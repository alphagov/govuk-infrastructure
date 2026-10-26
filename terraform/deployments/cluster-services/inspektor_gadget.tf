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

      operator = {
        kubemanager = {
          "fallback-podinformer" = true
          "hook-mode" = "auto"
        }

        oci = {
           verify-image = true
           public-keys = [
           <<EOF
           -----BEGIN PUBLIC KEY-----
           MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEoDOC0gYSxZTopenGmX3ZFvQ1DSfh
           Ir4EKRt5jC+mXaJ7c7J+oREskYMn/SfZdRHNSOjLTZUMDm60zpXGhkFecg==
           -----END PUBLIC KEY-----
           EOF
           ]
           allowed-gadgets = ["advise_networkpolicy"]
           disallow-pulling  = false
           insecure-registries = []
        }
      }
    }
  })]
}
