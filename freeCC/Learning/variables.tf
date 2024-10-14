// This is stored as a variable to be used throughout the rest of my code
// The additional files don't need to be referenced in the other files, as long as they are stored in the same location, they will be run together

variable "aws_region" {
    description   = "AWS Region"
    type          = string
    default       = "us-east-1"
}