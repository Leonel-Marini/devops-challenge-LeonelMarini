terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Namespace para el proyecto
resource "kubernetes_namespace" "devops-challenge" {
  metadata {
    name = "devops-challenge"
  }
}

# Redis deployment
resource "kubernetes_deployment" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.devops-challenge.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {
        container {
          image = "redis:7-alpine"
          name  = "redis"

          port {
            container_port = 6379
          }
        }
      }
    }
  }
}

# Redis service
resource "kubernetes_service" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.devops-challenge.metadata[0].name
  }

  spec {
    selector = {
      app = "redis"
    }

    port {
      port        = 6379
      target_port = 6379
    }

    type = "ClusterIP"
  }
}

# Nginx deployment
resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx-app"
    namespace = kubernetes_namespace.devops-challenge.metadata[0].name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "nginx-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx-app"
        }
      }

      spec {
        container {
          image = "nginx-app:local"
          name  = "nginx"
          
          image_pull_policy = "Never"  # Para usar imagen local

          port {
            container_port = 80
          }

          env {
            name  = "REDIS_HOST"
            value = "redis"
          }

          env {
            name  = "REDIS_PORT"
            value = "6379"
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
      }
    }
  }
}

# Nginx service
resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx-service"
    namespace = kubernetes_namespace.devops-challenge.metadata[0].name
  }

  spec {
    selector = {
      app = "nginx-app"
    }

    port {
      port        = 80
      target_port = 80
      node_port   = 30080
    }

    type = "NodePort"
  }
}

# Storage bucket simulado (PersistentVolume)
resource "kubernetes_persistent_volume" "storage_bucket" {
  metadata {
    name = "storage-bucket"
  }
  
  spec {
    capacity = {
      storage = "1Gi"
    }
    
    access_modes = ["ReadWriteOnce"]
    
    persistent_volume_source {
      host_path {
        path = "/tmp/storage-bucket"
        type = "DirectoryOrCreate"
      }
    }
  }
}
