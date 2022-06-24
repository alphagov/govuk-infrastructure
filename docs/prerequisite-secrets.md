# Prerequisite Secrets

The platform requires some prerequisite secrets in order to fully function.
These secrets are stores in AWS Secret Manager, further info about the integration
of the k8s platform platform with AWS Secret Manager is available [here](kubernetes-external-secrets.md)

The secrets listed here are either:
1. externally generated in external systems and imported into our platform. E.g.
   GitHub OAUTH secret; or
2. generated manually and used between different components of our platform.
   We don't have a method yet to autogenerate these. E.g. OAUTH shared secret between
   ArgoCD (continuous delivery tool) and Dex (federated OpenID Connect provider).
3. GOV.UK app specific secrets which are referred to in
   [govuk-apps-conf](https://github.com/alphagov/govuk-helm-charts/tree/main/charts/govuk-apps-conf/templates/external-secrets)
   helm chart of the [govuk-helm-charts] GitHub repository. These are usually copied across from
   from [govuk-secrets](https://github.com/alphagov/govuk-secrets)

The canonical source of all the platform secrets required are listed
[here](https://github.com/alphagov/govuk-helm-charts/tree/main/charts/cluster-secrets/templates)
in the [govuk-helm-charts] GitHub repository.

The purpose of this document is to provide information about:
1. how these secrets are generated/obtained exactly
2. the JSON format to use when adding the secrets to AWS Secret Manager

The format of secret is given below to aid creation from scratch:  
`name of the secret in AWS Secrets Manager`: Description

```
{
  <key_1>: <secret_1>,
  <key_2>: <secret_2>
}
```

In addition, there are


## Externally generated platform secrets


1. `govuk/dex/github`: shared OAUTH secret between Dex and GitHub.
   Created via GitHub admin portal.

   ```
   {
     "clientID": "<secret_1>",
     "clientSecret": "<secret_2>"
   }
   ```

2. `govuk/logit-host`: used by FileBeat in Kubernetes cluster to access the Logit stack.
  Obtained from the Logit portal.

  ```
  {
    "host": "<secret_1>",
    "port": "<secret_2>
  }
  ```

3. `govuk/slack-webhook-url`: Slack url used to post on Slack channel `#govuk-deploy-alerts`
  Obtained from GDS/CO IT which manages Slack.

 ```
 {
   url": "<secret_1>"
 }
 ```


## Manually generated platform secrets

1. `govuk/dex/argocd`: shared OAUTH secret between Dex and ArgoCD.
    Can be generated manually using for example `openssl rand -hex 16`.

   ```
   {
     "clientID": "<secret_1>",
     "clientSecret": "<secret_2>"
   }
   ```

2. `govuk/dex/argo-workflows`: shared OAUTH secret between Dex and Argo-workflows.
   Can be generated manually using for example `openssl rand -hex 16`.

   ```
   {
     "clientID": "<secret_1>",
     "clientSecret": "<secret_2>"
   }
   ```

3. `govuk/dex/grafana`: shared OAUTH secret between Dex and Grafana.
   Can be generated manually using for example `openssl rand -hex 16`.

    ```
    {
      "clientID": "<secret_1>",
      "clientSecret": "<secret_2>"
    }
    ```

4. `govuk/dex/alert-manager`: shared OAUTH secret between Dex and Alert Manager.
   Can be generated manually using for example `openssl rand -hex 16`.

   ```
   {
     "clientID": "<secret_1>",
     "clientSecret": "<secret_2>",
     :cookieSecret": "<secret_3>"
   }
   ```

5. `govuk/dex/prometheus`: shared OAUTH secret between Dex and Alert Manager.
  Can be generated manually using for example `openssl rand -hex 16`.

  ```
  {
    "clientID": "<secret_1>",
    "clientSecret": "<secret_2>",
    cookieSecret: <secret_3>
  }
  ```

6. `govuk/fastly/api`: used by Fastly exporter in k8s to scrape Fastly metrics.
   Created in the Fastly management web console by creating a user which has access
   only to the fastly service associated with a particular GOV.UK environment.

   ```
   {
     "token": "<secret_1>"
   }
   ```

7. `govuk/github/govuk-ci`: used by ArgoCD to access GOV.UK GitHub repos.
   Created via GitHub portal of user `govuk-ci`.

   ```
   {
     "token": "<secret_1>",
     "username": "govuk-ci"
   }
   ```

[govuk-helm-charts](https://github.com/alphagov/govuk-helm-charts)
