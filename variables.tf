variable "aws_region" {
  description = "AWS region for non-global resources. CloudFront is global."
  type        = string
  default     = "us-east-1"
}