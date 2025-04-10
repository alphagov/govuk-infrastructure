This module is used to provision ephemeral EKS clusters via Terraform Cloud.

## Basic Usage

1. Ensure you have logged in to Terraform Cloud via the Terraform CLI (`terraform login`)
2. Do a `terraform init`
3. Run an apply with your chosen ephemeral cluster ID (this isn't generated for you)
   `terraform apply -var ephemeral_cluster_id=eph-da2f44`

You will probably have to run the apply a couple of times due to Terraform not waiting for
things like Load Balancers becoming available.

State for the ephemeral module is stored locally for now.

### Alertmanager, Prometheus and Grafana

As an example if the cluster ID as `eph-da2f44` then these are the following URLs to access the monitoring apps:

- Alertmanager: https://alertmanager.eph-da2f44.ephemeral.govuk.digital/
- CKAN:  https://ckan.eph-da2f44.ephemeral.govuk.digital/
- Grafana: https://grafana.eph-da2f44.ephemeral.govuk.digital/

#### Validating the monitoring configuration

1. Check that the `watchdog` alert is firing in AlertManager
2. Navigate to `Dashboards` and verify if there are dashboards present
3. Navigate to `Alert rules` and verify if there are alerting rules present
4. Log into the CKAN website:

```
username: ckan_admin_test
password: test1234
```

5. Click on the `Harvest` tab
6. Click on `Add Harvest Source` and fill in the fields with these details
```
URL: http://environment.data.gov.uk/discover/ea/csw
Title: Environment Agency
Source Type: CSW
Update frequency: Manual
```

7. Click on `Admin` and then `Reharvest` to trigger a harvest job
8. Verify that metrics are appearing in Grafana in `App: request rates, errors, durations dashboard`

#### Testing out `argo-bootstrap-ephemeral`

Sometimes you want to test out a change to `argo-bootstrap-ephemeral` in `govuk-helm-charts` in the ephemeral cluster before creating a PR in `govuk-infrastructure` and running the Terraform. To do this:

1. Increment `version` in `Chart.yaml`
2. Run `helm upgrade -n cluster-services argo-bootstrap-ephemeral ./charts/argo-bootstrap-ephemeral --reuse-values`
3. After you have finished testing your changes create a Terraform run in `cluster-services-eph-da2f44` to downgrade the Helm chart

### Teardown

This hasn't been properly tested yet, and just running a `terraform apply -destroy` in the ephemeral module
isn't enough to destroy all resources correctly. (TF tries to destroy things like variable sets while running the destroys, which causes things to break)

1. Remove all `Application` resources on the cluster (these will mostly be in the `cluster-services` NS). This will cause the ELB controller and EBS CSI driver to delete any Load Balancers and block storage used by apps in the cluster
2. Run destroys on the underlying Terraform Cloud workspaces. Assuming your cluster ID is `eph-aaa111`, these will be:
   1. `datagovuk-infrastructure-eph-aaa111`
   2. `cluster-services-eph-aaa111`
   3. `cluster-infrastructure-eph-aaa111`
3. Run a destroy on your ephemeral module via the Terraform CLI
