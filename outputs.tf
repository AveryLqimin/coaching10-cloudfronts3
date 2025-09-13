output "bucket_name" {
  value = aws_s3_bucket.static.id
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.static.bucket_regional_domain_name
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.cdn.id
}

output "website_url" {
  description = "The CloudFront URL for the static website"
  value       = "https://${aws_cloudfront_distribution.cdn.domain_name}"
}

output "static_files_uploaded" {
  description = "Confirmation that static files have been uploaded"
  value       = "Static files from https://github.com/cloudacademy/static-website-example.git have been uploaded to S3"
}
