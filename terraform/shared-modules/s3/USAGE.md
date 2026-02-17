<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.owner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.https_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_combined_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AES256_encryption_configuration"></a> [AES256\_encryption\_configuration](#input\_AES256\_encryption\_configuration) | Whether to use AES256 as the algorithm for server side encryption. If false, the caller should set their own configuration | `bool` | `true` | no |
| <a name="input_extra_bucket_policies"></a> [extra\_bucket\_policies](#input\_extra\_bucket\_policies) | Extra bucket policies to apply to this bucket. List of json policies | `list(string)` | `[]` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | Bucket lifecycle rules and configuration see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration | <pre>list(object({<br/>    status = string<br/>    id     = string<br/>    abort_incomplete_multipart_upload = optional(object({<br/>      days_after_initiation = optional(number)<br/>    }))<br/>    expiration = optional(object({<br/>      date                         = optional(string)<br/>      days                         = optional(number)<br/>      expired_object_delete_number = optional(bool)<br/>    }))<br/>    filter = optional(object({<br/>      and = optional(object({<br/>        object_size_greater_than = optional(number)<br/>        object_size_less_than    = optional(number)<br/>        prefix                   = optional(string)<br/>        tags = optional(list(object({<br/>          key   = string<br/>          value = string<br/>        })))<br/><br/>      }))<br/>      object_size_greater_than = optional(number)<br/>      object_size_less_than    = optional(number)<br/>      prefix                   = optional(string)<br/>      tag = optional(object({<br/>        key   = string<br/>        value = string<br/>      }))<br/>    }))<br/>    noncurrent_version_expiration = optional(object({<br/>      noncurrent_days           = optional(number)<br/>      newer_noncurrent_versions = optional(number)<br/>    }))<br/>    noncurrent_version_transition = optional(object({<br/>      storage_class             = optional(string)<br/>      noncurrent_days           = optional(number)<br/>      newer_noncurrent_versions = optional(number)<br/>    }))<br/>    transition = optional(object({<br/>      date          = optional(string)<br/>      days          = optional(number)<br/>      storage_class = number<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The bucket and IAM policy name. NOTE: This must be a globally unique name for AWS S3 | `string` | n/a | yes |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Whether S3 bucket object versioning should be enabled | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_irsa_policy_arn"></a> [irsa\_policy\_arn](#output\_irsa\_policy\_arn) | IAM policy ARN for access to the S3 bucket |
| <a name="output_name"></a> [name](#output\_name) | n/a |
<!-- END_TF_DOCS -->