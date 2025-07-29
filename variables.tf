# Edge Network Services Module Variables
# This module provides comprehensive edge network services for global architectures

# =============================================================================
# General Configuration
# =============================================================================

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "edge-network"

  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 50
    error_message = "Project name must be between 1 and 50 characters."
  }
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : length(k) > 0 && length(v) > 0])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

# =============================================================================
# CloudFront Configuration
# =============================================================================

variable "enable_cloudfront" {
  description = "Enable CloudFront distribution"
  type        = bool
  default     = true
}

variable "cloudfront_origins" {
  description = "List of CloudFront origins"
  type = list(object({
    domain_name = string
    origin_id   = string
    origin_path = optional(string, "")
    custom_origin_config = optional(object({
      http_port              = number
      https_port             = number
      origin_protocol_policy = string
      origin_ssl_protocols   = list(string)
    }))
    s3_origin_config = optional(object({
      origin_access_identity = string
    }))
    custom_header = optional(list(object({
      name  = string
      value = string
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for origin in var.cloudfront_origins : 
      length(origin.domain_name) > 0 && length(origin.origin_id) > 0
    ])
    error_message = "All origins must have valid domain_name and origin_id."
  }
}

variable "cloudfront_default_cache_behavior" {
  description = "Default cache behavior for CloudFront"
  type = object({
    target_origin_id       = string
    viewer_protocol_policy = string
    allowed_methods        = list(string)
    cached_methods         = list(string)
    compress               = bool
    min_ttl                = number
    default_ttl            = number
    max_ttl                = number
    forwarded_values = optional(object({
      query_string = bool
      cookies = object({
        forward = string
      })
      headers = list(string)
    }))
    cache_policy_id = optional(string)
    origin_request_policy_id = optional(string)
  })
  default = {
    target_origin_id       = ""
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }
}

variable "cloudfront_ordered_cache_behaviors" {
  description = "Ordered cache behaviors for CloudFront"
  type = list(object({
    path_pattern     = string
    target_origin_id = string
    viewer_protocol_policy = string
    allowed_methods  = list(string)
    cached_methods   = list(string)
    compress         = bool
    min_ttl          = number
    default_ttl      = number
    max_ttl          = number
    forwarded_values = optional(object({
      query_string = bool
      cookies = object({
        forward = string
      })
      headers = list(string)
    }))
    cache_policy_id = optional(string)
    origin_request_policy_id = optional(string)
  }))
  default = []
}

variable "cloudfront_price_class" {
  description = "Price class for CloudFront distribution"
  type        = string
  default     = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.cloudfront_price_class)
    error_message = "Price class must be one of: PriceClass_100, PriceClass_200, PriceClass_All."
  }
}

variable "cloudfront_enabled" {
  description = "Whether the CloudFront distribution is enabled"
  type        = bool
  default     = true
}

variable "cloudfront_is_ipv6_enabled" {
  description = "Whether IPv6 is enabled for CloudFront distribution"
  type        = bool
  default     = true
}

variable "cloudfront_aliases" {
  description = "Extra CNAMEs (alternate domain names) for CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "cloudfront_acm_certificate_arn" {
  description = "ARN of ACM certificate for CloudFront distribution"
  type        = string
  default     = null
}

variable "cloudfront_minimum_protocol_version" {
  description = "Minimum protocol version for CloudFront distribution"
  type        = string
  default     = "TLSv1.2_2021"

  validation {
    condition = contains([
      "SSLv3", "TLSv1", "TLSv1_2016", "TLSv1.1_2016", "TLSv1.2_2018", "TLSv1.2_2019", "TLSv1.2_2021"
    ], var.cloudfront_minimum_protocol_version)
    error_message = "Invalid minimum protocol version."
  }
}

# =============================================================================
# Global Accelerator Configuration
# =============================================================================

variable "enable_global_accelerator" {
  description = "Enable AWS Global Accelerator"
  type        = bool
  default     = false
}

variable "global_accelerator_name" {
  description = "Name of the Global Accelerator"
  type        = string
  default     = "edge-accelerator"
}

variable "global_accelerator_ip_address_type" {
  description = "IP address type for Global Accelerator"
  type        = string
  default     = "IPV4"

  validation {
    condition     = contains(["IPV4", "DUAL_STACK"], var.global_accelerator_ip_address_type)
    error_message = "IP address type must be either IPV4 or DUAL_STACK."
  }
}

variable "global_accelerator_listeners" {
  description = "List of listeners for Global Accelerator"
  type = list(object({
    port_ranges = list(object({
      from_port = number
      to_port   = number
    }))
    protocol = string
  }))
  default = [
    {
      port_ranges = [
        {
          from_port = 80
          to_port   = 80
        }
      ]
      protocol = "TCP"
    }
  ]

  validation {
    condition = alltrue([
      for listener in var.global_accelerator_listeners :
      contains(["TCP", "UDP"], listener.protocol)
    ])
    error_message = "Protocol must be either TCP or UDP."
  }
}

variable "global_accelerator_endpoint_groups" {
  description = "List of endpoint groups for Global Accelerator"
  type = list(object({
    listener_arn = string
    region       = string
    endpoint_configurations = list(object({
      endpoint_id = string
      weight      = number
    }))
    health_check_path                = optional(string, "/")
    health_check_protocol            = optional(string, "HTTP")
    health_check_port                = optional(number, 80)
    health_check_interval_seconds    = optional(number, 30)
    health_check_timeout_seconds     = optional(number, 5)
    healthy_threshold_count          = optional(number, 3)
    unhealthy_threshold_count        = optional(number, 3)
    traffic_dial_percentage          = optional(number, 100)
  }))
  default = []
}

# =============================================================================
# Route 53 Configuration
# =============================================================================

variable "enable_route53" {
  description = "Enable Route 53 hosted zone and records"
  type        = bool
  default     = false
}

variable "route53_domain_name" {
  description = "Domain name for Route 53 hosted zone"
  type        = string
  default     = ""

  validation {
    condition     = var.route53_domain_name == "" || can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.[a-zA-Z]{2,}$", var.route53_domain_name))
    error_message = "Domain name must be a valid domain format."
  }
}

variable "route53_records" {
  description = "List of Route 53 records to create"
  type = list(object({
    name    = string
    type    = string
    ttl     = optional(number)
    records = optional(list(string))
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = bool
    }))
    health_check_id = optional(string)
    failover_routing_policy = optional(object({
      type = string
    }))
    geolocation_routing_policy = optional(object({
      continent   = optional(string)
      country     = optional(string)
      subdivision = optional(string)
    }))
    latency_routing_policy = optional(object({
      region = string
    }))
    weighted_routing_policy = optional(object({
      weight = number
    }))
  }))
  default = []
}

# =============================================================================
# WAF Configuration
# =============================================================================

variable "enable_waf" {
  description = "Enable WAF Web ACL"
  type        = bool
  default     = true
}

variable "waf_name" {
  description = "Name of the WAF Web ACL"
  type        = string
  default     = "edge-waf"
}

variable "waf_description" {
  description = "Description of the WAF Web ACL"
  type        = string
  default     = "WAF Web ACL for edge network services"
}

variable "waf_rules" {
  description = "List of WAF rules"
  type = list(object({
    name     = string
    priority = number
    action = object({
      type = string
    })
    statement = object({
      managed_rule_group_statement = optional(object({
        name        = string
        vendor_name = string
      }))
      rate_based_statement = optional(object({
        limit              = number
        aggregate_key_type = string
      }))
      geo_match_statement = optional(object({
        country_codes = list(string)
      }))
      ip_set_reference_statement = optional(object({
        arn = string
      }))
      byte_match_statement = optional(object({
        search_string         = string
        field_to_match        = object({
          uri_path = object({})
        })
        text_transformation = object({
          priority = number
          type     = string
        })
        positional_constraint = string
      }))
    })
    visibility_config = object({
      cloudwatch_metrics_enabled = bool
      metric_name                = string
      sampled_requests_enabled   = bool
    })
  }))
  default = [
    {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 1
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
        metric_name                = "AWSManagedRulesCommonRuleSetMetric"
        sampled_requests_enabled   = true
      }
    }
  ]
}

variable "waf_default_action" {
  description = "Default action for WAF Web ACL"
  type = object({
    allow = object({})
  })
  default = {
    allow = {}
  }
}

variable "waf_visibility_config" {
  description = "Visibility configuration for WAF Web ACL"
  type = object({
    cloudwatch_metrics_enabled = bool
    metric_name                = string
    sampled_requests_enabled   = bool
  })
  default = {
    cloudwatch_metrics_enabled = true
    metric_name                = "EdgeWAFMetric"
    sampled_requests_enabled   = true
  }
}

# =============================================================================
# Shield Configuration
# =============================================================================

variable "enable_shield" {
  description = "Enable AWS Shield Advanced protection"
  type        = bool
  default     = false
}

variable "shield_protection_arn" {
  description = "ARN of the resource to protect with Shield Advanced"
  type        = string
  default     = null
}

# =============================================================================
# Monitoring and Logging Configuration
# =============================================================================

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring and alarms"
  type        = bool
  default     = true
}

variable "enable_access_logs" {
  description = "Enable access logs for CloudFront"
  type        = bool
  default     = true
}

variable "access_logs_bucket" {
  description = "S3 bucket for CloudFront access logs"
  type        = string
  default     = null
}

variable "access_logs_prefix" {
  description = "Prefix for CloudFront access logs"
  type        = string
  default     = "cloudfront-logs"
}

variable "cloudwatch_alarms" {
  description = "List of CloudWatch alarms to create"
  type = list(object({
    alarm_name          = string
    comparison_operator = string
    evaluation_periods  = number
    metric_name         = string
    namespace           = string
    period              = number
    statistic           = string
    threshold           = number
    alarm_description   = string
    alarm_actions       = list(string)
    ok_actions          = list(string)
    dimensions = list(object({
      name  = string
      value = string
    }))
  }))
  default = []
}

# =============================================================================
# Security Configuration
# =============================================================================

variable "enable_ssl_certificate" {
  description = "Enable SSL certificate creation via ACM"
  type        = bool
  default     = false
}

variable "ssl_certificate_domain" {
  description = "Domain name for SSL certificate"
  type        = string
  default     = null
}

variable "ssl_certificate_validation_method" {
  description = "Validation method for SSL certificate"
  type        = string
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "EMAIL"], var.ssl_certificate_validation_method)
    error_message = "Validation method must be either DNS or EMAIL."
  }
}

variable "ssl_certificate_subject_alternative_names" {
  description = "Subject alternative names for SSL certificate"
  type        = list(string)
  default     = []
}

# =============================================================================
# Cost Optimization Configuration
# =============================================================================

variable "enable_cost_optimization" {
  description = "Enable cost optimization features"
  type        = bool
  default     = true
}

variable "cloudfront_compression" {
  description = "Enable compression for CloudFront"
  type        = bool
  default     = true
}

variable "cloudfront_price_class" {
  description = "Price class for CloudFront distribution"
  type        = string
  default     = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.cloudfront_price_class)
    error_message = "Price class must be one of: PriceClass_100, PriceClass_200, PriceClass_All."
  }
} 