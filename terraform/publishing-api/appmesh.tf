resource "aws_appmesh_virtual_service" "service" {
  name      = "${var.service_name}.govuk.local"
  mesh_name = var.appmesh_mesh_govuk_id

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
  mesh_name = var.appmesh_mesh_govuk_id

  spec {
    backend {
      # The ECS service
      virtual_service {
        virtual_service_name = "${var.service_name}.govuk.local"
      }
    }

    listener {
      # Incoming traffic to the node
      port_mapping {
        port     = var.container_ingress_port
        protocol = "http"
      }
    }

    service_discovery {
      aws_cloud_map {
        namespace_name = var.govuk_publishing_platform_namespace_name
        service_name   = aws_service_discovery_service.service.name
      }
    }
  }

  depends_on = [aws_service_discovery_service.service]
}
