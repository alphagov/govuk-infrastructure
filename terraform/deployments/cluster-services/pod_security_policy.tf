resource "helm_release" "pod_security_policy" {
  name       = "psp-baseline"
  chart      = "./cluster-security"
  count = length(var.psp_baseline_namespaces)
  namespace  = var.psp_baseline_namespaces[count.index] 
}