terraform {
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
            version = "3.0.2"
        }
    }
}

# This variable is used to store the specs of each container that you want to create
# When you want to add in another container, just add another block in the default value
# 
variable "container_specs" {
    type = list(object({
        name = string
        image_name = string
        internal_port = number
        external_port = number
    }))
    default = [
        {
            name = "dev"
            image_name = "nginx:latest"
            internal_port = 80
            external_port = 8080
        },
        {
            name = "prod"
            image_name = "httpd:latest"
            internal_port = 80
            external_port = 8081
        }
    ]
}

# This resource will download each Docker image listed in the variable
#
resource "docker_image" "images" {
    count = length(var.container_specs)
    name = var.container_specs[count.index].image_name
}

# This resource will create each Docker container based on the images that you downloaded and the ports stated in the variable
#
resource "docker_container" "system_containers" {
    count = length(var.container_specs)
    name = var.container_specs[count.index].name
    image = docker_image.images[count.index].name

    ports = {
        internal = var.container_specs[count.index].internal_port
        external = var.container_specs[count.index].external_port
    }
}

# Once done, it will output the name of each server and the external port in the following format:
# test server: http://localhost:4000
#
output "servers" {
    value = [
        for each in var.container_specs : join(" ", ["${each.name} server:", join(":", ["http://localhost", each.external_port])])
    ]
}
