# modules/service-mesh-node defines a set of resources to register an
# ECS Service with App Mesh (as a virtual service) with virtual nodes (ECS Tasks)
# and CloudMap service discovery.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

resource "aws_appmesh_virtual_service" "service" {
  name      = "${var.service_name}.${var.service_discovery_namespace_name}"
  mesh_name = var.mesh_name

  spec {
    provider {
      virtual_node {
        virtual_node_name = aws_appmesh_virtual_node.service.name
      }
    }
  }
}

resource "aws_appmesh_virtual_node" "service" {
  name      = var.service_name
  mesh_name = var.mesh_name

  spec {
    backend {
      virtual_service {
        virtual_service_name = "${var.service_name}.${var.service_discovery_namespace_name}"
      }
    }

    listener {
      port_mapping {
        port     = var.port
        protocol = var.protocol
      }
    }

    service_discovery {
      aws_cloud_map {
        namespace_name = var.service_discovery_namespace_name
        service_name   = aws_service_discovery_service.service.name
      }
    }

    logging {
      access_log {
        file {
          path = "/dev/stdout"
        }
      }
    }
  }
}

resource "aws_service_discovery_service" "service" {
  name = var.service_name

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "WEIGHTED"
  }
}
