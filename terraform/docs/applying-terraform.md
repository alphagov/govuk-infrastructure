# Applying Terraform

The EKS cluster is deployed via Terraform in two stages. See [adr-3] for background.

- `cluster-infrastructure` is concerned only with setting-up the EKS cluster and associated AWS resources (such as the worker groups and auto-scaling groups).
- `cluster-services` is concerned only with setting up the Kubernetes resources and configuration for base services, including the `aws-auth` ConfigMap, ingress controller, etc.

## Automated Deployment via Concourse

The `cluster-infrastructure` and `cluster-services` modules are deployed one after another by the [`eks` Concourse pipeline](https://cd.gds-reliability.engineering/teams/govuk-test/pipelines/eks).

The pipeline will trigger on any commit to the `main` branch of the `govuk-infrastructure` repo.

The automated deployment is not truly continuous in that it has no way to detect *when* something/someone else changes the resources which it owns. That is, any manual/external changes to (for example) AWS resources will be ignored until the next commit to `main`, at which point they'll be overwritten.

## Local Deployment

For testing before merging to `main`, we can run Terraform locally against the test account.

### Cluster infrastructure

You can update the base infrastructure from your machine to test things.
For example, run the following commands to update the test environment:

```sh
cd terraform/deployments/cluster-infrastructure
gds aws govuk-test-admin -- terraform init -backend-config=test.backend -reconfigure
gds aws govuk-test-admin -- terraform plan -var-file ../variables/test/common.tfvars
```

### Cluster services

As above, but with `terraform/deployments/cluster-services`.

### Running kubectl

```sh
AWS_DEFAULT_REGION=eu-west-1
eval $(gds aws govuk-test-admin -e)
aws eks update-kubeconfig --name govuk
kubectl get nodes
```

[adr-3]: https://github.com/alphagov/govuk-infrastructure/blob/main/docs/architecture/decisions/0003-split-terraform-state-into-separate-aws-cluster-and-kubernetes-resource-phases.md
