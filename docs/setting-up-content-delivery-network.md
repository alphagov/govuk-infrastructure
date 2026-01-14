<!-- vale RedHat.Headings = NO --> 
# Content Delivery Network (CDN) - Fastly

GOV.UK uses Fastly as its Content Delivery Network (CDN).

## Setting-up

To setup Fastly, log into the Fastly web management [portal](https://manage.fastly.com/).

### TLS certificate

1. Choose a domain that users will use to reach your GOV.UK environment, e.g.
   the GOV.UK Elastic Kubernetes Service (EKS) platform uses a domain with format `www.eks.<environment>.govuk.digital`
2. Create a Fastly/Let's Encrypt TLS certificate for your chosen domain and [attach it](https://docs.fastly.com/en/guides/serving-https-traffic-using-fastly-managed-certificates)
   to the `govuk` TLS configuration.
3. Create a CNAME to point to the address in the value of the variable `www_dns_validation_rdata` in the `commons.yaml` file
   belonging to the environment you are deploying; for example, the file for the `integration` environment 
   is [located at `terraform/deployments/variables/integration/common.tfvars`](https://github.com/alphagov/govuk-infrastructure/blob/main/terraform/deployments/variables/integration/common.tfvars)


### CDN service

1. In the Fastly portal, create a new CDN service, e.g. `<environment> GOV.UK EKS`.
   You should use the same domain that you have chosen above. Make a note of the new service ID.
2. Create a pull request in [the `govuk-cdn-config-secrets` GitHub repository](https://github.com/alphagov/govuk-cdn-config-secrets)
   with a new service under `www-eks`. You can use an [example pull request](https://github.com/alphagov/govuk-cdn-config-secrets/pull/151)
   to guide you.
3. See [how to deploy Fastly](https://docs.publishing.service.gov.uk/manual/cdn.html#deploying-fastly).
