# Advanced Edge Network Services Example
# This example demonstrates advanced features including multiple origins, custom cache behaviors, and enhanced security

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

# Advanced Edge Network Services Module
module "edge_network_advanced" {
  source = "../../"

  environment = "prod"
  project_name = "advanced-example"

  # CloudFront Configuration with Multiple Origins
  cloudfront_origins = [
    {
      domain_name = "static-content.s3.amazonaws.com"
      origin_id   = "S3-Static"
      s3_origin_config = {
        origin_access_identity = "origin-access-identity/cloudfront/E1234567890ABC"
      }
    },
    {
      domain_name = "api.example.com"
      origin_id   = "API-Origin"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2", "TLSv1.3"]
      }
      custom_header = [
        {
          name  = "X-API-Key"
          value = "your-api-key"
        }
      ]
    },
    {
      domain_name = "media.example.com"
      origin_id   = "Media-Origin"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2", "TLSv1.3"]
      }
    }
  ]

  # Default Cache Behavior
  cloudfront_default_cache_behavior = {
    target_origin_id       = "S3-Static"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  # Ordered Cache Behaviors for Different Content Types
  cloudfront_ordered_cache_behaviors = [
    {
      path_pattern     = "/api/*"
      target_origin_id = "API-Origin"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods  = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "DELETE"]
      cached_methods   = ["GET", "HEAD"]
      compress         = true
      min_ttl          = 0
      default_ttl      = 300
      max_ttl          = 3600
    },
    {
      path_pattern     = "/media/*"
      target_origin_id = "Media-Origin"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods  = ["GET", "HEAD"]
      cached_methods   = ["GET", "HEAD"]
      compress         = true
      min_ttl          = 0
      default_ttl      = 604800
      max_ttl          = 31536000
    },
    {
      path_pattern     = "/images/*"
      target_origin_id = "S3-Static"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods  = ["GET", "HEAD"]
      cached_methods   = ["GET", "HEAD"]
      compress         = true
      min_ttl          = 0
      default_ttl      = 2592000
      max_ttl          = 31536000
    }
  ]

  # Custom Domain Names
  cloudfront_aliases = ["www.example.com", "cdn.example.com"]

  # SSL Certificate
  enable_ssl_certificate = true
  ssl_certificate_domain = "example.com"
  ssl_certificate_subject_alternative_names = ["www.example.com", "cdn.example.com", "api.example.com"]

  # Enhanced WAF Configuration
  enable_waf = true
  waf_rules = [
    {
      name     = "RateLimit"
      priority = 1
      action = {
        type = "BLOCK"
      }
      statement = {
        rate_based_statement = {
          limit              = 2000
          aggregate_key_type = "IP"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "RateLimitMetric"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "GeoBlock"
      priority = 2
      action = {
        type = "BLOCK"
      }
      statement = {
        geo_match_statement = {
          country_codes = ["CN", "RU", "KP"]
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "GeoBlockMetric"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "SQLInjection"
      priority = 3
      action = {
        type = "BLOCK"
      }
      statement = {
        managed_rule_group_statement = {
          name        = "AWSManagedRulesSQLiRuleSet"
          vendor_name = "AWS"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "SQLInjectionMetric"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "CommonRuleSet"
      priority = 4
      action = {
        type = "ALLOW"
      }
      statement = {
        managed_rule_group_statement = {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "CommonRuleSetMetric"
        sampled_requests_enabled   = true
      }
    }
  ]

  # Enhanced Monitoring
  enable_monitoring = true
  cloudwatch_alarms = [
    {
      alarm_name          = "high-error-rate"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "5xxErrorRate"
      namespace           = "AWS/CloudFront"
      period              = 300
      statistic           = "Average"
      threshold           = 5.0
      alarm_description   = "High 5xx error rate detected"
      alarm_actions       = []
      ok_actions          = []
      dimensions = [
        {
          name  = "DistributionId"
          value = "E1234567890ABC"
        }
      ]
    },
    {
      alarm_name          = "high-latency"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 3
      metric_name         = "TotalErrorRate"
      namespace           = "AWS/CloudFront"
      period              = 300
      statistic           = "Average"
      threshold           = 10.0
      alarm_description   = "High latency detected"
      alarm_actions       = []
      ok_actions          = []
      dimensions = [
        {
          name  = "DistributionId"
          value = "E1234567890ABC"
        }
      ]
    }
  ]

  # Access Logging
  enable_access_logs = true
  access_logs_bucket = "edge-network-logs"
  access_logs_prefix = "cloudfront-logs/advanced-example"

  # Tags
  tags = {
    Environment = "production"
    Project     = "advanced-example"
    Owner       = "devops-team"
    CostCenter  = "engineering"
    DataClassification = "public"
  }
}

# Outputs
output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = module.edge_network_advanced.cloudfront_distribution_domain_name
}

output "cloudfront_aliases" {
  description = "CloudFront distribution aliases"
  value       = module.edge_network_advanced.cloudfront_distribution_domain_name
}

output "waf_web_acl_id" {
  description = "WAF Web ACL ID"
  value       = module.edge_network_advanced.waf_web_acl_id
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = module.edge_network_advanced.acm_certificate_arn
}

output "summary" {
  description = "Summary of created resources"
  value       = module.edge_network_advanced.summary
}

output "endpoints" {
  description = "All endpoint URLs and DNS names"
  value       = module.edge_network_advanced.endpoints
} 