resource "kubernetes_service_v1" "redis-service" {
  metadata {
    name      = "redis-service"
    namespace = "sre-challenge"
    labels = {
      app = "redis"
    }
  }

  spec {
    port {
      port = 6379
    }

    selector = {
      app = "redis"
    }
    cluster_ip = "None"
  }
}

resource "kubernetes_config_map_v1" "redis" {
  metadata {
    name      = "redis-ss-configuration"
    namespace = "sre-challenge"
    labels = {
      app = "redis"
    }
  }

  data = {
    "master.conf" = "${file("${path.module}/configmaps/master.conf")}"
    "init.sh" = "${file("${path.module}/scripts/init.sh")}"
    "slave.conf"  = <<EOF
        slaveof redis-ss-0.redis-service.sre-challenge 6379
        maxmemory 400mb
        maxmemory-policy allkeys-lru
        timeout 0
        dir /data
    EOF   
  }
}

resource "kubernetes_stateful_set_v1" "redis-ss" {
  metadata {
    name      = "redis-ss"
    namespace = "sre-challenge"
    annotations = {
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "redis"
      }
    }
    service_name = kubernetes_service_v1.redis-service.metadata.0.name

    template {
      metadata {
        labels = {
          app = "redis"
        }

        annotations = {
          "reloader.stakater.com/auto" = "true"
        }
      }

      spec {
        init_container {
          name              = "init-redis"
          image             = "redis:7.0.0"
          image_pull_policy = "IfNotPresent"
          command           = ["/bin/bash", "-c", "/mnt/init.sh" ]
          volume_mount {
            name       = "redis-claim"
            mount_path = "/etc"
          }
          volume_mount {
            name       = "config-map"
            mount_path = "/mnt/"
          }
        }

        container {
          name              = "redis"
          image             = "redis:7.0.0"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 6379
            name           = "redis-ss"
          }
          command = ["redis-server", "/etc/redis-config.conf"]

          volume_mount {
            name       = "redis-data"
            mount_path = "/data"
          }

          volume_mount {
            name       = "redis-claim"
            mount_path = "/etc"
          }
          resources {
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }

            requests = {
              cpu    = "0.5"
              memory = "100Mi"
            }
          }
        }
        volume {
          name = "config-map"
          config_map {
            name = kubernetes_config_map_v1.redis.metadata.0.name
            default_mode = "0700"

          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "redis-data"
      }
      spec {
        access_modes       = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "redis-claim"
      }
      spec {
        access_modes       = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }
  }
}