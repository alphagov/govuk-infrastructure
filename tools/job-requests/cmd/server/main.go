package main

import (
	"context"
	"crypto/tls"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"k8s.io/client-go/dynamic"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"

	"github.com/samsimpson/job-requests/internal/controller"
	"github.com/samsimpson/job-requests/internal/webhooks"
)

func main() {
	certFile := getEnv("TLS_CERT_FILE", "/etc/webhook/certs/tls.crt")
	keyFile := getEnv("TLS_KEY_FILE", "/etc/webhook/certs/tls.key")
	addr := getEnv("LISTEN_ADDR", ":8443")

	config, err := rest.InClusterConfig()
	if err != nil {
		log.Fatalf("failed to get in-cluster config: %v", err)
	}

	dynamicClient, err := dynamic.NewForConfig(config)
	if err != nil {
		log.Fatalf("failed to create dynamic client: %v", err)
	}

	typedClient, err := kubernetes.NewForConfig(config)
	if err != nil {
		log.Fatalf("failed to create typed client: %v", err)
	}

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()

	// Start the controller in the background
	ctrl := controller.New(dynamicClient, typedClient)
	go func() {
		if err := ctrl.Run(ctx); err != nil {
			log.Fatalf("controller error: %v", err)
		}
	}()

	// Set up webhook HTTPS server
	mux := http.NewServeMux()
	mux.HandleFunc("/mutate", webhooks.HandleMutate)
	mux.HandleFunc("/validate", webhooks.HandleValidate)
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	cert, err := tls.LoadX509KeyPair(certFile, keyFile)
	if err != nil {
		log.Fatalf("failed to load TLS certificate: %v", err)
	}

	server := &http.Server{
		Addr:    addr,
		Handler: mux,
		TLSConfig: &tls.Config{
			Certificates: []tls.Certificate{cert},
		},
	}

	go func() {
		<-ctx.Done()
		log.Println("shutting down webhook server")
		server.Close()
	}()

	log.Printf("starting webhook server on %s", addr)
	if err := server.ListenAndServeTLS("", ""); err != nil && err != http.ErrServerClosed {
		log.Fatalf("webhook server error: %v", err)
	}
}

func getEnv(key, fallback string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return fallback
}
