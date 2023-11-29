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

variable "cluster_version" {
  type        = string
  description = "Kubernetes release version for the cluster, e.g. 1.21"
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
  default     = "eks"
}

variable "publishing_service_domain" {
  type        = string
  description = "FQDN of the user-facing domain for the publishing apps, e.g. staging.publishing.service.gov.uk. This domain is included as a wildcard SAN on the TLS cert for Ingresses etc."
}

variable "force_destroy" {
  type        = bool
  description = "Setting for force_destroy on resources such as Route53 zones. For use in non-production environments to allow for automated tear-down."
  default     = false
}

variable "workers_instance_types" {
  type        = list(string)
  description = "List of instance types for the managed node group, in order of preference. The second and subsequent preferences are only relevant when using spot instances."
  default     = ["m6i.4xlarge", "m6a.4xlarge", "m6i.2xlarge", "m6a.2xlarge"]
}

variable "workers_default_capacity_type" {
  type        = string
  description = "Default capacity type for managed node groups: SPOT or ON_DEMAND."
  default     = "ON_DEMAND"
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
  default     = 12
}

variable "node_disk_size" {
  type        = number
  description = "Size in GB of the node default volume"
  default     = 60
}

variable "grafana_db_min_capacity" {
  type        = number
  description = "Minimum capacity of the Grafana RDS Aurora Serverless database."
  default     = 2
}

variable "grafana_db_max_capacity" {
  type        = number
  description = "Maximum capacity of the Grafana RDS Aurora Serverless database."
  default     = 8
}

variable "grafana_db_auto_pause" {
  type        = bool
  description = "Whether to auto-scale the Grafana RDS database to zero when it's idle. Takes 30s to start up again when traffic arrives. Best avoided in production."
  default     = false
}

variable "grafana_db_seconds_until_auto_pause" {
  type        = number
  description = "The timeout after which an idle Grafana RDS instance gets scaled down to zero, if grafana_db_auto_pause is true."
  default     = 7200
}

variable "rds_apply_immediately" {
  type        = bool
  description = "If true, apply changes to RDS instances immediately instead of scheduling them for the next maintenance window."
  default     = false
}

variable "rds_backup_retention_period" {
  type        = number
  description = "Backup retention period for Grafana config database, in days."
  default     = 7
}

variable "rds_skip_final_snapshot" {
  type        = bool
  description = "If true, allow deletion of RDS instances via Terraform by removing the requirement for a final snapshot to be taken on deletion. Do not enable this in production."
  default     = false
}

variable "secrets_recovery_window_in_days" {
  type        = number
  description = "Set to 0 in non-production environments to allow Terraform to delete and re-create secrets in AWS Secrets Manager."
  default     = 7
}

variable "govuk_environment" {
  type        = string
  description = "Acceptable values are test, integration, staging, production"
}
