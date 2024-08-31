# Sets up the docker provider's version and source to download the API
#
terraform {
    required_providers {
        docker = {
            source                = "kreuzwerker/docker"
            version               = "3.0.2"
        }
    }
}

# --VARIABLES--
# These are a few variables used to connect the WordPress site and the MySQL database
#
variable "wordpress_host" {
    default                       = "{HOSTNAME}"
}

variable "wordpress_user" {
    default                       = "{USERNAME}"
}

variable "wordpress_password" {
    default                       = "{PASSWORD}"
}

variable "wordpress_external_port" {
    default                       = "8080"
}

# --IMAGES--
# The images are being pulled straight from Docker's main repository
#
resource "docker_image" "wordpress_image" {
    name                          = "wordpress"
}

resource "docker_image" "mysql_image" {
    name                          = "mysql"
}

# --VOLUMES--
# We are just declaring the volumes and giving them names
#
resource "docker_volume" "site_data" {}

resource "docker_volume" "db_data" {}

# --CONTAINERS--
#
resource "docker_container" "wordpress_app" {
    depends_on                    = [ docker_image.mysql_app ] # We need to wait for the MySQL database to be loaded before this works properly
    name                          = "wordpress_app"
    image                         = docker_image.wordpress_image.name # This calls the image that was created
    restart                       = "always"

    ports {
        internal                  = 80
        external                  = var.wordpress_external_port
    }

    env = [
        "WORDPRESS_DB_HOST        = mysql_app:3306", # This points directly to the MySQL database on the standard port
        "WORDPRESS_DB_PASSWORD    = ${var.wordpress_password}"
    ]

    mounts { # This is when we are actually storing data into the volumes
        type                      = "volume"
        target                    = "/var/www/html/"
        source                    = "site_data"
    }
}

resource "docker_container" "mysql_app" {
    name                          = "mysql_app"
    image                         = docker_image.mysql_image.name
    restart                       = "always"

    env = [
        "MYSQL_DATABASE           = ${var.wordpress_host}",
        "MYSQL_PASSWORD           = ${var.wordpress_password}",
        "MYSQL_USER               = ${var.wordpress_user}",
        "MYSQL_ROOT_PASSWORD      = ${var.wordpress_password}"
    ]

    mounts {
        type                      = "volume"
        target                    = "/var/lib/mysql/"
        source                    = "db_data"
    }
}

# --OUTPUTS--
# Once the apply is all finished, it will output the URL of the site
#
output "wordpress_url" {
    description                   = "WordPress URL"
    value                         = join(":", ["http://localhost", "${var.wordpress_external_port}"])
}
