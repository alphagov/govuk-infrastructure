# Variables for the cluster-infrastructure-integration workspace

cluster_version = "1.34"

enable_container_network_observability = true
enable_eks_pod_identity_addon          = true
enable_network_flow_addon              = true

enable_arm_workers_blue  = false
enable_arm_workers_green = true
enable_x86_workers       = false

grafana_db_auto_pause       = true
rds_apply_immediately       = true
rds_backup_retention_period = 1
rds_skip_final_snapshot     = true

secrets_recovery_window_in_days = 0
