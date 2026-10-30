// resource "helm_release" "cilium" {
//   chart = "cilium"
//   name  = "cilium"
// 
//   namespace  = "kube-system"
//   version    = "1.20.3"
//   repository = "https://helm.cilium.io/"
//   values = [yamlencode({
//     cni = {
//       exclusive    = false,
//       chainingMode = "aws-cni"
//     },
//     enableIPv4Masquerade = false,
//     routingMode          = "native",
//     hubble = {
//       enabled = true
//       relay = {
//         enabled = true
//       }
//       ui = {
//         enabled = true
//       }
//       export = {
//         static = {
//           enabled  = true
//           filePath = "/var/run/cilium/hubble/events.log"
//         }
//       }
//     }
//     affinity = {
//       podAntiAffinity = {
//         requiredDuringSchedulingIgnoredDuringExecution = [
//           {
//             topologyKey = "kubernetes.io/hostname"
//             labelSelector = {
//               matchExpressions = [
//                 {
//                   key      = "k8s-app"
//                   operator = "In"
//                   values   = ["cilium"]
//                 }
//               ]
//             }
//           }
//         ]
//       }
//       nodeAffinity = {
//         requiredDuringSchedulingIgnoredDuringExecution = {
//           nodeSelectorTerms = [
//             {
//               matchExpressions = [
//                 {
//                   key      = "cilium-disable"
//                   operator = "NotIn"
//                   values   = ["true"]
//                 }
//               ]
//             }
//           ]
//         }
//       }
//     }
//   })]
// }
