<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policy_scope"></a> [access\_policy\_scope](#input\_access\_policy\_scope) | Scope of the access policy. Either cluster or namespace. access\_policy\_namespaces is required if scope is namespace | `string` | n/a | yes |
| <a name="input_aws_iam_role_arns"></a> [aws\_iam\_role\_arns](#input\_aws\_iam\_role\_arns) | List of aws iam roles to create access policies with | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the access entry | `string` | n/a | yes |
| <a name="input_access_policy_arn"></a> [access\_policy\_arn](#input\_access\_policy\_arn) | ARN of the access policy to associate with this role (defaults to AmazonEKSViewPolicy) | `string` | `"arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"` | no |
| <a name="input_access_policy_namespaces"></a> [access\_policy\_namespaces](#input\_access\_policy\_namespaces) | List of namespaces to add to the access policy | `list(string)` | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | `"govuk"` | no |
| <a name="input_cluster_role_rules"></a> [cluster\_role\_rules](#input\_cluster\_role\_rules) | List of rules to apply to kubernetes cluster role resources | <pre>list(<br/>    object({<br/>      api_groups = list(string)<br/>      resources  = list(string)<br/>      verbs      = list(string)<br/>    })<br/>  )</pre> | `[]` | no |
| <a name="input_namespace_role_rules"></a> [namespace\_role\_rules](#input\_namespace\_role\_rules) | List of rules to apply to kubernetes namespace role resources | <pre>list(<br/>    object({<br/>      api_groups = list(string)<br/>      resources  = list(string)<br/>      verbs      = list(string)<br/>    })<br/>  )</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->