data "docker_image" "local_image" {
    name = "caddnation-test:latest"
}

resource "docker_container" "packer-test" {
    name = "packer-test"
    image = data.docker_image.local_image.name

    ports {
        internal = 8080
        external = 8080
    }
}