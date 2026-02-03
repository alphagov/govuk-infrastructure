resource "helm_release" "falco" {
  name             = "flaco"
  repository       = "https://falcosecurity.github.io/charts/falcosecurity"
  chart            = "falco"
  version          = "8.0.0"
  namespace        = local.services_ns
  create_namespace = false

  values = [yamlencode({
    env = [
      {
        name  = "tty"
        value = true
      }
    ]
  })]
}

