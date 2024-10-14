variable "aws_region" {
    description           = "AWS Region"
    type                  = string
    default               = "us-east-1"
}

variable "availability_zone" {
    description           = "Availability Zone"
    type                  = string
    default               = "us-east-1a"
}

variable "test_dev_ingress_rules" {
    type = list(object({
        from_port         = number
        to_port           = number
        protocol          = string
        cidr_block        = string
    }))
    default = [
        {
            from_port     = 22
            to_port       = 22
            protocol      = "tcp"
            cidr_block    = aws_subnet.test_dev_subnet.cidr_block
        },
        {
            from_port     = 80
            to_port       = 80
            protocol      = "tcp"
            cidr_block    = aws_subnet.test_dev_subnet.cidr_block
        },
        {
            from_port     = 443
            to_port       = 443
            protocol      = "tcp"
            cidr_block    = aws_subnet.test_dev_subnet.cidr_block
        }
    ]
}