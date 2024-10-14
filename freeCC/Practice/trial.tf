/* Things to do in this Practice

1. Create VPC
2. Create Internet Gateway
3. Create Custom Route Table
4. Create Subnet
5. Associate Subnet with Route Table
6. Create Security Group to allow Ports 22, 80, 443
7. Create a Network Interface with an IP in the Subnet that was created in Step 4
8. Assign an Elastic IP to the Network Interface
9. Create Ubuntu Server and Install/Enable Apache2

*/

terraform {
    required_providers {
        aws = {
            source              = "hashicorp/aws"
            version             = "~> 5.0"
        }
    }
}

provider "aws" {
    region                      = var.aws_region
    shared_config_files         = ["PATH/TO/CONFIG/FILE"]
    shared_credentials_files    = ["PATH/TO/CREDENTIAL/FILE"]
}

resource "aws_vpc" "test_dev_vpc" {
    cidr_block                  = "10.0.0.0/16"
}

resource "aws_internet_gateway" "test_dev_gateway" {
    vpc_id                      = aws_vpc.test_dev_vpc.id
}

resource "aws_route_table" "test_dev_rt" {
    vpc_id                      = aws_vpc.test_dev_vpc.id

    route {
        cidr_block              = "10.0.1.0/24"
        gateway_id              = aws_internet_gateway.test_dev_gateway.id
    }
}

resource "aws_subnet" "test_dev_subnet" {
    vpc_id                      = aws_vpc.test_dev_vpc.id
    cidr_block                  = "10.0.1.0/26"
}

resource "aws_route_table_association" "test_dev_subrt" {
    subnet_id                   = aws_subnet.test_dev_subnet.id
    route_table_id              = aws_route_table.test_dev_rt.id
}

resource "aws_security_group" "test_dev_sec_group" {
    vpc_id                      = aws_vpc.test_dev_vpc.id
}

resource "aws_security_group_rule" "test_dev_ingress" {
    security_group_id           = aws_security_group.test_dev_sec_group.id
    count                       = length(var.test_dev_ingress_rules)

    type                        = "ingress"
    from_port                   = var.test_dev_ingress_rules[count.index].from_port
    to_port                     = var.test_dev_ingress_rules[count.index].to_port
    protocol                    = var.test_dev_ingress_rules[count.index].protocol
    cidr_blocks                 = [var.test_dev_ingress_rules[count.index].cidr_block]
}

resource "aws_security_group_rule" "test_dev_egress" {
    security_group_id           = aws_security_group.test_dev_sec_group.id
    
    type                        = "egress"
    from_port                   = 0
    to_port                     = 0
    protocol                    = "tcp"
    cidr_blocks                 = [ aws_subnet.test_dev_subnet.cidr_block ]
}

/* Potential Test for Ingress Rules
   All the ports have been stored in a variable as a list
   Hopefully, this should go through each port and create an ingress rule for them

resource "aws_security_group_rule" "test_dev_ingress" {
    security_group_id           = aws_security_group.test_dev_sec_group.id
    for_each                    = { for each in var.test_dev_ingress_rules : each.name => each}
    
    type                        = "ingress"
    from_port                   = each.value.from_port
    to_port                     = each.value.to_port
    protocol                    = each.value.protocol
    cidr_blocks                 = [each.value.cidr_block]
}
*/

/* Best Practice for Ingress/Egress Rules according to Documentation
   Each port should have it's own ingress/egress rule resource

resource "aws_vpc_security_group_ingress_rule" "test_dev_ingress22" {
    security_group_id           = aws_security_group.test_dev_sec_group.id

    cidr_ipv4                   = "10.0.0.0/16"
    from_port                   = 22
    to_port                     = 22
    ip_protocol                 = "tcp"
}
*/

resource "aws_network_interface" "test_dev_interface" {
    subnet_id                   = aws_subnet.test_dev_subnet.id
    private_ip                  = ["10.0.1.50"]
    security_groups             = [aws_security_group.test_dev_sec_group.id]
}

resource "aws_instance" "test_dev_server" {
    ami                         = data.aws_ami.ubuntu.id
    instance_type               = "t2.micro"
    security_groups             = [aws_security_group.test_dev_sec_group.id]
    network_interface {
        network_interface_id    = aws_network_interface.test_dev_interface.id
        device_index            = 0
    }

    user_data                   = <<-EOL
        #!/bin/bash
        sudo apt update -y
        sudo apt install apache2 -y
        sudo systemctl enable apache2
        sudo systemctl start apache2
    EOL
}