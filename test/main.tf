# Test Configuration for Edge Network Services Module
# This configuration is used for testing the module with minimal resources

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

# Test Edge Network Services Module
module "edge_network_test" {
  source = "../"

  environment = "test"
  project_name = "test-edge-network"

  # Minimal CloudFront Configuration for Testing
  cloudfront_origins = [
    {
      domain_name = "test.example.com"
      origin_id   = "Test-Origin"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  ]

  cloudfront_default_cache_behavior = {
    target_origin_id       = "Test-Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Disable optional features for testing
  enable_waf = false
  enable_monitoring = false
  enable_global_accelerator = false
  enable_route53 = false
  enable_ssl_certificate = false
  enable_shield = false

  # Minimal tags for testing
  tags = {
    Environment = "test"
    Project     = "test-edge-network"
    Owner       = "test-team"
  }
}

# Test Outputs
output "test_cloudfront_domain" {
  description = "Test CloudFront distribution domain name"
  value       = module.edge_network_test.cloudfront_distribution_domain_name
}

output "test_summary" {
  description = "Test summary of created resources"
  value       = module.edge_network_test.summary
}

output "test_endpoints" {
  description = "Test endpoint URLs and DNS names"
  value       = module.edge_network_test.endpoints
} 