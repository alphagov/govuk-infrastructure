resource "helm_release" "inspektor_gadget" {
  count = var.enable_inspektor_gadget ? 1 : 0

  name       = "inspektor-gadget"
  repository = "https://inspektor-gadget.github.io/charts"
  chart      = "gadget"
  version    = "0.56.0"
  namespace  = "cluster-services"
  timeout    = var.helm_timeout_seconds
  values = [yamlencode({
    config = {
      eventsBufferLength = 32768
      gadgetConfigMaps = [
        {
          name      = "advise_network_policy"
          imageName = "ghcr.io/inspektor-gadget/gadget/advise_networkpolicy:latest"
        }
      ]
    }
  })]
}
