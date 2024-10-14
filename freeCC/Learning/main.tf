// First and foremost, this file doesn't have to be named main.tf, it can be anything as long as it ends in the tf format

// The first thing we need to do define our provider
// Terraform uses riders, a plugin that allows us to talk to a specific set of APIs

provider "aws" {
    // version used to be handled in the provider block, but is now depreciated
    // version to be handled in the required_providers block, instead
    region                      = var.aws_region
    // instead of hard-coding in a region, it's best to store it in a variable that can be called here and everywhere else you need
    // access_key and secret_key can be declared in the provider block, but not very secure to hard code them into your script
    access_key                  = "{KEY}"
    secret_key                  = "{KEY}"
    // a better way of doing things is to use the shared_config_files and shared_credentials_files keys to connect safely
    shared_config_files         = [ "PATH/TO/CONFIG/FILE" ]
    shared_credentials_files    = [ "PATH/TO/CREDENTIAL/FILE" ]
}

/* To call a resource, it's the same format for every provider

resource <provider>_<resource_type> "defined_name" {
    config options
    key                         = "value"
    key2                        = "value2"
}

*/

// using the aws_instance resource_type, we can create a new EC2 in our AWS account
// using the datasource we created for the Ubuntu AMI, we can call that in the resource
// any tags declared are going to be just for organizational purposes on the AWS account

resource "aws_instance" "test_ec2" {
    ami                         = data.aws_ami.ubuntu.id
    instance_type               = "t2.micro"
    
    tags = {
        Name                    = "Test EC2"
    }
}

// when first running your project, run "terraform init" to initialize your provider
// once you initialize your code, run "terraform plan" to give you a breakdown of every change you are going to make
// once you are sure that the changes are correct, run "terraform apply" to make those changes

// terraform is declarative, meaning that everytime we run the code, it's only going to update the changes that we have made
// think of this terraform file as a blueprint for our infrastructure
// we aren't giving commands to run in a step by step basis, we are giving an entire overlook at what our infrastructure should incorporate

// if we want to remove our resources, run "terraform destroy" which will delete everything in the file by default
// instead of running a destroy, either comment out the resource or delete it, to keep everything else created

resource "aws_vpc" "test_prod_vpc" {
    cidr_block                  = "10.0.0.0/16"

    tags = {
        Name                    = "PRODUCTION"
    }
}

resource "aws_subnet" "test_prod_subnet" {
    vpc_id                      = aws_vpc.test_prod_vpc.id
    cidr_block                  = "10.0.1.0/24"

    tags = {
        Name                    = "PRODUCTION"
    }
}

// even though the VPC houses the subnet, it doesn't matter which order they are declared
// .terraform folder holds all the plugins from the providers when we run "terraform init"
// terraform.tfstate file holds all the information on all infrastructure that's been created with terraform
// DO NOT MESS WITH THE STATE FILE!!!!!

// to see all the resources that are currently deployed in the state, run "terraform state list"
// to see all detailed information about a specific resource that's deployed, run "terraform state show {RESOURCE}"
// when running this command, the name of the resource should be the full name as {<provider>_<resource_type>."defined_name"}
// Example: "terraform state show aws_subnet.test_prod_subnet"

// If you want to have certain information output when you run an apply, you can set up an output, I've gone ahead and added it to the output.tf file

// If you don't want to redeploy your resources with an apply, you can always run a "terraform refresh", which will refresh the state and list the outputs

// If you just want to re-obtain the outputs, you can run "terraform output"

// If you want to target just 1 resource with your commands, you can add the -target flag onto your command
// Example: "terraform delete -target aws_instance.test_ec2" will delete just the 1 EC2 instance
// Can even be used with apply

// When using variables in terraform and you don't assign a default value to them, terraform will ask you to enter your values when you first run your plan/apply
// You can also pass in a variable value while running your commands
// Example: "terraform apply -var 'aws_region=us-west-1'"
// But the single quotes should be double quotes when running, I just wanted them to show differently in my notes

// One common location that terraform looks for variable values is the terraform.tfvars file
// If you want to store variables in another .tfvars file, you can run "terraform apply -var-file {FILENAME}"
// Example: "terraform apply -var-file example.tfvars"
// I've been just putting variables in a separate variables.tf file in the same location, so everything has been fine, but I need to look up what the best practice is

