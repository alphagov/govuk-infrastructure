current_live_domain = "blue"
launch_blue_domain  = true
launch_green_domain = false

blue_cluster_options = {
  engine         = "OpenSearch"
  engine_version = "3.1"
  instance_count = 3
  instance_type  = "t3.small.search"
  ebs_options = {
    volume_size = 90
    volume_type = "gp3"
    throughput  = 250
  }
}

aws_region = "eu-west-1"
