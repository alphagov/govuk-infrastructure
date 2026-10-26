# Variables for the cluster-infrastructure-production workspace

cluster_version = "1.36" # Don't forget to change this in variables-test.tf too

enable_container_network_observability = true
enable_eks_pod_identity_addon          = true
enable_network_flow_addon              = true

enable_arm_workers_blue  = false
enable_arm_workers_green = true
enable_x86_workers       = false

arm_workers_green_size_desired = 12
arm_workers_green_size_min     = 12
arm_workers_green_size_max     = 24
