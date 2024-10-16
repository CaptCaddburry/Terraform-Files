variable "container_name" {
    description = "Name for Containers"
    type = string
}

variable "image_name" {
    description = "Name for Image"
    type = string
}

variable "internal_port" {
    description = "Internal Port for Container"
    type = number
}

variable "external_port" {
    description = "External Port for Container"
    type = number
}