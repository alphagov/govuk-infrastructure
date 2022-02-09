variable "govuk_aws_state_bucket" {
  type        = string
  description = "The name of the S3 bucket used for govuk-aws's Terraform state files."
}

variable "cluster_infrastructure_state_bucket" {
  type        = string
  description = "Name of the S3 bucket for the cluster-infrastructure module's Terraform state. Must match the name of the bucket specified in the backend config file."
}

variable "govuk_environment" {
  type        = string
  description = "GOV.UK environment where resources are being deployed"
}

variable "frontend_memcached_node_type" {
  type        = string
  description = "Instance type for the Frontend memcached."
}

variable "rabbitmq_subnets" {
  type        = map(object({ az = string, cidr = string }))
  description = "Map of {subnet_name: {az=<az>, cidr=<cidr>}} for the private subnets for the RabbitMQ broker."
}

variable "shared_redis_cluster_node_type" {
  type        = string
  description = "Instance type for the shared Redis cluster. t1 and t2 instances are not supported."
}
