terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
    shared_config_files = ["$HOME/.aws/config"]
    shared_credentials_files = ["$HOME/.aws/credentials"]
}

module "template_files" {
    source = "hashicorp/dir/template"
    base_dir = "${path.module}/web"
}

resource "aws_s3_bucket" "caddnation_bucket" {
    bucket = var.bucket_name

    tags = {
        Name = "CaddNation Site"
    }
}

resource "aws_s3_bucket_acl" "caddnation_bucket_acl" {
    bucket = aws_s3_bucket.caddnation_bucket.id
    acl = "public-read"
}

resource "aws_s3_bucket_policy" "caddnation_bucket_policy" {
    bucket = aws_s3_bucket.caddnation_bucket.id
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::${var.bucket_name}/*"
            }
        ]
    })
}

resource "aws_s3_bucket_website_configuration" "caddnation_site" {
    bucket = aws_s3_bucket.caddnation_bucket.id

    index_document {
        suffix = "index.html"
    }

    error_document {
        key = "404.html"
    }
}

resource "aws_s3_object" "caddnation_bucket_files" {
    bucket = aws_s3_bucket.caddnation_bucket.id

    for_each = module.template_files.files

    key = each.key
    content_type = each.value.content_type

    source = each.value.source_path
    content = each.value.content

    etag = each.value.digests.md5
}