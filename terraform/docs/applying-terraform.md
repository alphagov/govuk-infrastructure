# Applying Terraform

The EKS cluster is deployed via Terraform in two stages. See [adr-3] for background.

- `cluster-infrastructure` is concerned only with setting-up the EKS cluster and associated AWS resources (such as the worker groups and auto-scaling groups).
- `cluster-services` is concerned only with setting up the Kubernetes resources and configuration for base services, including the `aws-auth` ConfigMap, ingress controller, etc.

## Prerequisites

1. `cluster-infrastructure` deployment assumes that there is a Fastly CDN service
   and requires a value (`www_dns_validation_rdata`) for creating the DNS validation of the Fastly domain. You can
   either use a dummy value or look at setting up the [CDN service](../../docs/setting-up-content-delivery-network.md)
2. `cluster-services` deployment requires some [prerequisite secrets](../../docs/prerequisite-secrets.md)
which are not generated automatically. Create these secrets before running
the Terraform apply for the first time.

## Deployment

All terraform modules in this repository are now deployed via Terraform Cloud.
To test changes before merging into main, open a PR and a plan will automatically
start for your branch.

When turning up from scratch, deploy the root modules in this order:

1. [`tfc-bootstrap`](../deployments/tfc-bootstrap): bootstraps Terraform Cloud and creates `tfc-configuration`
workspace which is used to manage the other Terraform module workspaces.
2. [`tfc-configuration`](../deployments/tfc-configuration): creates TFC workspaces for each terraform module and environment.
3. [`ecr`](../deployments/ecr) (test and production accounts only): creates the ECR container registry from
   which the cluster pull container images. There is a single registry for all
   of the environments (to avoid consistency problems with image tags and
   having to copy images between registries), so this module is not deployed
   per-environment.
4. [`cluster-infrastructure`](../deployments/cluster-infrastructure): creates the AWS resources for the cluster.
5. Delete the `aws-auth` configmap by running `gds aws govuk-${ENV?}-admin -- aws eks update-kubeconfig --name govuk && kubectl -n kube-system delete cm aws-auth`. This is a workaround for the problem that one of the AWS-managed EKS addons creates a default aws-auth configmap which then either needs to be imported into Terraform or deleted.
6. [`govuk-publishing-infrastructure`](../deployments/govuk-publishing-infrastructure): creates AWS resources specific to the GOV.UK apps where we are not yet
able to manage those resources via Kubernetes.
7. [`cluster-services`](../deployments/cluster-services): deploys the base services into the cluster.

### Bootstrapping Terraform Cloud

1. [Configure an OIDC connection between each AWS environment and Terraform Cloud](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/aws-configuration).
2.  Create an IAM role named `terraform-cloud` in each AWS environment.
    * See example [permissions policy](./example-tfc-role-policy.json) and [trust policy](./example-tfc-trust-policy.json).
3. Apply the [`tfc-bootstrap`](../deployments/tfc-bootstrap) module locally. This will create the `tfc-configuration` workspace, which will
   create all of the remaining workspaces.

### Other modules

See the README.md for the module:

* [`ecr`](../deployments/ecr/README.md) (test and production accounts only)
* [`github`](../deployments/github/README.md)

## Running kubectl

```sh
AWS_DEFAULT_REGION=eu-west-1
gds aws govuk-test-admin -e -- bash -l
aws eks update-kubeconfig --name govuk
kubectl get nodes
```

[adr-3]: https://github.com/alphagov/govuk-infrastructure/blob/main/docs/architecture/decisions/0003-split-terraform-state-into-separate-aws-cluster-and-kubernetes-resource-phases.md
