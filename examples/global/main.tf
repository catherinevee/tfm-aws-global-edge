# Global Edge Network Services Example
# This example demonstrates a global architecture with Global Accelerator, Route 53, and multi-region setup

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

# Global Edge Network Services Module
module "edge_network_global" {
  source = "../../"

  environment = "prod"
  project_name = "global-example"

  # CloudFront Configuration
  cloudfront_origins = [
    {
      domain_name = "global-app.s3.amazonaws.com"
      origin_id   = "S3-Global"
      s3_origin_config = {
        origin_access_identity = "origin-access-identity/cloudfront/E1234567890ABC"
      }
    },
    {
      domain_name = "api.global-app.com"
      origin_id   = "API-Global"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2", "TLSv1.3"]
      }
    }
  ]

  cloudfront_default_cache_behavior = {
    target_origin_id       = "S3-Global"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  # Custom Domain Names
  cloudfront_aliases = ["www.global-app.com", "cdn.global-app.com"]

  # SSL Certificate
  enable_ssl_certificate = true
  ssl_certificate_domain = "global-app.com"
  ssl_certificate_subject_alternative_names = ["www.global-app.com", "cdn.global-app.com", "api.global-app.com"]

  # Global Accelerator Configuration
  enable_global_accelerator = true
  global_accelerator_name   = "global-app-accelerator"
  global_accelerator_ip_address_type = "DUAL_STACK"

  global_accelerator_listeners = [
    {
      port_ranges = [
        {
          from_port = 80
          to_port   = 80
        }
      ]
      protocol = "TCP"
    },
    {
      port_ranges = [
        {
          from_port = 443
          to_port   = 443
        }
      ]
      protocol = "TCP"
    }
  ]

  global_accelerator_endpoint_groups = [
    {
      listener_arn = "arn:aws:globalaccelerator::123456789012:accelerator/a1b2c3d4/listener/e5f6g7h8"
      region       = "us-east-1"
      endpoint_configurations = [
        {
          endpoint_id = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/global-alb-us-east-1/1234567890abcdef"
          weight      = 100
        }
      ]
      health_check_path                = "/health"
      health_check_protocol            = "HTTP"
      health_check_port                = 80
      health_check_interval_seconds    = 30
      health_check_timeout_seconds     = 5
      healthy_threshold_count          = 3
      unhealthy_threshold_count        = 3
      traffic_dial_percentage          = 100
    },
    {
      listener_arn = "arn:aws:globalaccelerator::123456789012:accelerator/a1b2c3d4/listener/e5f6g7h8"
      region       = "eu-west-1"
      endpoint_configurations = [
        {
          endpoint_id = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:loadbalancer/app/global-alb-eu-west-1/0987654321fedcba"
          weight      = 100
        }
      ]
      health_check_path                = "/health"
      health_check_protocol            = "HTTP"
      health_check_port                = 80
      health_check_interval_seconds    = 30
      health_check_timeout_seconds     = 5
      healthy_threshold_count          = 3
      unhealthy_threshold_count        = 3
      traffic_dial_percentage          = 100
    },
    {
      listener_arn = "arn:aws:globalaccelerator::123456789012:accelerator/a1b2c3d4/listener/e5f6g7h8"
      region       = "ap-southeast-1"
      endpoint_configurations = [
        {
          endpoint_id = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:loadbalancer/app/global-alb-ap-southeast-1/abcdef1234567890"
          weight      = 100
        }
      ]
      health_check_path                = "/health"
      health_check_protocol            = "HTTP"
      health_check_port                = 80
      health_check_interval_seconds    = 30
      health_check_timeout_seconds     = 5
      healthy_threshold_count          = 3
      unhealthy_threshold_count        = 3
      traffic_dial_percentage          = 100
    }
  ]

  # Route 53 Configuration
  enable_route53 = true
  route53_domain_name = "global-app.com"
  
  route53_records = [
    {
      name = "www.global-app.com"
      type = "A"
      alias = {
        name                   = "d1234abcd.cloudfront.net"
        zone_id                = "Z2FDTNDATAQYW2"
        evaluate_target_health = false
      }
    },
    {
      name = "api.global-app.com"
      type = "A"
      alias = {
        name                   = "a1234567890abcdef.awsglobalaccelerator.com"
        zone_id                = "Z2BJ6XQ5FK7U4H"
        evaluate_target_health = true
      }
    },
    {
      name = "cdn.global-app.com"
      type = "A"
      alias = {
        name                   = "d5678efgh.cloudfront.net"
        zone_id                = "Z2FDTNDATAQYW2"
        evaluate_target_health = false
      }
    }
  ]

  # Enhanced WAF Configuration for Global Protection
  enable_waf = true
  waf_rules = [
    {
      name     = "GlobalRateLimit"
      priority = 1
      action = {
        type = "BLOCK"
      }
      statement = {
        rate_based_statement = {
          limit              = 5000
          aggregate_key_type = "IP"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "GlobalRateLimitMetric"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "GlobalGeoBlock"
      priority = 2
      action = {
        type = "BLOCK"
      }
      statement = {
        geo_match_statement = {
          country_codes = ["CN", "RU", "KP", "IR"]
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "GlobalGeoBlockMetric"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "GlobalSecurityRules"
      priority = 3
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
        metric_name                = "GlobalSecurityRulesMetric"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "GlobalSQLInjection"
      priority = 4
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
        metric_name                = "GlobalSQLInjectionMetric"
        sampled_requests_enabled   = true
      }
    }
  ]

  # Enhanced Global Monitoring
  enable_monitoring = true
  cloudwatch_alarms = [
    {
      alarm_name          = "global-high-error-rate"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "5xxErrorRate"
      namespace           = "AWS/CloudFront"
      period              = 300
      statistic           = "Average"
      threshold           = 3.0
      alarm_description   = "Global high 5xx error rate detected"
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
      alarm_name          = "global-high-latency"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 3
      metric_name         = "TotalErrorRate"
      namespace           = "AWS/CloudFront"
      period              = 300
      statistic           = "Average"
      threshold           = 8.0
      alarm_description   = "Global high latency detected"
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
      alarm_name          = "global-cache-miss"
      comparison_operator = "LessThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CacheHitRate"
      namespace           = "AWS/CloudFront"
      period              = 300
      statistic           = "Average"
      threshold           = 85.0
      alarm_description   = "Global cache hit ratio is low"
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
  access_logs_bucket = "global-edge-network-logs"
  access_logs_prefix = "cloudfront-logs/global-example"

  # Tags
  tags = {
    Environment = "production"
    Project     = "global-example"
    Owner       = "devops-team"
    CostCenter  = "engineering"
    DataClassification = "public"
    GlobalDeployment = "true"
  }
}

# Outputs
output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = module.edge_network_global.cloudfront_distribution_domain_name
}

output "global_accelerator_dns" {
  description = "Global Accelerator DNS name"
  value       = module.edge_network_global.global_accelerator_dns_name
}

output "route53_zone_name_servers" {
  description = "Route 53 zone name servers"
  value       = module.edge_network_global.route53_zone_name_servers
}

output "waf_web_acl_id" {
  description = "WAF Web ACL ID"
  value       = module.edge_network_global.waf_web_acl_id
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = module.edge_network_global.acm_certificate_arn
}

output "summary" {
  description = "Summary of created resources"
  value       = module.edge_network_global.summary
}

output "endpoints" {
  description = "All endpoint URLs and DNS names"
  value       = module.edge_network_global.endpoints
}

output "global_accelerator_endpoints" {
  description = "Global Accelerator endpoint groups"
  value = {
    endpoint_group_ids = module.edge_network_global.global_accelerator_endpoint_group_ids
    endpoint_group_arns = module.edge_network_global.global_accelerator_endpoint_group_arns
  }
} 