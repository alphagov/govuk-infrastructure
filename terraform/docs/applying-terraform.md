# Applying Terraform

The EKS cluster is deployed via Terraform in two stages. See [adr-3] for background.

- `cluster-infrastructure` is concerned only with setting-up the EKS cluster and associated AWS resources (such as the worker groups and auto-scaling groups).
- `cluster-services` is concerned only with setting up the Kubernetes resources and configuration for base services, including the `aws-auth` ConfigMap, ingress controller, etc.

## Deployment

**We no longer have any deployment automation for Terraform** (since the demise of Big Concourse).

For testing before merging to `main`, we can run Terraform locally against the test account.

When turning up from scratch, deploy the root modules in this order:

1. `terraform-lock`
1. `ecr` (test and production accounts only)
1. `cluster-infrastructure`
1. Delete the `aws-auth` configmap by running `gds aws govuk-${ENV?}-admin -- aws eks update-kubeconfig --name govuk && kubectl -n kube-system delete cm aws-auth`. This is a workaround for the problem that one of the AWS-managed EKS addons creates a default aws-auth configmap which then either needs to be imported into Terraform or deleted.
1. `govuk-publishing-infrastructure`
1. `cluster-services`

### `cluster-infrastructure`, `cluster-services` or `govuk-publishing-infrastructure` modules

```sh
ENV=test  # or integration, staging, production
cd terraform/deployments/cluster-infrastructure  # or cluster-services or govuk-publishing-infrastructure

gds aws govuk-${ENV?}-admin -- terraform init -backend-config=${ENV?}.backend -reconfigure -upgrade
gds aws govuk-${ENV?}-admin -- terraform apply -var-file ../variables/common.tfvars -var-file ../variables/${ENV?}/common.tfvars
```

### Other modules

See the README.md for the module:

* [`ecr`](../deployments/ecr/README.md) (test and production accounts only)
* [`github`](../deployments/github/README.md)
* [`terraform-lock`](../deployments/terraform-lock/README.md)

## Running kubectl

```sh
AWS_DEFAULT_REGION=eu-west-1
gds aws govuk-test-admin -e -- bash -l
aws eks update-kubeconfig --name govuk
kubectl get nodes
```

[adr-3]: https://github.com/alphagov/govuk-infrastructure/blob/main/docs/architecture/decisions/0003-split-terraform-state-into-separate-aws-cluster-and-kubernetes-resource-phases.md
