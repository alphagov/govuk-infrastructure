# AWS EKS

## Procedure

1. Create cluster

```sh
gds aws govuk-test-admin -- terraform init -backend-config test.backend
gds aws govuk-test-admin -- terraform apply
```

2. Update kubeconfig

```sh
gds aws govuk-test-admin -- aws eks --region eu-west-1 update-kubeconfig --name govuk
```

test by:

```sh
gds aws govuk-test-admin -- kubectl get nodes
```

3. Add all the apps: frontend, static, content-store

```sh
gds aws govuk-test-admin -- kubectl apply -f <repository_home>/helm/govuk-charts/<app_name>/app.yml
```

4. Get ingress address, i.e load balancer

```sh
gds aws govuk-test-admin -- kubectl get ingress
```
