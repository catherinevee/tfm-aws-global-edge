# Basic Edge Network Services Example
# This example demonstrates a simple CloudFront distribution with WAF protection

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Basic Edge Network Services Module
module "edge_network_basic" {
  source = "../../"

  environment = "dev"
  project_name = "basic-example"

  # CloudFront Configuration
  cloudfront_origins = [
    {
      domain_name = "example-bucket.s3.amazonaws.com"
      origin_id   = "S3-Origin"
      s3_origin_config = {
        origin_access_identity = "origin-access-identity/cloudfront/E1234567890ABC"
      }
    }
  ]

  cloudfront_default_cache_behavior = {
    target_origin_id       = "S3-Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # WAF Configuration (enabled by default)
  enable_waf = true

  # Monitoring (enabled by default)
  enable_monitoring = true

  # Tags
  tags = {
    Environment = "development"
    Project     = "basic-example"
    Owner       = "devops-team"
    CostCenter  = "engineering"
  }
}

# Outputs
output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = module.edge_network_basic.cloudfront_distribution_domain_name
}

output "waf_web_acl_id" {
  description = "WAF Web ACL ID"
  value       = module.edge_network_basic.waf_web_acl_id
}

output "summary" {
  description = "Summary of created resources"
  value       = module.edge_network_basic.summary
} 