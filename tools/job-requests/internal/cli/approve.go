package cli

import (
	"context"
	"fmt"

	"github.com/spf13/cobra"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/dynamic"
	"k8s.io/client-go/tools/clientcmd"

	jrtypes "github.com/samsimpson/job-requests/internal/types"
)

func NewApproveCmd() *cobra.Command {
	var namespace string
	var yes bool

	cmd := &cobra.Command{
		Use:   "approve <job-request-name>",
		Short: "Approve a pending JobRequest",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			name := args[0]

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

			jr, err := client.Resource(jrtypes.JobRequestGVR).Namespace(namespace).Get(
				context.TODO(), name, metav1.GetOptions{},
			)
			if err != nil {
				return fmt.Errorf("failed to get JobRequest: %w", err)
			}

			status := jrtypes.GetStatusField(jr, "requestStatus")
			if status != jrtypes.StatusPending {
				return fmt.Errorf("JobRequest %s is not pending (current status: %s)", name, status)
			}

			image := jrtypes.GetSpecField(jr, "image")
			command := jrtypes.GetSpecField(jr, "command")
			createdBy := jrtypes.GetStatusField(jr, "createdBy")

			fmt.Printf("JobRequest: %s\n", name)
			fmt.Printf("  Created by: %s\n", createdBy)
			fmt.Printf("  Image:      %s\n", image)
			fmt.Printf("  Command:    %s\n", command)

			if !yes {
				fmt.Printf("\nTo approve, run: kubectl job-request approve %s -n %s --yes\n", name, namespace)
				return nil
			}

			// Set requestStatus to Approved. The mutating webhook will set approvedBy
			// from the authenticated user's identity.
			jrtypes.SetStatusField(jr, "requestStatus", jrtypes.StatusApproved)

			_, err = client.Resource(jrtypes.JobRequestGVR).Namespace(namespace).UpdateStatus(
				context.TODO(), jr, metav1.UpdateOptions{},
			)
			if err != nil {
				return fmt.Errorf("failed to approve JobRequest: %w", err)
			}

			fmt.Printf("\nJobRequest %s approved\n", name)
			return nil
		},
	}

	cmd.Flags().StringVarP(&namespace, "namespace", "n", "", "Kubernetes namespace (defaults to current context)")
	cmd.Flags().BoolVar(&yes, "yes", false, "Confirm approval")
	return cmd
}
