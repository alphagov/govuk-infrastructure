# Prerequisite Secrets

The platform requires some prerequisite secrets in order to fully function.

The secrets listed here are either:
1. externally generated in external systems and imported into our platform. E.g.
   GitHub OAUTH secret; or
2. generated manually and used between different components of our platform.
   We don't have a method yet to autogenerate these. E.g. OAUTH shared secret between
   ArgoCD (continuous delivery tool) and Dex (federated OpenID Connect provider).

The format of secret is given below to aid creation from scratch:  
`name of the secret in AWS Secrets Manager`: Description

```
{
  <key_1>: <secret_1>,
  <key_2>: <secret_2>
}
```


## Externally generated secrets

1. `govuk/dex/github`: shared OAUTH secret between Dex and GitHub. Obtained via
   GitHub admin portal.

   ```
   {
     clientID: <secret_1>,
     clientSecret: <secret_2>
   }
   ```

## Manually generated secrets

1. `govuk/dex/argocd`: shared OAUTH secret between Dex and ArgoCD.

   ```
   {
     clientID: <secret_1>,
     clientSecret: <secret_2>
   }
   ```

2. `govuk/dex/argo-workflows`: shared OAUTH secret between Dex and Argo-workflows.

   ```
   {
     clientID: <secret_1>,
     clientSecret: <secret_2>
   }
   ```

3. `govuk/dex/grafana`: shared OAUTH secret between Dex and Grafana.

    ```
    {
      clientID: <secret_1>,
      clientSecret: <secret_2>
    }
    ```

4. `govuk/dex/alert-manager`: shared OAUTH secret between Dex and Alert Manager.

   ```
   {
     clientID: <secret_1>,
     clientSecret: <secret_2>
   }
   ```
