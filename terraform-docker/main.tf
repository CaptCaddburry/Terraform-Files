terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

resource "docker_image" "nginx_image" {
  name         = "nginx"
}

resource "docker_container" "nginx" {
  image = docker_image.nginx_image.name
  name  = "nginx"

  ports {
    internal = 80
    external = 8000
  }
}
