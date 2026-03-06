package cli

import (
	"context"
	"fmt"
	"io"
	"os"
	"time"

	"github.com/spf13/cobra"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/watch"
	"k8s.io/client-go/dynamic"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"

	jrtypes "github.com/samsimpson/job-requests/internal/types"
)

func NewCreateCmd() *cobra.Command {
	var namespace string
	var follow bool

	cmd := &cobra.Command{
		Use:   "create <image> <command>",
		Short: "Create a new JobRequest",
		Args:  cobra.ExactArgs(2),
		RunE: func(cmd *cobra.Command, args []string) error {
			image := args[0]
			command := args[1]

			config, err := clientcmd.NewNonInteractiveDeferredLoadingClientConfig(
				clientcmd.NewDefaultClientConfigLoadingRules(),
				&clientcmd.ConfigOverrides{},
			).ClientConfig()
			if err != nil {
				return fmt.Errorf("failed to load kubeconfig: %w", err)
			}

			if namespace == "" {
				ns, _, err := clientcmd.NewNonInteractiveDeferredLoadingClientConfig(
					clientcmd.NewDefaultClientConfigLoadingRules(),
					&clientcmd.ConfigOverrides{},
				).Namespace()
				if err != nil {
					return fmt.Errorf("failed to determine namespace: %w", err)
				}
				namespace = ns
			}

			client, err := dynamic.NewForConfig(config)
			if err != nil {
				return fmt.Errorf("failed to create client: %w", err)
			}

			jr := jrtypes.NewJobRequest(namespace, image, command)

			created, err := client.Resource(jrtypes.JobRequestGVR).Namespace(namespace).Create(
				context.TODO(), jr, metav1.CreateOptions{},
			)
			if err != nil {
				return fmt.Errorf("failed to create JobRequest: %w", err)
			}

			name := created.GetName()
			fmt.Printf("JobRequest created: %s\n", name)

			fmt.Printf("To approve, run: kubectl job-request approve %s -n %s\n", name, namespace)

			if !follow {
				return nil
			}

			fmt.Printf("Waiting for approval and job to start...\n")

			ctx := cmd.Context()

			jobName, err := waitForJob(ctx, client, namespace, name)
			if err != nil {
				return err
			}

			fmt.Printf("Job started: %s\n", jobName)

			typedClient, err := kubernetes.NewForConfig(config)
			if err != nil {
				return fmt.Errorf("failed to create typed client: %w", err)
			}

			podName, err := waitForPod(ctx, typedClient, namespace, jobName)
			if err != nil {
				return err
			}

			fmt.Printf("Streaming logs from pod %s...\n", podName)

			return streamLogs(ctx, typedClient, namespace, podName)
		},
	}

	cmd.Flags().StringVarP(&namespace, "namespace", "n", "", "Kubernetes namespace (defaults to current context)")
	cmd.Flags().BoolVarP(&follow, "follow", "f", false, "Wait for job to start and follow its logs")
	return cmd
}

// waitForJob watches a JobRequest until a Job is created (status.jobName is set)
// or the request fails. It returns the job name.
func waitForJob(ctx context.Context, client dynamic.Interface, namespace, name string) (string, error) {
	watcher, err := client.Resource(jrtypes.JobRequestGVR).Namespace(namespace).Watch(ctx, metav1.ListOptions{
		FieldSelector: fmt.Sprintf("metadata.name=%s", name),
	})
	if err != nil {
		return "", fmt.Errorf("failed to watch JobRequest: %w", err)
	}
	defer watcher.Stop()

	for event := range watcher.ResultChan() {
		if event.Type == watch.Error {
			return "", fmt.Errorf("watch error")
		}

		obj, ok := event.Object.(*unstructured.Unstructured)
		if !ok {
			continue
		}

		status := jrtypes.GetStatusField(obj, "requestStatus")
		jobName := jrtypes.GetStatusField(obj, "jobName")

		if status == jrtypes.StatusFailed {
			return "", fmt.Errorf("JobRequest failed")
		}

		if jobName != "" {
			return jobName, nil
		}
	}

	return "", fmt.Errorf("watch closed unexpectedly")
}

// waitForPod waits for a Pod owned by the given Job to exist and be past the
// Pending phase so that logs are available.
func waitForPod(ctx context.Context, client kubernetes.Interface, namespace, jobName string) (string, error) {
	selector := fmt.Sprintf("job-name=%s", jobName)

	watcher, err := client.CoreV1().Pods(namespace).Watch(ctx, metav1.ListOptions{
		LabelSelector: selector,
	})
	if err != nil {
		return "", fmt.Errorf("failed to watch pods: %w", err)
	}
	defer watcher.Stop()

	// Check if a pod already exists before watching events.
	pods, err := client.CoreV1().Pods(namespace).List(ctx, metav1.ListOptions{
		LabelSelector: selector,
	})
	if err != nil {
		return "", fmt.Errorf("failed to list pods: %w", err)
	}
	for i := range pods.Items {
		if podReady(&pods.Items[i]) {
			return pods.Items[i].Name, nil
		}
	}

	for event := range watcher.ResultChan() {
		if event.Type == watch.Error {
			return "", fmt.Errorf("pod watch error")
		}

		pod, ok := event.Object.(*corev1.Pod)
		if !ok {
			continue
		}

		if podReady(pod) {
			return pod.Name, nil
		}
	}

	return "", fmt.Errorf("pod watch closed unexpectedly")
}

// podReady returns true when the pod has moved past Pending and logs should be
// available to stream.
func podReady(pod *corev1.Pod) bool {
	return pod.Status.Phase != corev1.PodPending && pod.Status.Phase != ""
}

// streamLogs follows the container logs for a pod, copying them to stdout.
func streamLogs(ctx context.Context, client kubernetes.Interface, namespace, podName string) error {
	// Brief pause to let the kubelet start the container log stream.
	time.Sleep(500 * time.Millisecond)

	req := client.CoreV1().Pods(namespace).GetLogs(podName, &corev1.PodLogOptions{
		Follow: true,
	})

	stream, err := req.Stream(ctx)
	if err != nil {
		return fmt.Errorf("failed to stream logs: %w", err)
	}
	defer stream.Close()

	if _, err := io.Copy(os.Stdout, stream); err != nil {
		return fmt.Errorf("error reading logs: %w", err)
	}

	return nil
}
