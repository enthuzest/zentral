resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = var.agent_name
    namespace = var.namespace
  }

  spec {
    replicas = var.agent_count

    selector {
      match_labels = {
        app = var.agent_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.agent_name
        }
      }

      spec {
        automount_service_account_token = false

        container {
          image             = var.container_image
          name              = var.agent_name
          image_pull_policy = "Always"
          env {
            name  = "AZP_URL"
            value = var.azp_url
          }
          env {
            name  = "AZP_TOKEN"
            value = var.azp_token
          }
          env {
            name  = "AZP_POOL"
            value = var.azp_pool
          }

          dynamic "env" {
            for_each = var.env
            content {
              name  = env.value.name
              value = env.value.value
            }
          }

          resources {
            requests = {
              cpu    = "200m"
              memory = "128Mi"
            }

            limits = {
              cpu    = "400m"
              memory = "1024Mi"
            }
          }

        }

        node_name = var.node_name
      }
    }
  }
  timeouts {
    create = "20m"
  }
}

resource "kubernetes_namespace" "main" {
  metadata {
    name = var.namespace
  }
}

# resource "kubernetes_horizontal_pod_autoscaler" "autoscaler" {
#   metadata {
#     name      = "pod-hpa"
#     namespace = var.namespace
#   }

#   spec {
#     scale_target_ref {
#       kind       = "Deployment"
#       name       = kubernetes_deployment.deployment.metadata[0].name
#       api_version = "apps/v1"
#     }

#     min_replicas = 1
#     max_replicas = 4
#     target_cpu_utilization_percentage = 50
#   }
# }