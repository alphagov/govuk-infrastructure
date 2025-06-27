# Elasticsearch cluster

Managed Elasticsearch 6 cluster

The snapshot repository configuration is not currently done via Terraform;
see register-snapshot-repository.py.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | 0.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.opensearch_error_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.opensearch_index_slow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.opensearch_search_slow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.opensearch_log_publishing_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_elasticsearch_domain.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain) | resource |
| [aws_iam_policy.can_configure_es_snapshots](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.manual_snapshot_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.manual_snapshot_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.manual_snapshot_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_service_linked_role.es_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_route53_record.service_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.manual_snapshots](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_logging.manual_snapshots](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.manual_snapshots_cross_account_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_acm_certificate.govuk_internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.can_configure_es_snapshots](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.domain_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.es_can_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.manual_snapshot_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.manual_snapshots_cross_account_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.opensearch_log_publishing_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [tfe_outputs.cluster_infrastructure](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/outputs) | data source |
| [tfe_outputs.logging](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/outputs) | data source |
| [tfe_outputs.root_dns](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/outputs) | data source |
| [tfe_outputs.security](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/outputs) | data source |
| [tfe_outputs.vpc](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/outputs) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"eu-west-1"` | no |
| <a name="input_dedicated_master"></a> [dedicated\_master](#input\_dedicated\_master) | Dedicated master settings, leave null to disable dedicated master | <pre>object({<br>    instance_count = number<br>    instance_type = string<br>  })</pre> | `null` | no |
| <a name="input_ebs"></a> [ebs](#input\_ebs) | EBS configuration, leave null to disable EBS | <pre>object({<br>    volume_size      = number<br>    volume_type      = string<br>    throughput       = number<br>    provisioned_iops = number<br>  })</pre> | `null` | no |
| <a name="input_elasticsearch6_manual_snapshot_bucket_arns"></a> [elasticsearch6\_manual\_snapshot\_bucket\_arns](#input\_elasticsearch6\_manual\_snapshot\_bucket\_arns) | A list of S3 Bucket ARNS that the manual snapshot role should be able to access | `list(string)` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The engine version of the opensearch cluster | `string` | n/a | yes |
| <a name="input_govuk_environment"></a> [govuk\_environment](#input\_govuk\_environment) | Acceptable values are test, integration, staging, production | `string` | n/a | yes |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | n/a | `number` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | n/a | `string` | n/a | yes |
| <a name="input_stackname"></a> [stackname](#input\_stackname) | Name of the stack, valid options are 'blue' and 'green' | `string` | n/a | yes |
| <a name="input_tls_security_policy"></a> [tls\_security\_policy](#input\_tls\_security\_policy) | The pre-canned AWS security policy to enforce for connections to opensearch | `string` | n/a | yes |
| <a name="input_zone_awareness_enabled"></a> [zone\_awareness\_enabled](#input\_zone\_awareness\_enabled) | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_configuration_policy_arn"></a> [domain\_configuration\_policy\_arn](#output\_domain\_configuration\_policy\_arn) | ARN of the policy used to configure the elasticsearch domain |
| <a name="output_manual_snapshots_bucket_arn"></a> [manual\_snapshots\_bucket\_arn](#output\_manual\_snapshots\_bucket\_arn) | ARN of the bucket to store manual snapshots |
| <a name="output_service_dns_name"></a> [service\_dns\_name](#output\_service\_dns\_name) | DNS name to access the Elasticsearch internal service |
| <a name="output_service_endpoint"></a> [service\_endpoint](#output\_service\_endpoint) | Endpoint to submit index, search, and upload requests |
