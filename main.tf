# Edge Network Services Module
# This module provides comprehensive edge network services for global architectures
# including CloudFront, Global Accelerator, Route 53, WAF, and monitoring

# =============================================================================
# Local Variables
# =============================================================================

locals {
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    Module      = "edge-network"
    ManagedBy   = "terraform"
  })

  name_prefix = "${var.project_name}-${var.environment}"
}

# =============================================================================
# ACM Certificate (if enabled)
# =============================================================================

resource "aws_acm_certificate" "main" {
  count = var.enable_ssl_certificate && var.ssl_certificate_domain != null ? 1 : 0

  domain_name               = var.ssl_certificate_domain
  subject_alternative_names = var.ssl_certificate_subject_alternative_names
  validation_method         = var.ssl_certificate_validation_method

  lifecycle {
    create_before_destroy = true
  }

  tags = local.common_tags
}

# =============================================================================
# Route 53 Hosted Zone (if enabled)
# =============================================================================

resource "aws_route53_zone" "main" {
  count = var.enable_route53 && var.route53_domain_name != "" ? 1 : 0

  name = var.route53_domain_name

  tags = local.common_tags
}

# =============================================================================
# WAF Web ACL
# =============================================================================

resource "aws_wafv2_web_acl" "main" {
  count = var.enable_waf ? 1 : 0

  name        = "${local.name_prefix}-${var.waf_name}"
  description = var.waf_description
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = var.waf_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action.type == "ALLOW" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action.type == "BLOCK" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action.type == "COUNT" ? [1] : []
          content {}
        }
      }

      dynamic "statement" {
        for_each = rule.value.statement != null ? [rule.value.statement] : []
        content {
          dynamic "managed_rule_group_statement" {
            for_each = statement.value.managed_rule_group_statement != null ? [statement.value.managed_rule_group_statement] : []
            content {
              name        = managed_rule_group_statement.value.name
              vendor_name = managed_rule_group_statement.value.vendor_name
            }
          }

          dynamic "rate_based_statement" {
            for_each = statement.value.rate_based_statement != null ? [statement.value.rate_based_statement] : []
            content {
              limit              = rate_based_statement.value.limit
              aggregate_key_type = rate_based_statement.value.aggregate_key_type
            }
          }

          dynamic "geo_match_statement" {
            for_each = statement.value.geo_match_statement != null ? [statement.value.geo_match_statement] : []
            content {
              country_codes = geo_match_statement.value.country_codes
            }
          }

          dynamic "ip_set_reference_statement" {
            for_each = statement.value.ip_set_reference_statement != null ? [statement.value.ip_set_reference_statement] : []
            content {
              arn = ip_set_reference_statement.value.arn
            }
          }

          dynamic "byte_match_statement" {
            for_each = statement.value.byte_match_statement != null ? [statement.value.byte_match_statement] : []
            content {
              search_string         = byte_match_statement.value.search_string
              positional_constraint = byte_match_statement.value.positional_constraint

              field_to_match {
                uri_path {}
              }

              text_transformation {
                priority = byte_match_statement.value.text_transformation.priority
                type     = byte_match_statement.value.text_transformation.type
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = rule.value.visibility_config.cloudwatch_metrics_enabled
        metric_name                = rule.value.visibility_config.metric_name
        sampled_requests_enabled   = rule.value.visibility_config.sampled_requests_enabled
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.waf_visibility_config.cloudwatch_metrics_enabled
    metric_name                = var.waf_visibility_config.metric_name
    sampled_requests_enabled   = var.waf_visibility_config.sampled_requests_enabled
  }

  tags = local.common_tags
}

# =============================================================================
# CloudFront Distribution
# =============================================================================

resource "aws_cloudfront_distribution" "main" {
  count = var.enable_cloudfront ? 1 : 0

  enabled             = var.cloudfront_enabled
  is_ipv6_enabled     = var.cloudfront_is_ipv6_enabled
  price_class         = var.cloudfront_price_class
  aliases             = var.cloudfront_aliases
  comment             = "Edge Network CloudFront Distribution for ${var.project_name}"

  # Origins
  dynamic "origin" {
    for_each = var.cloudfront_origins
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id
      origin_path = origin.value.origin_path

      dynamic "custom_origin_config" {
        for_each = origin.value.custom_origin_config != null ? [origin.value.custom_origin_config] : []
        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
        }
      }

      dynamic "s3_origin_config" {
        for_each = origin.value.s3_origin_config != null ? [origin.value.s3_origin_config] : []
        content {
          origin_access_identity = s3_origin_config.value.origin_access_identity
        }
      }

      dynamic "custom_header" {
        for_each = origin.value.custom_header
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }
    }
  }

  # Default cache behavior
  default_cache_behavior {
    target_origin_id       = var.cloudfront_default_cache_behavior.target_origin_id
    viewer_protocol_policy = var.cloudfront_default_cache_behavior.viewer_protocol_policy
    allowed_methods        = var.cloudfront_default_cache_behavior.allowed_methods
    cached_methods         = var.cloudfront_default_cache_behavior.cached_methods
    compress               = var.cloudfront_default_cache_behavior.compress
    min_ttl                = var.cloudfront_default_cache_behavior.min_ttl
    default_ttl            = var.cloudfront_default_cache_behavior.default_ttl
    max_ttl                = var.cloudfront_default_cache_behavior.max_ttl

    dynamic "forwarded_values" {
      for_each = var.cloudfront_default_cache_behavior.forwarded_values != null ? [var.cloudfront_default_cache_behavior.forwarded_values] : []
      content {
        query_string = forwarded_values.value.query_string
        headers      = forwarded_values.value.headers

        cookies {
          forward = forwarded_values.value.cookies.forward
        }
      }
    }

    cache_policy_id          = var.cloudfront_default_cache_behavior.cache_policy_id
    origin_request_policy_id = var.cloudfront_default_cache_behavior.origin_request_policy_id
  }

  # Ordered cache behaviors
  dynamic "ordered_cache_behavior" {
    for_each = var.cloudfront_ordered_cache_behaviors
    content {
      path_pattern     = ordered_cache_behavior.value.path_pattern
      target_origin_id = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy
      allowed_methods  = ordered_cache_behavior.value.allowed_methods
      cached_methods   = ordered_cache_behavior.value.cached_methods
      compress         = ordered_cache_behavior.value.compress
      min_ttl          = ordered_cache_behavior.value.min_ttl
      default_ttl      = ordered_cache_behavior.value.default_ttl
      max_ttl          = ordered_cache_behavior.value.max_ttl

      dynamic "forwarded_values" {
        for_each = ordered_cache_behavior.value.forwarded_values != null ? [ordered_cache_behavior.value.forwarded_values] : []
        content {
          query_string = forwarded_values.value.query_string
          headers      = forwarded_values.value.headers

          cookies {
            forward = forwarded_values.value.cookies.forward
          }
        }
      }

      cache_policy_id          = ordered_cache_behavior.value.cache_policy_id
      origin_request_policy_id = ordered_cache_behavior.value.origin_request_policy_id
    }
  }

  # Viewer certificate
  dynamic "viewer_certificate" {
    for_each = var.cloudfront_acm_certificate_arn != null ? [1] : []
    content {
      acm_certificate_arn      = var.cloudfront_acm_certificate_arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = var.cloudfront_minimum_protocol_version
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.cloudfront_acm_certificate_arn == null ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }

  # Logging configuration
  dynamic "logging_config" {
    for_each = var.enable_access_logs && var.access_logs_bucket != null ? [1] : []
    content {
      include_cookies = false
      bucket          = "${var.access_logs_bucket}.s3.amazonaws.com"
      prefix          = var.access_logs_prefix
    }
  }

  # WAF association
  dynamic "web_acl_id" {
    for_each = var.enable_waf ? [aws_wafv2_web_acl.main[0].arn] : []
    content {
      web_acl_id = web_acl_id.value
    }
  }

  # Custom error responses
  custom_error_response {
    error_code         = 404
    response_code      = "200"
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = "200"
    response_page_path = "/index.html"
  }

  tags = local.common_tags

  depends_on = [
    aws_wafv2_web_acl.main
  ]
}

# =============================================================================
# Global Accelerator
# =============================================================================

resource "aws_globalaccelerator_accelerator" "main" {
  count = var.enable_global_accelerator ? 1 : 0

  name            = "${local.name_prefix}-${var.global_accelerator_name}"
  ip_address_type = var.global_accelerator_ip_address_type
  enabled         = true

  attributes {
    flow_logs_enabled   = true
    flow_logs_s3_bucket = var.access_logs_bucket
    flow_logs_s3_prefix = "global-accelerator-logs"
  }

  tags = local.common_tags
}

resource "aws_globalaccelerator_listener" "main" {
  count = var.enable_global_accelerator ? length(var.global_accelerator_listeners) : 0

  accelerator_arn = aws_globalaccelerator_accelerator.main[0].id
  protocol        = var.global_accelerator_listeners[count.index].protocol

  dynamic "port_range" {
    for_each = var.global_accelerator_listeners[count.index].port_ranges
    content {
      from_port = port_range.value.from_port
      to_port   = port_range.value.to_port
    }
  }
}

resource "aws_globalaccelerator_endpoint_group" "main" {
  count = var.enable_global_accelerator ? length(var.global_accelerator_endpoint_groups) : 0

  listener_arn = var.global_accelerator_endpoint_groups[count.index].listener_arn
  region       = var.global_accelerator_endpoint_groups[count.index].region

  health_check_path                = var.global_accelerator_endpoint_groups[count.index].health_check_path
  health_check_protocol            = var.global_accelerator_endpoint_groups[count.index].health_check_protocol
  health_check_port                = var.global_accelerator_endpoint_groups[count.index].health_check_port
  health_check_interval_seconds    = var.global_accelerator_endpoint_groups[count.index].health_check_interval_seconds
  health_check_timeout_seconds     = var.global_accelerator_endpoint_groups[count.index].health_check_timeout_seconds
  healthy_threshold_count          = var.global_accelerator_endpoint_groups[count.index].healthy_threshold_count
  unhealthy_threshold_count        = var.global_accelerator_endpoint_groups[count.index].unhealthy_threshold_count
  traffic_dial_percentage          = var.global_accelerator_endpoint_groups[count.index].traffic_dial_percentage

  dynamic "endpoint_configuration" {
    for_each = var.global_accelerator_endpoint_groups[count.index].endpoint_configurations
    content {
      endpoint_id = endpoint_configuration.value.endpoint_id
      weight      = endpoint_configuration.value.weight
    }
  }
}

# =============================================================================
# Route 53 Records
# =============================================================================

resource "aws_route53_record" "main" {
  count = var.enable_route53 ? length(var.route53_records) : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.route53_records[count.index].name
  type    = var.route53_records[count.index].type
  ttl     = var.route53_records[count.index].ttl
  records = var.route53_records[count.index].records

  dynamic "alias" {
    for_each = var.route53_records[count.index].alias != null ? [var.route53_records[count.index].alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  dynamic "health_check_id" {
    for_each = var.route53_records[count.index].health_check_id != null ? [var.route53_records[count.index].health_check_id] : []
    content {
      health_check_id = health_check_id.value
    }
  }

  dynamic "failover_routing_policy" {
    for_each = var.route53_records[count.index].failover_routing_policy != null ? [var.route53_records[count.index].failover_routing_policy] : []
    content {
      type = failover_routing_policy.value.type
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = var.route53_records[count.index].geolocation_routing_policy != null ? [var.route53_records[count.index].geolocation_routing_policy] : []
    content {
      continent   = geolocation_routing_policy.value.continent
      country     = geolocation_routing_policy.value.country
      subdivision = geolocation_routing_policy.value.subdivision
    }
  }

  dynamic "latency_routing_policy" {
    for_each = var.route53_records[count.index].latency_routing_policy != null ? [var.route53_records[count.index].latency_routing_policy] : []
    content {
      region = latency_routing_policy.value.region
    }
  }

  dynamic "weighted_routing_policy" {
    for_each = var.route53_records[count.index].weighted_routing_policy != null ? [var.route53_records[count.index].weighted_routing_policy] : []
    content {
      weight = weighted_routing_policy.value.weight
    }
  }
}

# =============================================================================
# Shield Protection (if enabled)
# =============================================================================

resource "aws_shield_protection" "main" {
  count = var.enable_shield && var.shield_protection_arn != null ? 1 : 0

  name         = "${local.name_prefix}-shield-protection"
  resource_arn = var.shield_protection_arn

  tags = local.common_tags
}

# =============================================================================
# CloudWatch Alarms
# =============================================================================

resource "aws_cloudwatch_metric_alarm" "main" {
  count = var.enable_monitoring ? length(var.cloudwatch_alarms) : 0

  alarm_name          = var.cloudwatch_alarms[count.index].alarm_name
  comparison_operator = var.cloudwatch_alarms[count.index].comparison_operator
  evaluation_periods  = var.cloudwatch_alarms[count.index].evaluation_periods
  metric_name         = var.cloudwatch_alarms[count.index].metric_name
  namespace           = var.cloudwatch_alarms[count.index].namespace
  period              = var.cloudwatch_alarms[count.index].period
  statistic           = var.cloudwatch_alarms[count.index].statistic
  threshold           = var.cloudwatch_alarms[count.index].threshold
  alarm_description   = var.cloudwatch_alarms[count.index].alarm_description
  alarm_actions       = var.cloudwatch_alarms[count.index].alarm_actions
  ok_actions          = var.cloudwatch_alarms[count.index].ok_actions

  dynamic "dimensions" {
    for_each = var.cloudwatch_alarms[count.index].dimensions
    content {
      name  = dimensions.value.name
      value = dimensions.value.value
    }
  }

  tags = local.common_tags
}

# =============================================================================
# Default CloudWatch Alarms for CloudFront
# =============================================================================

resource "aws_cloudwatch_metric_alarm" "cloudfront_4xx_errors" {
  count = var.enable_monitoring && var.enable_cloudfront ? 1 : 0

  alarm_name          = "${local.name_prefix}-cloudfront-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "4xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300
  statistic           = "Average"
  threshold           = 5.0
  alarm_description   = "CloudFront 4xx error rate is high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = aws_cloudfront_distribution.main[0].id
    Region         = "Global"
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_5xx_errors" {
  count = var.enable_monitoring && var.enable_cloudfront ? 1 : 0

  alarm_name          = "${local.name_prefix}-cloudfront-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300
  statistic           = "Average"
  threshold           = 2.0
  alarm_description   = "CloudFront 5xx error rate is high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = aws_cloudfront_distribution.main[0].id
    Region         = "Global"
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_cache_hit_ratio" {
  count = var.enable_monitoring && var.enable_cloudfront ? 1 : 0

  alarm_name          = "${local.name_prefix}-cloudfront-cache-hit-ratio"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CacheHitRate"
  namespace           = "AWS/CloudFront"
  period              = 300
  statistic           = "Average"
  threshold           = 80.0
  alarm_description   = "CloudFront cache hit ratio is low"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = aws_cloudfront_distribution.main[0].id
    Region         = "Global"
  }

  tags = local.common_tags
} 