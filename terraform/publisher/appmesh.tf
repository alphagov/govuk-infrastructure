resource "aws_appmesh_virtual_service" "publisher" {
  name      = "${var.service_name}.govuk-publishing-platform"
  mesh_name = var.appmesh_mesh_govuk_id

  spec {
    provider {
      virtual_node {
        virtual_node_name = aws_appmesh_virtual_node.publisher.name
      }
    }
  }
}

resource "aws_appmesh_virtual_node" "publisher" {
  name      = var.service_name
  mesh_name = var.appmesh_mesh_govuk_id

  spec {
    backend {
      # The ECS service
      virtual_service {
        virtual_service_name = "${var.service_name}.govuk-publishing-platform"
      }
    }

    listener {
      # Incoming traffic to the node
      port_mapping {
        port     = 3000
        protocol = "http"
      }
    }

    service_discovery {
      aws_cloud_map {
        namespace_name = var.govuk_publishing_platform_namespace_name
        service_name   = aws_service_discovery_service.publisher.name
      }
    }
  }

  depends_on = [aws_service_discovery_service.publisher]
}
