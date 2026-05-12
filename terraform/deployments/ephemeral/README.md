This module is used to provision ephemeral EKS clusters via Terraform Cloud.

## Basic Usage

1. `export EPH_CLUSTER_ID=eph-aaa111`
1. ensure you are in the correct dir `terraform/deployments/ephemeral`
1. Ensure you have logged in to Terraform Cloud via the Terraform CLI (`terraform login`)
1. Do a `terraform init`
1. Run an apply with your chosen ephemeral cluster ID (this isn't generated for you):
   ```
   terraform apply -var ephemeral_cluster_id=${EPH_CLUSTER_ID}
   ``` 
   If your new ephemeral cluster should be based on a branch other than `main`, provide the `git_branch` variable:

   ```
   terraform apply -var ephemeral_cluster_id=${EPH_CLUSTER_ID} -var git_branch="$(git branch --show-current)"
   ```
   
1. When `cluster_access` has applied successfully you can gain access to the cluster with `aws eks update-kubeconfig --name ${EPH_CLUSTER_ID} --kubeconfig <optional_new_kube_config>`
1. Once all the Terraform workspaces have successfully applied, log into the cluster and
   run `./validate.sh` to test that the cluster is functioning and able to accept ingress.

State for the ephemeral module is stored locally for now.

### Alertmanager, Prometheus and Grafana

As an example if the cluster ID is `eph-da2f44` then these are the following URLs to access the monitoring apps:

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

### Shutdown

#### Prerequisites

- `EPH_CLUSTER_ID` set to your cluster ID (e.g. `eph-ctf-260429`)
- AWS credentials assumed for the test account (`govuk-test-platformengineer` or `govuk-test-fulladmin`)
- Terraform Cloud CLI authenticated (`terraform login`)
- `kubectl`, `helm`, `jq`, and `curl` available on `$PATH`

#### Steps

1. Assume the `govuk-test-platformengineer` (or `govuk-test-fulladmin`) role.

2. Run the shutdown script:
   ```bash
   ./shutdown.sh "${EPH_CLUSTER_ID}"
   ```
   The script will:
   - Update your kubeconfig to point at the target cluster
   - Delete all Helm-managed Argo CD Application resources
   - Uninstall all Helm charts (load balancer controller and external-dns last, so cloud resources they manage are cleaned up first)
   - Trigger Terraform Cloud destroy runs in dependency order:
     `datagovuk-infrastructure` -> `rds` -> `cluster-access` -> `cluster-services` -> `cluster-infrastructure` -> `vpc`
   - Poll each destroy run until completion before starting the next

   The script authenticates to Terraform Cloud using the token in `~/.terraform.d/credentials.tfrc.json`.

3. After the shutdown script completes, destroy the local Terraform state for the ephemeral workspaces:
   ```bash
   terraform apply -var ephemeral_cluster_id=${EPH_CLUSTER_ID} -destroy
   ```

#### Troubleshooting

##### MFA session timeout

The full shutdown takes 30-60 minutes. If your AWS MFA session has a short
TTL, it may expire mid-run causing `kubectl`, `helm`, or `aws` calls to
fail. Either request a longer session duration before starting, or re-auth
and re-run the script — it is mostly idempotent (already-deleted resources
are skipped).

##### Cluster API server unreachable

If the EKS cluster has already been partially destroyed (e.g. by a previous
failed run or manual intervention), `kubectl` and `helm` commands will fail
with:

```
error: kubernetes cluster unreachable: the server has asked for the client to provide credentials
```

The script uses `set -eu` and will exit immediately. In this case, the Argo CD
Applications and Helm charts are already gone (the cluster is gone), but the
TFC destroy runs for the remaining workspaces have not been triggered. You
need to destroy the remaining workspaces manually — see below.

##### Pending or errored Terraform Cloud runs

1. **Check the Terraform Cloud run.** The script prints a direct link to each run. Open it and check for:
   - **Pending state**: another run is queued ahead of the destroy. Discard the earlier run, then unlock the workspace.
   - **Errored state**: read the error, fix the underlying issue (e.g. a resource that can't be deleted), then re-run the script.

##### Manually destroying remaining workspaces

Search for your cluster ID in the [Terraform Cloud workspace list](https://app.terraform.io/app/govuk/workspaces). Destroy workspaces in dependency order, waiting for each to complete before starting the next:

1. `cluster-services-<cluster-id>`
2. `cluster-infrastructure-<cluster-id>`
3. `vpc-<cluster-id>`

For each workspace:
- Go to **Settings > Destruction and Deletion**
- Queue a destroy plan and wait for it to complete
- Delete the workspace

Any workspaces with 0 resources (e.g. `cluster-access`) can be deleted directly without queueing a destroy plan.

##### Cleaning up orphaned local state

If Terraform Cloud workspaces are gone but local state still references resources:

```bash
terraform refresh -var "ephemeral_cluster_id=${EPH_CLUSTER_ID}"
terraform state list
terraform state show <resource-name>   # inspect before destroying
terraform destroy -var "ephemeral_cluster_id=${EPH_CLUSTER_ID}"
```

> **Note**: Terraform Cloud workspaces are not removed by `terraform destroy`. They must be deleted manually via the Terraform Cloud UI under **Settings > Destruction and Deletion**.
