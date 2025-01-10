output "server_address" {
    description = "Web Address for container"
    value = "http://localhost:${docker_container.packer-test.ports[0].external}"
}