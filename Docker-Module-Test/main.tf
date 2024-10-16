terraform {
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
            version = "3.0.2"
        }
    }
}

module "image_creation" {
    source = "./modules/image_creation"
    image_name = "nginx:latest"
}

module "container_creation" {
    depends_on = [module.image_creation]
    source = "./modules/container_creation"
    container_name = "dev"
    image_name = module.image_creation.name
    internal_port = 80
    external_port = 8080
}

output "server_address" {
    value = "${module.container_creation.name} server: http://localhost:${module.container_creation.external_port}"
}
