# opensearch-blue-green-deployment

This module will allow you to deploy an opensearch (or elasticsearch) domain cluster, it will be deployed as either blue or green, you can deploy both blue and green and switch which is live
with a variable, this allows you to have a blue cluster running, launch a green cluster, restore a snapshot from the blue cluster into the green cluster, and then switch which cluster the
CNAME points to, finally then removing the blue cluster.

The individual clusters can be different engines (Elasticsearch or OpenSearch), be on different versions, or have a wildly different cluster configuration.

**IMPORTANT**: Once you have launched a domain (blue or green) for the first time you need to register the S3 bucket as a snapshot repository. The instructions for doing this are at the top of the
[register-snapshot-repository.py](./register-snapshot-repository.py) script.

## Usage

See the examples below, and see [USAGE.md](./USAGE.md) for a complete list of all options with descriptions.

## Examples

### Just launch a blue domain with minimal config
```tf
module "opensearch" {
  source = "../../shared-modules/opensearch-blue-green-deployment"

  opensearch_domain_name = "ai-accelerator"

  current_live_domain = "blue"
  launch_blue_domain  = true
  launch_green_domain = false

  blue_cluster_options  = var.blue_cluster_options
 
  govuk_environment                            = "integration"
  secrets_manager_prefix                       = "govuk/ai-accelerator" // pragma: allowlist secret

  blue_cluster_options = {
    engine         = "OpenSearch"
    engine_version = "3.1"
    instance_count = 3
    instance_type  = "t3.small.search"
    ebs_options = {
      volume_size = 90
      volume_type = "gp3"
      throughput  = 250
    }
  }

  aws_region = "eu-west-1"
}
```

### Launch a Blue and Green cluster 

**NOTE**: You would switch which the CNAME points to by changing `current_live_domain` to `green`.

```tf
module "opensearch" {
  source = "../../shared-modules/opensearch-blue-green-deployment"

  opensearch_domain_name = "ai-accelerator"

  current_live_domain = "blue"
  launch_blue_domain  = true
  launch_green_domain = true

  blue_cluster_options  = var.blue_cluster_options
 
  govuk_environment      = "integration"
  secrets_manager_prefix = "govuk/ai-accelerator" // pragma: allowlist secret

  blue_cluster_options = {
    engine         = "OpenSearch"
    engine_version = "3.0"
    instance_count = 3
    instance_type  = "t3.small.search"
    ebs_options = {
      volume_size = 90
      volume_type = "gp3"
      throughput  = 250
    }
  }


  green_cluster_options = {
    engine         = "OpenSearch"
    engine_version = "3.1"
    instance_count = 3
    instance_type  = "t3.small.search"
    ebs_options = {
      volume_size = 90
      volume_type = "gp3"
      throughput  = 250
    }
  }

  aws_region = "eu-west-1"
}
```

### Complete configuration example launching only a blue cluster

```tf
module "opensearch" {
  source = "../../shared-modules/opensearch-blue-green-deployment"

  opensearch_domain_name = "ai-accelerator"

  current_live_domain = "blue"
  launch_blue_domain  = true
  launch_green_domain = false

  blue_cluster_options  = var.blue_cluster_options
 
  govuk_environment      = "staging"
  secrets_manager_prefix = "govuk/ai-accelerator" // pragma: allowlist secret

  blue_cluster_options = {
    engine         = "OpenSearch"
    engine_version = "3.1"
    instance_count = 3
    instance_type  = "t3.small.search"
    dedicated_master = {
      instance_count = 3
      instance_type = "t3.small.search"
    }
    zone_awareness_enabled = true
    advanced_security_options = {
      anonymous_auth_enabled = true
      internal_user_database_enabled = false
    }
    endpoint_tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
    ebs_options = {
      volume_size = 90
      volume_type = "gp3"
      throughput  = 250
    }
  }

  read_snapshots_from_environment = [
    "production"
  ]
  account_ids_allowed_to_read_domain_snapshots = ["210287912431"]
  s3_bucket_custom_suffix = "os-snaps"

  aws_region = "eu-west-1"
}
```
