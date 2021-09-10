variable "govuk_aws_state_bucket" {
  type        = string
  description = "The name of the S3 bucket used for govuk-aws's Terraform state files."
}

variable "cluster_log_retention_in_days" {
  type        = number
  description = "Number of days to retain cluster log events in CloudWatch."
}

variable "cluster_name" {
  type        = string
  description = "Name for the EKS cluster."
  default     = "govuk"
}

variable "eks_control_plane_subnets" {
  type        = map(object({ az = string, cidr = string }))
  description = "Map of {subnet_name: {az=<az>, cidr=<cidr>}} for the public subnets for the EKS cluster's apiserver."
}

variable "eks_private_subnets" {
  type        = map(object({ az = string, cidr = string }))
  description = "Map of {subnet_name: {az=<az>, cidr=<cidr>}} for the private subnets for the EKS cluster's nodes and pods."
}

variable "eks_public_subnets" {
  type        = map(object({ az = string, cidr = string }))
  description = "Map of {subnet_name: {az=<az>, cidr=<cidr>}} for the public subnets where the EKS cluster will create Internet-facing load balancers."
}

variable "external_dns_subdomain" {
  type        = string
  description = "Subdomain name for a Route53 zone which will be created underneath external_root_zone (e.g. 'eks' to be created underneath staging.govuk.digital), for use by the external-dns addon. external-dns will create records for ALBs/NLBs created by Ingresses and Service[type=LoadBalancer] in this zone."
}

variable "publishing_service_domain" {
  type        = string
  description = "FQDN of the user-facing domain for the publishing apps, e.g. staging.publishing.gov.uk. This domain is included as a wildcard SAN on the TLS cert for Ingresses etc."
}

variable "force_destroy" {
  type        = bool
  description = "Setting for force_destroy on resources such as Route53 zones. For use in non-production environments to allow for automated tear-down."
  default     = false
}

variable "workers_instance_type" {
  type        = string
  description = "Instance type for the managed node group."
  default     = "m5.xlarge"
}

variable "workers_size_desired" {
  type        = number
  description = "Desired capacity of managed node autoscale group."
  default     = 6
}

variable "workers_size_min" {
  type        = number
  description = "Min capacity of managed node autoscale group."
  default     = 3
}

variable "workers_size_max" {
  type        = number
  description = "Max capacity of managed node autoscale group."
  default     = 9
}
