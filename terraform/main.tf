terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = "app"
    labels = {
      Author = "Adam-L-Klein"
      Purpose = "Python-Flask-web-hit-counter"
    }
  }

  spec {
    replicas = 4
    selector {
      match_labels = {
        service = "app"
      }
    }

  strategy {
    type = "RollingUpdate"
      rolling_update {
        max_surge = "25%"
        max_unavailable = "25%"
      }
  }

    template {
      metadata {
        labels = {
          service = "app"
        }
      }

      spec {
        container {
          image = "alklein/alation_app:1.4.0"
          name  = "app"

          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }

            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 3
            success_threshold     = 1
            failure_threshold     = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "app"
  }
  spec {
    selector = {
      service = "app"
    }
    type = "ClusterIP"
    port {
      port = 8000
      target_port = 8000
      name = "8000"
    }
  }
}

resource "kubernetes_deployment" "proxy" {
  metadata {
    name = "proxy"
    labels = {
      Author = "Adam-L-Klein"
      Purpose = "Proxy-loadbalancer-for-python-web-counter"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        service = "proxy"
      }
    }

  strategy {
    type = "RollingUpdate"
      rolling_update {
        max_surge = 1
        max_unavailable = 0
      }
  }

    template {
      metadata {
        labels = {
          service = "proxy"
        }
      }

      spec {
        container {
          image = "alklein/alation_proxy:1.3.0"
          name  = "proxy"

          liveness_probe {
            http_get {
              scheme = "HTTP"
              path = "/health"
              port = 80
            }

            initial_delay_seconds = 7
            period_seconds        = 10
            timeout_seconds       = 3
            success_threshold     = 1
            failure_threshold     = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "proxy" {
  metadata {
    name      = "proxy"
  }
  spec {
    selector = {
        service = "proxy"
    }
    type = "LoadBalancer"
    port {
      port = 80
      target_port = 80
      name = "80"
    }
  }
}

resource "kubernetes_deployment" "redis" {
  metadata {
    name = "redis"
    labels = {
      Author = "Adam-L-Klein"
      Purpose = "Redis-db-for-python-hit-counter"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        service = "redis"
      }
    }

  strategy {
    type = "RollingUpdate"
      rolling_update {
        max_surge = 1
        max_unavailable = 0
      }
  }

    template {
      metadata {
        labels = {
          service = "redis"
        }
      }

      spec {
        container {
          image = "redis:alpine"
          name  = "redis"

          liveness_probe {
            tcp_socket {
              port = 6379
            }

            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 3
            success_threshold     = 1
            failure_threshold     = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "redis" {
  metadata {
    name      = "redis"
  }
  spec {
    selector = {
        service = "redis"
    }
    type = "ClusterIP"
    port {
      port = 6379
      target_port = 6379
      name = "6379"
    }
  }
}