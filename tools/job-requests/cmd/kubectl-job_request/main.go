package main

import (
	"os"

	"github.com/spf13/cobra"

	"github.com/samsimpson/job-requests/internal/cli"
)

func main() {
	rootCmd := &cobra.Command{
		Use:   "kubectl-job_request",
		Short: "Manage Kubernetes JobRequests with approval workflow",
	}

	rootCmd.AddCommand(cli.NewCreateCmd())
	rootCmd.AddCommand(cli.NewApproveCmd())

	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}
