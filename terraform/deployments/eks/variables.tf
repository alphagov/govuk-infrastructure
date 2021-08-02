variable "assume_role_arn" {
  type        = string
  description = "(optional) AWS IAM role to assume. Uses the role from the environment by default."
  default     = null
}

variable "govuk_aws_state_bucket" {
  type        = string
  description = "The name of the S3 bucket used for govuk-aws's terraform state files"
  default     = "govuk-terraform-steppingstone-test"
}

variable "external_domain" {
  type        = string
  description = "full domain where services will be accessible publicly"
  default     = "tmp.eks.test.govuk.digital"
}

variable "worker_node_instance_type" {
  type        = string
  description = "worker_node_instance_type"
  default     = "m5.4xlarge"
}

variable "desired_workers_size" {
  type        = number
  description = "desired number of worker nodes"
  default     = 1
}

#TODO: move default to variables file
variable "admin_roles" {
  description = "name of Additional IAM roles to add to the aws-auth configmap"
  type        = list(string)
  default = [
    "frederic.francois-admin",
    "william.franklin-admin",
    "roch.trinque-admin",
    "stephen.ford-admin",
    "karl.baker-admin",
    "chris.banks-admin",
    "nadeem.sabri-admin",
  ]
}
