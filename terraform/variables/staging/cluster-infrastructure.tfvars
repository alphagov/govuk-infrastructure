# Variables for the cluster-infrastructure-staging workspace

cluster_version = "1.36"

enable_container_network_observability = true
enable_eks_pod_identity_addon          = true
enable_network_flow_addon              = true

enable_arm_workers_blue  = false
enable_arm_workers_green = true
enable_x86_workers       = false

use_bedrock_endpoints = true

rds_backup_retention_period = 1
