# Terraform for GOV.UK

## Docs

* [Applying Terraform](docs/applying-terraform.md)
* [AWS tagging schema](docs/tagging-guide.md)

## Directory structure

* `deployments`: root modules that make up a GOV.UK workload account (integration, staging, production), and some 
contributing services such as GitHub and Sentry. You can run Terraform commands in each of these.

* `tools`: root modules that make up the Tools account, which contains centralised services such as CI/CD. You can run
Terraform commands in each of these.,

* `shared-modules`: re-usable Terraform modules, used by at least 2 roots. Terraform modules which are used by just one
root should be a subdirectory of it.#

* `variables`: Terraform variables files for different environments. They are used in conjunction with the Terraform roots
in `deployments`
