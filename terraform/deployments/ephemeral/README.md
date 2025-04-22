This module is used to provision ephemeral EKS clusters via Terraform Cloud.

## Basic Usage

Set an ephemeral cluster ID before doing anything: `export EPH_CLUSTER_ID=eph-aaa111`

1. Ensure you have logged in to Terraform Cloud via the Terraform CLI (`terraform login`)
2. Do a `terraform init`
3. Run an apply with your chosen ephemeral cluster ID (this isn't generated for you)
   `terraform apply -var ephemeral_cluster_id=${EPH_CLUSTER_ID}`

State for the ephemeral module is stored locally for now.

### Shutdown

Ensure `EPH_CLUSTER_ID` is set to your ephemeral cluster ID

1. Get some AWS credentials in the test account
2. Run shutdown script
   `./shutdown.sh "${EPH_CLUSTER_ID}"`
3. Run Terraform destroy on the ephemeral workspaces
   `terraform apply -var ephemeral_cluster_id=${EPH_CLUSTER_ID} -destroy`

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

