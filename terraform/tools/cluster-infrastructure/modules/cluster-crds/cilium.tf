locals {
  base_path = "https://raw.githubusercontent.com/cilium/cilium/refs/tags/${var.cilium_crd_version}/pkg/k8s/apis/cilium.io/client/crds"


  cilium_crd_yamls = {
    cilium_bgp_advertisements            = "${local.base_path}/v2/ciliumbgpadvertisements.yaml"
    cilium_bgp_cluster_configs           = "${local.base_path}/v2/ciliumbgpclusterconfigs.yaml"
    cilium_bgp_node_config_overrides     = "${local.base_path}/v2/ciliumbgpnodeconfigoverrides.yaml"
    cilium_bgp_node_configs              = "${local.base_path}/v2/ciliumbgpnodeconfigs.yaml"
    cilium_bgp_peer_configs              = "${local.base_path}/v2/ciliumbgppeerconfigs.yaml"
    cilium_cidr_groups                   = "${local.base_path}/v2/ciliumcidrgroups.yaml"
    cilium_cluster_wide_envoy_configs    = "${local.base_path}/v2/ciliumclusterwideenvoyconfigs.yaml"
    cilium_cluster_wide_network_policies = "${local.base_path}/v2/ciliumclusterwidenetworkpolicies.yaml"
    cilium_egress_gateway_policies       = "${local.base_path}/v2/ciliumegressgatewaypolicies.yaml"
    cilium_endpoints                     = "${local.base_path}/v2/ciliumendpoints.yaml"
    cilium_envoy_configs                 = "${local.base_path}/v2/ciliumenvoyconfigs.yaml"
    cilium_identities                    = "${local.base_path}/v2/ciliumidentities.yaml"
    cilium_load_balancer_ip_pools        = "${local.base_path}/v2/ciliumloadbalancerippools.yaml"
    cilium_local_redirect_policies       = "${local.base_path}/v2/ciliumlocalredirectpolicies.yaml"
    cilium_network_policies              = "${local.base_path}/v2/ciliumnetworkpolicies.yaml"
    cilium_node_configs                  = "${local.base_path}/v2/ciliumnodeconfigs.yaml"
    cilium_nodes                         = "${local.base_path}/v2/ciliumnodes.yaml"
    cilium_data_path_plugins             = "${local.base_path}/v2alpha1/ciliumdatapathplugins.yaml"
    cilium_endpoint_slices               = "${local.base_path}/v2alpha1/ciliumendpointslices.yaml"
    cilium_gateway_class_configs         = "${local.base_path}/v2alpha1/ciliumgatewayclassconfigs.yaml"
    cilium_l2_announcement_policies      = "${local.base_path}/v2alpha1/ciliuml2announcementpolicies.yaml"
    cilium_pod_ip_pools                  = "${local.base_path}/v2alpha1/ciliumpodippools.yaml"
  }
}

data "http" "cilium_crd_yamls" {
  for_each = local.cilium_crd_yamls
  url      = each.value
}

# Prometheus crd yaml pulled from kube-prometheus-stack helm chart.
# Update local variable `prometheus_operator_crd_version` to manage the crd version
resource "kubectl_manifest" "cilium_operator_crds" {
  server_side_apply = true
  for_each          = data.http.cilium_crd_yamls
  yaml_body         = each.value["response_body"]
}
