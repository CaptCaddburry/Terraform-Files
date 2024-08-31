variable "aws_region" {
    description           = "AWS Region"
    type                  = string
    default               = "us-east-1"
}

variable "availability_zone" {
    description           = "AWS Availability Zone"
    type                  = string
    default               = "us-east-1a"
}

variable "test_ingress_rules" {
    type = list(object({
        port              = number
        protocol          = string
        cidr_blocks       = list(string)
    }))
    default = [
        {
            port          = 22
            protcol       = "tcp"
            cidr_blocks   = ["0.0.0.0/0"]
        },
        {
            port          = 80
            protcol       = "tcp"
            cidr_blocks   = ["0.0.0.0/0"]
        },
        {
            port          = 443
            protcol       = "tcp"
            cidr_blocks   = ["0.0.0.0/0"]
        }
    ]
}