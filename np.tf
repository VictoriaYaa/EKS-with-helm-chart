resource "kubernetes_network_policy" "network_policy" {
  metadata {
    name      = "terraform-example-network-policy"
    namespace = kubernetes_namespace.vic-ns.metadata[0].name
  }

  spec {
    pod_selector {
      match_expressions {
        key      = "app.kubernetes.io/instance"
        operator = "In"
        values   = ["httpbin"]
      }
    }

    ingress {
      ports {
        port     = "http"
        protocol = "TCP"
      }
      ports {
        port     = "8125"
        protocol = "UDP"
      }

      from {
        namespace_selector {
          match_labels = {
            name = "vic-ns"
          }
        }
      }

      from {
        ip_block {
          cidr = "10.0.0.0/8"
          except = [
            "10.0.0.0/24",
            "10.0.1.0/24",
          ]
        }
      }
      from {
        ip_block {
          cidr = "94.0.0.0/8"
          except = [
            "94.10.0.0/24",
            "94.0.10.0/24",
          ]
        }
      }
    }

    egress {} 

    policy_types = ["Ingress", "Egress"]
  }
}