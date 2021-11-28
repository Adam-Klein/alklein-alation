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
    type = RollingUpdate
    rollingUpdate {
      maxSurge = 25%
      maxUnavailable = 25%
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
          image = "alklein/alation_app"
          name  = "app"

          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }

            initial_delay_seconds = 3
            period_seconds        = 3
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
    type = RollingUpdate
    rollingUpdate {
      maxSurge = 1
      maxUnavailable = 0
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
          image = "alklein/alation_proxy"
          name  = "proxy"
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
    type = RollingUpdate
    rollingUpdate {
      maxSurge = 1
      maxUnavailable = 0
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