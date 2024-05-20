# tfc-aws-config

The `tfc-aws-config` root module sets up the OpenID Connect authentication and AWS
IAM authorisation for the `govuk` Terraform Cloud org to manage resources in
the GOV.UK AWS accounts.

## Apply

You must apply this module locally. It cannot be applied from within Terraform
Cloud.

1. Log into GCP.

    ```sh
    gcloud auth application-default login
    ```

1. Log into Terraform Cloud.

    ```sh
    terraform login
    ```

1. Fetch remote modules etc.

    ```sh
    terraform init -upgrade
    ```

1. Run `terraform apply` for each workspace.

    ```sh
    for account in tools test integration staging production; do
      terraform workspace select tfc-aws-config-$account
      gds aws govuk-$account-admin -- \
        terraform apply -var=govuk_environment=$account
    done
    ```
