terraform {
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
            version = "3.6.2"
        }
    }
}

data "docker_image" "remote_image" {
    name = "${var.APP_NAME}:${var.VERSION}"
}

resource "docker_container" "caddnation-container" {
    name = "caddnation"
    image = data.docker_image.remote_image.name
    restart = "always"

    ports {
        internal = 80
        external = 80
    }
}

output "server_address" {
    description = "Web Address for container"
    value = "http://localhost:${docker_container.caddnation-container.ports[0].external}"
}