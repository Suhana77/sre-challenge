resource "kubernetes_namespace" "sre-challenge" {
  metadata {
    annotations = {
      name = "sre-challenge"
    }

    labels = {
      mylabel = "sre-challenge"
    }

    name = "sre-challenge"
  }
}



resource "kubernetes_deployment" "node-api-deployment" {
  metadata {
    name = "node-api"
    namespace = "sre-challenge"
    labels = {
      App = "node-api"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "node-api"
      }
    }
    template {
      metadata {
        labels = {
          App = "node-api"
        }
      }
      spec {
        container {
          image = "suhanad14/node-api:latest"
          name  = "node-api"

          port {
            container_port = 3000
          }
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
          readiness_probe {
            http_get {
              path = "/"
              port =  3000
            }
            initial_delay_seconds = 30
            timeout_seconds = 10
            period_seconds = 10
            failure_threshold = 3
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 120
            timeout_seconds = 10
            period_seconds = 10
            failure_threshold = 3
          }
        }
      }
    }
  }
}


resource "kubernetes_service_v1" "node-api-service" {
  metadata {
    name      = "node-api-service"
    namespace = "sre-challenge"
    labels = {
      App = "node-api"
    }
  }

  spec {
    port {
      port = 3000
    }
    selector = {
      App = "node-api"
    }
  }
}




resource "kubernetes_horizontal_pod_autoscaler" "pod_scaler" {
 depends_on = [
    helm_release.prometheus
  ]

  metadata {
    name = "node-hpi"
    namespace = "sre-challenge"
  }

  spec {
    max_replicas = 10
    min_replicas = 2

    target_cpu_utilization_percentage = 50

    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "node-api"
    }
  }
}




resource "kubectl_manifest" "pod-monitor" {

  depends_on = [
    helm_release.prometheus
  ]

  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: node-api
  namespace: "sre-challenge"
  labels:
    App: "node-api"
    release: "kube-prometheus-stack"
spec:
  namespaceSelector:
    matchNames:
      - sre-challenge
  selector:
    matchLabels:
      App: "node-api"
  podMetricsEndpoints:
  - targetPort: 3000
    path: /metrics
    interval: 5s

YAML
}

