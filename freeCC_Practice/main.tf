provider "aws" {
    region                      = var.aws_region
    shared_config_files         = [  ]
    shared_credentials_files    = [  ]
}

resource "aws_vpc" "test_prod_vpc" {
    cidr_block                  = "10.0.0.0/16"
}

resource "aws_internet_gateway" "test_prod_gateway" {
    vpc_id                      = aws_vpc.test_prod_vpc.id
}

resource "aws_route_table" "test_prod_rt" {
    vpc_id                      = aws_vpc.test_prod_vpc.id

    route {
        cidr_block              = "0.0.0.0/0"
        gateway_id              = aws_internet_gateway.test_prod_gateway.id
    }

    route {
        ipv6_cidr_block         = "::/0"
        gateway_id              = aws_internet_gateway.test_prod_gateway.id
    }
}

resource "aws_subnet" "test_prod_subnet" {
    vpc_id                      = aws_vpc.test_prod_vpc.id
    cidr_block                  = "10.0.1.0/24"
    availability_zone           = var.availability_zone
}

resource "aws_route_table_association" "test_deb_subrt" {
    subnet_id                   = aws_subnet.test_prod_subnet.id
    route_table_id              = aws_route_table.test_prod_rt.id
}

resource "aws_security_group" "test_prod_sec_group" {
    name                        = "allow_web_traffic"
    vpc_id                      = aws_vpc.test_prod_vpc.id
    dynamic "ingress" {
        for_each                = var.test_ingress_rules
        content {
            from_port           = ingress.value["port"]
            to_port             = ingress.value["port"]
            protocol            = ingress.value["protocol"]
            cidr_blocks         = ingress.value["cidr_blocks"]
        }
    }
    egress {
        from_port               = 0
        to_port                 = 0
        protocol                = "-1"
        cidr_blocks             = ["0.0.0.0/0"]
    }
}

resource "aws_network_interface" "test_prod_interface" {
    subnet_id                   = aws_subnet.test_prod_subnet.id
    private_ip                  = ["10.0.1.50"]
    security_groups             = [aws_security_group.test_prod_sec_group.id]
}

resource "aws_eip" "test_prod_server_eip" {
    instance                    = aws_instance.test_prod_server.id
    domain                      = "vpc"
    depends_on                  = [ aws_internet_gateway.test_prod_server ]
}

resource "aws_instance" "test_prod_server" {
    ami                         = data.aws_ami.ubuntu.id
    instance_type               = "t2.micro"
    availability_zone           = var.availability_zone
    key_name                    = "main_key"
    network_interface {
        network_interface_id    = aws_network_interface.test_prod_interface.id
        device_index            = 0
    }

    user_data                   = <<-EOL
        #!/bin/bash
        sudo apt update -y
        sudo apt install apache2 -y
        sudo systemctl enable apache2
        sudo systemctl start apache2
        sudo bash -c 'echo Test Prod Server Created > /var/www/html/index.html'
    EOL
}
