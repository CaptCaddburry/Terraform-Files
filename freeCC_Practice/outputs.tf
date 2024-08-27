output "instance_public_ip" {
    description   = "Public IP Address"
    value         = aws_instance.test_prod_server.public_ip
}