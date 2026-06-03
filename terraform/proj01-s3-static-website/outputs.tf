output "site_url" {
  value = "https://${var.site_domain}"
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.static_website.domain_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.static_website.bucket
}
