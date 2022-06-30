# Applying Terraform

The EKS cluster is deployed via Terraform in two stages. See [adr-3] for background.

- `cluster-infrastructure` is concerned only with setting-up the EKS cluster and associated AWS resources (such as the worker groups and auto-scaling groups).
- `cluster-services` is concerned only with setting up the Kubernetes resources and configuration for base services, including the `aws-auth` ConfigMap, ingress controller, etc.

## Prerequisites

1. Some of the deployments below require external [tfvars
files](../terraform/deployments/variables). To create a new environment, you
will need to copy the variables directory for an existing environment (e.g.
[integration](../deployments/variables/integration)) and modify as
appropriate.
    1. `cluster-infrastructure` deployment assumes that there is a Fastly CDN service
       and requires a value (`www_dns_validation_rdata`) for creating the DNS validation of the Fastly domain. You can
       either use a dummy value or look at setting up the [CDN service](../../docs/setting-up-content-delivery-network.md)
1. Each of the deployments (except `ecr`) requires a [backend config
file](https://www.terraform.io/docs/language/settings/backends/configuration.html#partial-configuration)
You can use an existing backend file as a template.
1. `cluster-services` deployment requires some [prerequisite secrets](../../docs/prerequisite-secrets.md)
which are not generated automatically. Create these secrets before running
`terraform apply` for the first time.

## Deployment

**We no longer have any deployment automation for Terraform** (since the demise of Big Concourse).

For testing before merging to `main`, we can run Terraform locally against the test account.

When turning up from scratch, deploy the root modules in this order:

1. [`terraform-lock`](../deployments/terraform-lock): creates the
   DynamoDB table which Terraform uses to control concurrent access to the
   state files in S3.
1. [`ecr`](../deployments/ecr) (test and production accounts only): creates the ECR container registry from
   which the cluster pull container images. There is a single registry for all
   of the environments (to avoid consistency problems with image tags and
   having to copy images between registries), so this module is not deployed
   per-environment.
1. [`cluster-infrastructure`](../deployments/cluster-infrastructure): creates the AWS resources for the cluster.
1. Delete the `aws-auth` configmap by running `gds aws govuk-${ENV?}-admin -- aws eks update-kubeconfig --name govuk && kubectl -n kube-system delete cm aws-auth`. This is a workaround for the problem that one of the AWS-managed EKS addons creates a default aws-auth configmap which then either needs to be imported into Terraform or deleted.
1. [`govuk-publishing-infrastructure`](../deployments/govuk-publishing-infrastructure): creates AWS resources specific to the GOV.UK apps where we are not yet
able to manage those resources via Kubernetes.
1. [`cluster-services`](../deployments/cluster-services): deploys the base services into the cluster.
1. Create the Signon API token as a k8s secret by running `kubectl -n apps create secret generic signon-auth-token --from-literal=token=$(openssl rand -base64 40)`. This will allow
`signon-resources` to create/export tokens from `signon`, see [here](../../docs/signon-secrets.md) for further details.

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
