locals {
  collated_node_group_configs = {
    blue  = var.blue_node_group_config
    green = var.green_node_group_config
  }
}

resource "aws_launch_template" "this" {
  for_each = local.collated_node_group_configs

  name_prefix = "${var.environment_name}-${each.key}-"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = each.value.disk_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = true
  }

  update_default_version = true

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = each.key

    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = each.key

    }
  }

  tag_specifications {
    resource_type = "network-interface"

    tags = {
      Name = each.key
    }
  }
}

