output "website_url" {
  description = "CaddNation URL"
  value       = aws_s3_bucket_website_configuration.caddnation_site.website_endpoint
}
