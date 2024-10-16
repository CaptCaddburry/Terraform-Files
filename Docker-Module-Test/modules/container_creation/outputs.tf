output "name" {
    description = "Name for Container"
    value = docker_container.this.name
}

output "external_port" {
    description = "External Port of Container"
    value = docker_container.this.ports[0].external
}