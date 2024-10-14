output "server_public_ip" {
    value = aws_instance.test_ec2.public_ip
}

output "server_public_hostname" {
    value = aws_instance.test_ec2.public_dns
}