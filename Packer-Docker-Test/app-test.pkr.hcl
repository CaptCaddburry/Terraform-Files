packer {
    required_plugins {
        docker = {
            version = ">= 1.0.8"
            source = "github.com/hashicorp/docker"
        }
    }
}

source "docker" "web-app" {
    build {
        path = "app/Dockerfile"
    }
    commit = true
}

build {
    name = "caddnation-test"
    sources = [
        "source.docker.web-app"
    ]

    post-processor "docker-tag" {
        repository = "caddnation-test"
        tags = ["latest"]
    }
}