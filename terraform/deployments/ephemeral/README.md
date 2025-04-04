This module is used to provision ephemeral EKS clusters via Terraform Cloud.

## Basic Usage

1. Ensure you have logged in to Terraform Cloud via the Terraform CLI (`terraform login`)
2. Do a `terraform init`
3. Run an apply with your chosen ephemeral cluster ID (this isn't generated for you)
   `terraform apply -var ephemeral_cluster_id=eph-da2f44`

You will probably have to run the apply a couple of times due to Terraform not waiting for
things like Load Balancers becoming available.

State for the ephemeral module is stored locally for now.

### Validating working alertmanager, prometheus and grafana

If we take the cluster id as being `eph-da2f44` then these will be the URLs to access the web apps running on the ephemeral cluster:

- Alertmanager: https://alertmanager.eph-da2f44.ephemeral.govuk.digital/
- CKAN:  https://ckan.eph-da2f44.ephemeral.govuk.digital/
- Grafana: https://grafana.eph-da2f44.ephemeral.govuk.digital/

- to validate that alertmanager is working by checking that the `watchdog` alert is firing.
- validation of grafana and prometheus working can done by logging into the CKAN website as an admin user 

  - username: ckan_admin_test
  - password: test1234

- and then creating a harvest job in CKAN with the following parameters:

  - url: http://environment.data.gov.uk/discover/ea/csw
  - source type: csw

and finally clicking on the reharvest button under on the Admin site of harvest job page. More detailed instructions can be found in the E2E testing documentation for DGU on an Ephemeral cluster.

Shortly after triggering the harvest job, metrics should start to appear in grafana in the `App: request rates, errors, durations dashboard`.

### Teardown

This hasn't been properly tested yet, and just running a `terraform apply -destroy` in the ephemeral module
isn't enough to destroy all resources correctly. (TF tries to destroy things like variable sets while running the destroys, which causes things to break)

1. Remove all `Application` resources on the cluster (these will mostly be in the `cluster-services` NS). This will cause the ELB controller and EBS CSI driver to delete any Load Balancers and block storage used by apps in the cluster
2. Run destroys on the underlying Terraform Cloud workspaces. Assuming your cluster ID is `eph-aaa111`, these will be:
   1. `datagovuk-infrastructure-eph-aaa111`
   2. `cluster-services-eph-aaa111`
   3. `cluster-infrastructure-eph-aaa111`
3. Run a destroy on your ephemeral module via the Terraform CLI
