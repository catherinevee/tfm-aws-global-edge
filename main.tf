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
  certificate_authority_arn = var.ssl_certificate_authority_arn
  certificate_body          = var.ssl_certificate_body
  certificate_chain         = var.ssl_certificate_chain
  private_key               = var.ssl_certificate_private_key
  key_algorithm             = var.ssl_certificate_key_algorithm

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.common_tags,
    var.ssl_certificate_tags
  )
}

# Certificate validation records
resource "aws_route53_record" "certificate_validation" {
  for_each = var.enable_ssl_certificate && var.ssl_certificate_domain != null && var.ssl_certificate_validation_method == "DNS" && var.enable_route53 ? {
    for dvo in aws_acm_certificate.main[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main[0].zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "main" {
  count = var.enable_ssl_certificate && var.ssl_certificate_domain != null && var.ssl_certificate_validation_method == "DNS" && var.enable_route53 ? 1 : 0

  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]

  timeouts {
    create = var.ssl_certificate_validation_timeout
  }
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
  scope       = var.waf_scope

  # Default action
  dynamic "default_action" {
    for_each = [var.waf_default_action]
    content {
      dynamic "allow" {
        for_each = default_action.value.type == "ALLOW" ? [default_action.value] : []
        content {
          dynamic "custom_request_handling" {
            for_each = lookup(allow.value, "custom_request_handling", null) != null ? [allow.value.custom_request_handling] : []
            content {
              dynamic "insert_header" {
                for_each = custom_request_handling.value.insert_header
                content {
                  name  = insert_header.value.name
                  value = insert_header.value.value
                }
              }
            }
          }
        }
      }
      dynamic "block" {
        for_each = default_action.value.type == "BLOCK" ? [default_action.value] : []
        content {
          dynamic "custom_response" {
            for_each = lookup(block.value, "custom_response", null) != null ? [block.value.custom_response] : []
            content {
              response_code = custom_response.value.response_code
              dynamic "response_header" {
                for_each = lookup(custom_response.value, "response_header", [])
                content {
                  name  = response_header.value.name
                  value = response_header.value.value
                }
              }
              custom_response_body_key = lookup(custom_response.value, "custom_response_body_key", null)
            }
          }
        }
      }
    }
  }

  # Rules
  dynamic "rule" {
    for_each = var.waf_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      # Rule action
      dynamic "action" {
        for_each = [rule.value.action]
        content {
        dynamic "allow" {
            for_each = action.value.type == "ALLOW" ? [action.value] : []
            content {
              dynamic "custom_request_handling" {
                for_each = lookup(allow.value, "custom_request_handling", null) != null ? [allow.value.custom_request_handling] : []
                content {
                  dynamic "insert_header" {
                    for_each = custom_request_handling.value.insert_header
                    content {
                      name  = insert_header.value.name
                      value = insert_header.value.value
                    }
                  }
                }
              }
            }
        }
        dynamic "block" {
            for_each = action.value.type == "BLOCK" ? [action.value] : []
            content {
              dynamic "custom_response" {
                for_each = lookup(block.value, "custom_response", null) != null ? [block.value.custom_response] : []
                content {
                  response_code = custom_response.value.response_code
                  dynamic "response_header" {
                    for_each = lookup(custom_response.value, "response_header", [])
                    content {
                      name  = response_header.value.name
                      value = response_header.value.value
                    }
                  }
                  custom_response_body_key = lookup(custom_response.value, "custom_response_body_key", null)
                }
              }
            }
        }
        dynamic "count" {
            for_each = action.value.type == "COUNT" ? [action.value] : []
            content {
              dynamic "custom_request_handling" {
                for_each = lookup(count.value, "custom_request_handling", null) != null ? [count.value.custom_request_handling] : []
                content {
                  dynamic "insert_header" {
                    for_each = custom_request_handling.value.insert_header
                    content {
                      name  = insert_header.value.name
                      value = insert_header.value.value
                    }
                  }
                }
              }
            }
          }
        }
      }

      # Rule statement
      dynamic "statement" {
        for_each = rule.value.statement != null ? [rule.value.statement] : []
        content {
          # Managed rule group statement
          dynamic "managed_rule_group_statement" {
            for_each = statement.value.managed_rule_group_statement != null ? [statement.value.managed_rule_group_statement] : []
            content {
              name        = managed_rule_group_statement.value.name
              vendor_name = managed_rule_group_statement.value.vendor_name
              
              dynamic "rule_action_override" {
                for_each = lookup(managed_rule_group_statement.value, "rule_action_override", [])
                content {
                  name = rule_action_override.value.name
                  dynamic "action_to_use" {
                    for_each = [rule_action_override.value.action_to_use]
                    content {
                      dynamic "allow" {
                        for_each = action_to_use.value.type == "ALLOW" ? [action_to_use.value] : []
                        content {}
                      }
                      dynamic "block" {
                        for_each = action_to_use.value.type == "BLOCK" ? [action_to_use.value] : []
                        content {}
                      }
                      dynamic "count" {
                        for_each = action_to_use.value.type == "COUNT" ? [action_to_use.value] : []
                        content {}
                      }
                    }
                  }
                }
              }
            }
          }

          # Rate based statement
          dynamic "rate_based_statement" {
            for_each = statement.value.rate_based_statement != null ? [statement.value.rate_based_statement] : []
            content {
              limit              = rate_based_statement.value.limit
              aggregate_key_type = rate_based_statement.value.aggregate_key_type
              
              dynamic "custom_key" {
                for_each = lookup(rate_based_statement.value, "custom_key", null) != null ? [rate_based_statement.value.custom_key] : []
                content {
                  dynamic "header" {
                    for_each = lookup(custom_key.value, "header", null) != null ? [custom_key.value.header] : []
                    content {
                      name = header.value.name
                    }
                  }
                  dynamic "cookie" {
                    for_each = lookup(custom_key.value, "cookie", null) != null ? [custom_key.value.cookie] : []
                    content {
                      name = cookie.value.name
                    }
                  }
                  dynamic "query_string" {
                    for_each = lookup(custom_key.value, "query_string", null) != null ? [custom_key.value.query_string] : []
                    content {}
                  }
                  dynamic "uri_path" {
                    for_each = lookup(custom_key.value, "uri_path", null) != null ? [custom_key.value.uri_path] : []
                    content {}
                  }
                }
              }
            }
          }

          # Geo match statement
          dynamic "geo_match_statement" {
            for_each = statement.value.geo_match_statement != null ? [statement.value.geo_match_statement] : []
            content {
              country_codes = geo_match_statement.value.country_codes
            }
          }

          # IP set reference statement
          dynamic "ip_set_reference_statement" {
            for_each = statement.value.ip_set_reference_statement != null ? [statement.value.ip_set_reference_statement] : []
            content {
              arn = ip_set_reference_statement.value.arn
              ip_set_forwarded_ip_config {
                header_name                 = lookup(ip_set_reference_statement.value, "header_name", null)
                fallback_behavior          = lookup(ip_set_reference_statement.value, "fallback_behavior", "MATCH")
                position                   = lookup(ip_set_reference_statement.value, "position", "FIRST")
              }
            }
          }

          # Byte match statement
          dynamic "byte_match_statement" {
            for_each = statement.value.byte_match_statement != null ? [statement.value.byte_match_statement] : []
            content {
              search_string         = byte_match_statement.value.search_string
              positional_constraint = byte_match_statement.value.positional_constraint

              dynamic "field_to_match" {
                for_each = [byte_match_statement.value.field_to_match]
                content {
                  dynamic "uri_path" {
                    for_each = field_to_match.value.uri_path != null ? [field_to_match.value.uri_path] : []
                    content {}
                  }
                  dynamic "query_string" {
                    for_each = field_to_match.value.query_string != null ? [field_to_match.value.query_string] : []
                    content {}
                  }
                  dynamic "header" {
                    for_each = field_to_match.value.header != null ? [field_to_match.value.header] : []
                    content {
                      name = header.value.name
                    }
                  }
                  dynamic "method" {
                    for_each = field_to_match.value.method != null ? [field_to_match.value.method] : []
                    content {}
                  }
                  dynamic "body" {
                    for_each = field_to_match.value.body != null ? [field_to_match.value.body] : []
                    content {
                      oversize_handling = lookup(body.value, "oversize_handling", "CONTINUE")
                    }
                  }
                }
              }

                             dynamic "text_transformation" {
                 for_each = byte_match_statement.value.text_transformation != null ? byte_match_statement.value.text_transformation : []
                 content {
                   priority = text_transformation.value.priority
                   type     = text_transformation.value.type
                 }
               }
            }
          }

          # Size constraint statement
          dynamic "size_constraint_statement" {
            for_each = statement.value.size_constraint_statement != null ? [statement.value.size_constraint_statement] : []
            content {
              comparison_operator = size_constraint_statement.value.comparison_operator
              size                = size_constraint_statement.value.size

              dynamic "field_to_match" {
                for_each = [size_constraint_statement.value.field_to_match]
                content {
                  dynamic "uri_path" {
                    for_each = field_to_match.value.uri_path != null ? [field_to_match.value.uri_path] : []
                    content {}
                  }
                  dynamic "query_string" {
                    for_each = field_to_match.value.query_string != null ? [field_to_match.value.query_string] : []
                    content {}
                  }
                  dynamic "header" {
                    for_each = field_to_match.value.header != null ? [field_to_match.value.header] : []
                    content {
                      name = header.value.name
                    }
                  }
                  dynamic "method" {
                    for_each = field_to_match.value.method != null ? [field_to_match.value.method] : []
                    content {}
                  }
                  dynamic "body" {
                    for_each = field_to_match.value.body != null ? [field_to_match.value.body] : []
                    content {
                      oversize_handling = lookup(body.value, "oversize_handling", "CONTINUE")
                    }
                  }
                }
              }

                             dynamic "text_transformation" {
                 for_each = size_constraint_statement.value.text_transformation != null ? size_constraint_statement.value.text_transformation : []
                 content {
                   priority = text_transformation.value.priority
                   type     = text_transformation.value.type
                 }
               }
            }
          }

          # SQL injection match statement
          dynamic "sql_injection_match_statement" {
            for_each = statement.value.sql_injection_match_statement != null ? [statement.value.sql_injection_match_statement] : []
            content {
              dynamic "field_to_match" {
                for_each = [sql_injection_match_statement.value.field_to_match]
                content {
                  dynamic "uri_path" {
                    for_each = field_to_match.value.uri_path != null ? [field_to_match.value.uri_path] : []
                    content {}
                  }
                  dynamic "query_string" {
                    for_each = field_to_match.value.query_string != null ? [field_to_match.value.query_string] : []
                    content {}
                  }
                  dynamic "header" {
                    for_each = field_to_match.value.header != null ? [field_to_match.value.header] : []
                    content {
                      name = header.value.name
                    }
                  }
                  dynamic "method" {
                    for_each = field_to_match.value.method != null ? [field_to_match.value.method] : []
                    content {}
                  }
                  dynamic "body" {
                    for_each = field_to_match.value.body != null ? [field_to_match.value.body] : []
                    content {
                      oversize_handling = lookup(body.value, "oversize_handling", "CONTINUE")
                    }
                  }
                }
              }

                             dynamic "text_transformation" {
                 for_each = sql_injection_match_statement.value.text_transformation != null ? sql_injection_match_statement.value.text_transformation : []
                 content {
                   priority = text_transformation.value.priority
                   type     = text_transformation.value.type
                 }
               }
            }
          }

          # XSS match statement
          dynamic "xss_match_statement" {
            for_each = statement.value.xss_match_statement != null ? [statement.value.xss_match_statement] : []
            content {
              dynamic "field_to_match" {
                for_each = [xss_match_statement.value.field_to_match]
                content {
                  dynamic "uri_path" {
                    for_each = field_to_match.value.uri_path != null ? [field_to_match.value.uri_path] : []
                    content {}
                  }
                  dynamic "query_string" {
                    for_each = field_to_match.value.query_string != null ? [field_to_match.value.query_string] : []
                    content {}
                  }
                  dynamic "header" {
                    for_each = field_to_match.value.header != null ? [field_to_match.value.header] : []
                    content {
                      name = header.value.name
                    }
                  }
                  dynamic "method" {
                    for_each = field_to_match.value.method != null ? [field_to_match.value.method] : []
                    content {}
                  }
                  dynamic "body" {
                    for_each = field_to_match.value.body != null ? [field_to_match.value.body] : []
                    content {
                      oversize_handling = lookup(body.value, "oversize_handling", "CONTINUE")
                    }
                  }
                }
              }

                             dynamic "text_transformation" {
                 for_each = xss_match_statement.value.text_transformation != null ? xss_match_statement.value.text_transformation : []
                 content {
                   priority = text_transformation.value.priority
                   type     = text_transformation.value.type
                 }
               }
            }
          }

          # Regex pattern set reference statement
          dynamic "regex_pattern_set_reference_statement" {
            for_each = statement.value.regex_pattern_set_reference_statement != null ? [statement.value.regex_pattern_set_reference_statement] : []
            content {
              arn = regex_pattern_set_reference_statement.value.arn
              
              dynamic "field_to_match" {
                for_each = [regex_pattern_set_reference_statement.value.field_to_match]
                content {
                  dynamic "uri_path" {
                    for_each = field_to_match.value.uri_path != null ? [field_to_match.value.uri_path] : []
                    content {}
                  }
                  dynamic "query_string" {
                    for_each = field_to_match.value.query_string != null ? [field_to_match.value.query_string] : []
                    content {}
                  }
                  dynamic "header" {
                    for_each = field_to_match.value.header != null ? [field_to_match.value.header] : []
                    content {
                      name = header.value.name
                    }
                  }
                  dynamic "method" {
                    for_each = field_to_match.value.method != null ? [field_to_match.value.method] : []
                    content {}
                  }
                  dynamic "body" {
                    for_each = field_to_match.value.body != null ? [field_to_match.value.body] : []
                    content {
                      oversize_handling = lookup(body.value, "oversize_handling", "CONTINUE")
                    }
                  }
                }
              }

                             dynamic "text_transformation" {
                 for_each = regex_pattern_set_reference_statement.value.text_transformation != null ? regex_pattern_set_reference_statement.value.text_transformation : []
                 content {
                   priority = text_transformation.value.priority
                   type     = text_transformation.value.type
                 }
              }
            }
          }
        }
      }

      # Rule visibility config
      visibility_config {
        cloudwatch_metrics_enabled = rule.value.visibility_config.cloudwatch_metrics_enabled
        metric_name                = rule.value.visibility_config.metric_name
        sampled_requests_enabled   = rule.value.visibility_config.sampled_requests_enabled
      }
    }
  }

  # Custom response bodies
  dynamic "custom_response_body" {
    for_each = var.waf_custom_response_bodies
    content {
      key          = custom_response_body.value.key
      content_type = custom_response_body.value.content_type
      content      = custom_response_body.value.content
    }
  }

  # Visibility config
  visibility_config {
    cloudwatch_metrics_enabled = var.waf_visibility_config.cloudwatch_metrics_enabled
    metric_name                = var.waf_visibility_config.metric_name
    sampled_requests_enabled   = var.waf_visibility_config.sampled_requests_enabled
  }

  tags = merge(
    local.common_tags,
    var.waf_tags
  )
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
  comment             = var.cloudfront_comment
  default_root_object = var.cloudfront_default_root_object
  http_version        = var.cloudfront_http_version
  retain_on_delete    = var.cloudfront_retain_on_delete
  wait_for_deployment = var.cloudfront_wait_for_deployment

  # Origins
  dynamic "origin" {
    for_each = var.cloudfront_origins
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id
      origin_path = origin.value.origin_path
      origin_access_control_id = lookup(origin.value, "origin_access_control_id", null)

      dynamic "custom_origin_config" {
        for_each = origin.value.custom_origin_config != null ? [origin.value.custom_origin_config] : []
        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_read_timeout      = lookup(custom_origin_config.value, "origin_read_timeout", 30)
          origin_keepalive_timeout = lookup(custom_origin_config.value, "origin_keepalive_timeout", 5)
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

      dynamic "origin_shield" {
        for_each = origin.value.origin_shield != null ? [origin.value.origin_shield] : []
        content {
          enabled              = origin_shield.value.enabled
          origin_shield_region = origin_shield.value.origin_shield_region
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
    smooth_streaming       = lookup(var.cloudfront_default_cache_behavior, "smooth_streaming", false)
    trusted_signers        = lookup(var.cloudfront_default_cache_behavior, "trusted_signers", null)
    trusted_key_groups     = lookup(var.cloudfront_default_cache_behavior, "trusted_key_groups", null)

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
    realtime_log_config_arn  = lookup(var.cloudfront_default_cache_behavior, "realtime_log_config_arn", null)
    response_headers_policy_id = lookup(var.cloudfront_default_cache_behavior, "response_headers_policy_id", null)
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
      smooth_streaming = lookup(ordered_cache_behavior.value, "smooth_streaming", false)
      trusted_signers  = lookup(ordered_cache_behavior.value, "trusted_signers", null)
      trusted_key_groups = lookup(ordered_cache_behavior.value, "trusted_key_groups", null)

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
      realtime_log_config_arn  = lookup(ordered_cache_behavior.value, "realtime_log_config_arn", null)
      response_headers_policy_id = lookup(ordered_cache_behavior.value, "response_headers_policy_id", null)
    }
  }

  # Viewer certificate
  dynamic "viewer_certificate" {
    for_each = var.cloudfront_acm_certificate_arn != null ? [1] : []
    content {
      acm_certificate_arn      = var.cloudfront_acm_certificate_arn
      ssl_support_method       = var.cloudfront_ssl_support_method
      minimum_protocol_version = var.cloudfront_minimum_protocol_version
      cloudfront_default_certificate = false
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
      include_cookies = var.cloudfront_logging_include_cookies
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
  dynamic "custom_error_response" {
    for_each = var.cloudfront_custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
    }
  }

  # Geo restrictions
  dynamic "restrictions" {
    for_each = var.cloudfront_geo_restrictions != null ? [var.cloudfront_geo_restrictions] : []
    content {
      geo_restriction {
        restriction_type = restrictions.value.restriction_type
        locations        = lookup(restrictions.value, "locations", [])
      }
    }
  }

  # Default geo restrictions if none specified
  dynamic "restrictions" {
    for_each = var.cloudfront_geo_restrictions == null ? [1] : []
    content {
      geo_restriction {
        restriction_type = "none"
      }
    }
  }

  tags = merge(
    local.common_tags,
    var.cloudfront_tags
  )

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
  enabled         = var.global_accelerator_enabled

  # Enhanced attributes
  dynamic "attributes" {
    for_each = var.global_accelerator_attributes != null ? [var.global_accelerator_attributes] : []
    content {
      flow_logs_enabled   = attributes.value.flow_logs_enabled
      flow_logs_s3_bucket = attributes.value.flow_logs_s3_bucket
      flow_logs_s3_prefix = attributes.value.flow_logs_s3_prefix
    }
  }

  # Default attributes if none specified
  dynamic "attributes" {
    for_each = var.global_accelerator_attributes == null ? [1] : []
    content {
    flow_logs_enabled   = true
    flow_logs_s3_bucket = var.access_logs_bucket
    flow_logs_s3_prefix = "global-accelerator-logs"
    }
  }

  tags = merge(
    local.common_tags,
    var.global_accelerator_tags
  )
}

resource "aws_globalaccelerator_listener" "main" {
  count = var.enable_global_accelerator ? length(var.global_accelerator_listeners) : 0

  accelerator_arn = aws_globalaccelerator_accelerator.main[0].id
  protocol        = var.global_accelerator_listeners[count.index].protocol
  client_affinity = lookup(var.global_accelerator_listeners[count.index], "client_affinity", "NONE")

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

  health_check_path                = var.global_accelerator_endpoint_groups[count.index].health_check_path
  health_check_protocol            = var.global_accelerator_endpoint_groups[count.index].health_check_protocol
  health_check_port                = var.global_accelerator_endpoint_groups[count.index].health_check_port
  health_check_interval_seconds    = var.global_accelerator_endpoint_groups[count.index].health_check_interval_seconds
  traffic_dial_percentage          = var.global_accelerator_endpoint_groups[count.index].traffic_dial_percentage
  threshold_count                  = lookup(var.global_accelerator_endpoint_groups[count.index], "threshold_count", 3)

  dynamic "endpoint_configuration" {
    for_each = var.global_accelerator_endpoint_groups[count.index].endpoint_configurations
    content {
      endpoint_id = endpoint_configuration.value.endpoint_id
      weight      = endpoint_configuration.value.weight
      client_ip_preservation_enabled = lookup(endpoint_configuration.value, "client_ip_preservation_enabled", false)
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
  ttl     = lookup(var.route53_records[count.index], "ttl", null)
  records = lookup(var.route53_records[count.index], "records", null)
  set_identifier = lookup(var.route53_records[count.index], "set_identifier", null)

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
      continent   = lookup(geolocation_routing_policy.value, "continent", null)
      country     = lookup(geolocation_routing_policy.value, "country", null)
      subdivision = lookup(geolocation_routing_policy.value, "subdivision", null)
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

  dynamic "multivalue_answer_routing_policy" {
    for_each = var.route53_records[count.index].multivalue_answer_routing_policy != null ? [var.route53_records[count.index].multivalue_answer_routing_policy] : []
    content {
      multivalue_answer_routing_policy = true
    }
  }

  allow_overwrite = lookup(var.route53_records[count.index], "allow_overwrite", false)
}

# Route 53 Health Checks
resource "aws_route53_health_check" "main" {
  count = var.enable_route53 ? length(var.route53_health_checks) : 0

  fqdn              = lookup(var.route53_health_checks[count.index], "fqdn", null)
  port              = lookup(var.route53_health_checks[count.index], "port", null)
  type              = var.route53_health_checks[count.index].type
  resource_path     = lookup(var.route53_health_checks[count.index], "resource_path", null)
  failure_threshold = lookup(var.route53_health_checks[count.index], "failure_threshold", 3)
  request_interval  = lookup(var.route53_health_checks[count.index], "request_interval", 30)
  measure_latency   = lookup(var.route53_health_checks[count.index], "measure_latency", false)
  invert_healthcheck = lookup(var.route53_health_checks[count.index], "invert_healthcheck", false)

  child_healthchecks = lookup(var.route53_health_checks[count.index], "child_healthchecks", null)
  child_health_threshold = lookup(var.route53_health_checks[count.index], "child_health_threshold", null)
  cloudwatch_alarm_name = lookup(var.route53_health_checks[count.index], "cloudwatch_alarm_name", null)
  cloudwatch_alarm_region = lookup(var.route53_health_checks[count.index], "cloudwatch_alarm_region", null)
  insufficient_data_health_status = lookup(var.route53_health_checks[count.index], "insufficient_data_health_status", null)

  tags = merge(
    local.common_tags,
    lookup(var.route53_health_checks[count.index], "tags", {})
  )
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
  alarm_description   = lookup(var.cloudwatch_alarms[count.index], "alarm_description", null)
  alarm_actions       = lookup(var.cloudwatch_alarms[count.index], "alarm_actions", [])
  ok_actions          = lookup(var.cloudwatch_alarms[count.index], "ok_actions", [])
  insufficient_data_actions = lookup(var.cloudwatch_alarms[count.index], "insufficient_data_actions", [])
  treat_missing_data  = lookup(var.cloudwatch_alarms[count.index], "treat_missing_data", "missing")
  unit                = lookup(var.cloudwatch_alarms[count.index], "unit", null)
  extended_statistic  = lookup(var.cloudwatch_alarms[count.index], "extended_statistic", null)
  datapoints_to_alarm = lookup(var.cloudwatch_alarms[count.index], "datapoints_to_alarm", null)
  threshold_metric_id = lookup(var.cloudwatch_alarms[count.index], "threshold_metric_id", null)

  dynamic "dimensions" {
    for_each = lookup(var.cloudwatch_alarms[count.index], "dimensions", [])
    content {
      name  = dimensions.value.name
      value = dimensions.value.value
    }
  }

  dynamic "metric_query" {
    for_each = lookup(var.cloudwatch_alarms[count.index], "metric_query", [])
    content {
      id          = metric_query.value.id
      expression  = lookup(metric_query.value, "expression", null)
      label       = lookup(metric_query.value, "label", null)
      return_data = lookup(metric_query.value, "return_data", null)
      
      dynamic "metric" {
        for_each = lookup(metric_query.value, "metric", null) != null ? [metric_query.value.metric] : []
        content {
          dimensions = lookup(metric.value, "dimensions", [])
          metric_name = metric.value.metric_name
          namespace   = metric.value.namespace
          period      = metric.value.period
          stat        = metric.value.stat
          unit        = lookup(metric.value, "unit", null)
        }
      }
    }
  }

  tags = merge(
    local.common_tags,
    lookup(var.cloudwatch_alarms[count.index], "tags", {})
  )
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