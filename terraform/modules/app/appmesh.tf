resource "aws_appmesh_virtual_service" "service" {
  count     = length(local.container_services)
  name      = "${local.container_services[count.index].container_service}.${var.service_discovery_namespace_name}"
  mesh_name = var.mesh_name

  spec {
    provider {
      virtual_node {
        virtual_node_name = aws_appmesh_virtual_node.service[count.index].name
      }
    }
  }
}

resource "aws_appmesh_virtual_node" "service" {
  count     = length(local.container_services)
  name      = local.container_services[count.index].container_service
  mesh_name = var.mesh_name

  spec {
    backend {
      virtual_service {
        virtual_service_name = "${local.container_services[count.index].container_service}.${var.service_discovery_namespace_name}"
      }
    }

    listener {
      port_mapping {
        port     = local.container_services[count.index].port
        protocol = local.container_services[count.index].protocol
      }
    }

    service_discovery {
      aws_cloud_map {
        namespace_name = var.service_discovery_namespace_name
        service_name   = aws_service_discovery_service.service[count.index].name
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

  depends_on = [aws_service_discovery_service.service]
}
