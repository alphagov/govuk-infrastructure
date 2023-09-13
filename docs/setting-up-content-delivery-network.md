# Content Delivery Network (CDN) - Fastly

GOV.UK uses Fastly as its Content Delivery Network (CDN).

## Setting-up

To setup Fastly, log into the Fastly web management [portal](https://manage.fastly.com/).

### TLS certificate

1. Choose a domain that users will use to reach your GOV.UK environment, e.g.
   the GOV.UK EKS platform uses domain with format `www.eks.<environment>.govuk.digital`
2. Create a Fastly/letsencrypt TLS certificate for your chosen domain and attach
   it to the "govuk" TLS configuration. Further details are available [here](https://docs.fastly.com/en/guides/serving-https-traffic-using-fastly-managed-certificates)
3. You will be asked to create a CNAME to point to a specific given address, you should use
   this address as the value of the variable `www_dns_validation_rdata` in the `commons.yaml` file
   of the environment you are deploying, e.g. for integration it is located [here](https://github.com/alphagov/govuk-infrastructure/blob/main/terraform/deployments/variables/integration/common.tfvars)


### CDN service

1. In the Fastly portal, create a new CDN service, e.g. `<environment> GOV.UK EKS`.
   You should use the same domain that you have chosen above. Make a note of the new service ID.
2. Create a pull request in the [GitHub repo](https://github.com/alphagov/govuk-cdn-config-secrets)
   with a new service under `www-eks`. You can use this previous [pull request](https://github.com/alphagov/govuk-cdn-config-secrets/pull/151)
   as example.
3. See [how to deploy Fastly](https://docs.publishing.service.gov.uk/manual/cdn.html#deploying-fastly).
