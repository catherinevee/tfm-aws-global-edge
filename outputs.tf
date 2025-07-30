# Edge Network Services Module Outputs
# This module provides comprehensive outputs for edge network services

# =============================================================================
# General Outputs
# =============================================================================

output "module_name" {
  description = "Name of the edge network module"
  value       = var.project_name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}

# =============================================================================
# ACM Certificate Outputs
# =============================================================================

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = var.enable_ssl_certificate && var.ssl_certificate_domain != null ? aws_acm_certificate.main[0].arn : null
}

output "acm_certificate_id" {
  description = "ID of the ACM certificate"
  value       = var.enable_ssl_certificate && var.ssl_certificate_domain != null ? aws_acm_certificate.main[0].id : null
}

output "acm_certificate_domain_name" {
  description = "Domain name of the ACM certificate"
  value       = var.enable_ssl_certificate && var.ssl_certificate_domain != null ? aws_acm_certificate.main[0].domain_name : null
}

output "acm_certificate_status" {
  description = "Status of the ACM certificate"
  value       = var.enable_ssl_certificate && var.ssl_certificate_domain != null ? aws_acm_certificate.main[0].status : null
}

output "acm_certificate_validation_method" {
  description = "Validation method of the ACM certificate"
  value       = var.enable_ssl_certificate && var.ssl_certificate_domain != null ? aws_acm_certificate.main[0].validation_method : null
}

output "acm_certificate_subject_alternative_names" {
  description = "Subject alternative names of the ACM certificate"
  value       = var.enable_ssl_certificate && var.ssl_certificate_domain != null ? aws_acm_certificate.main[0].subject_alternative_names : []
}

output "acm_certificate_validation_records" {
  description = "Validation records for the ACM certificate"
  value       = var.enable_ssl_certificate && var.ssl_certificate_domain != null && var.ssl_certificate_validation_method == "DNS" && var.enable_route53 ? aws_route53_record.certificate_validation : {}
}

output "acm_certificate_validation_status" {
  description = "Validation status of the ACM certificate"
  value       = var.enable_ssl_certificate && var.ssl_certificate_domain != null && var.ssl_certificate_validation_method == "DNS" && var.enable_route53 ? aws_acm_certificate_validation.main[0].certificate_arn : null
}

# =============================================================================
# CloudFront Outputs
# =============================================================================

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].id : null
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].arn : null
}

output "cloudfront_distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].domain_name : null
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "Hosted zone ID of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].hosted_zone_id : null
}

output "cloudfront_distribution_status" {
  description = "Status of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].status : null
}

output "cloudfront_distribution_etag" {
  description = "ETag of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].etag : null
}

output "cloudfront_distribution_last_modified_time" {
  description = "Last modified time of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].last_modified_time : null
}

output "cloudfront_distribution_in_progress_validation_batches" {
  description = "Number of in-progress validation batches for the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].in_progress_validation_batches : null
}

output "cloudfront_distribution_comment" {
  description = "Comment of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].comment : null
}

output "cloudfront_distribution_http_version" {
  description = "HTTP version of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].http_version : null
}

output "cloudfront_distribution_price_class" {
  description = "Price class of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].price_class : null
}

# =============================================================================
# WAF Outputs
# =============================================================================

output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].id : null
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].arn : null
}

output "waf_web_acl_name" {
  description = "Name of the WAF Web ACL"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].name : null
}

output "waf_web_acl_description" {
  description = "Description of the WAF Web ACL"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].description : null
}

output "waf_web_acl_capacity" {
  description = "Capacity of the WAF Web ACL"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].capacity : null
}

output "waf_web_acl_scope" {
  description = "Scope of the WAF Web ACL"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].scope : null
}

# =============================================================================
# Global Accelerator Outputs
# =============================================================================

output "global_accelerator_id" {
  description = "ID of the Global Accelerator"
  value       = var.enable_global_accelerator ? aws_globalaccelerator_accelerator.main[0].id : null
}

output "global_accelerator_arn" {
  description = "ARN of the Global Accelerator"
  value       = var.enable_global_accelerator ? aws_globalaccelerator_accelerator.main[0].arn : null
}

output "global_accelerator_name" {
  description = "Name of the Global Accelerator"
  value       = var.enable_global_accelerator ? aws_globalaccelerator_accelerator.main[0].name : null
}

output "global_accelerator_dns_name" {
  description = "DNS name of the Global Accelerator"
  value       = var.enable_global_accelerator ? aws_globalaccelerator_accelerator.main[0].dns_name : null
}

output "global_accelerator_hosted_zone_id" {
  description = "Hosted zone ID of the Global Accelerator"
  value       = var.enable_global_accelerator ? aws_globalaccelerator_accelerator.main[0].hosted_zone_id : null
}

output "global_accelerator_ip_sets" {
  description = "IP sets of the Global Accelerator"
  value       = var.enable_global_accelerator ? aws_globalaccelerator_accelerator.main[0].ip_sets : null
}

output "global_accelerator_enabled" {
  description = "Whether the Global Accelerator is enabled"
  value       = var.enable_global_accelerator ? aws_globalaccelerator_accelerator.main[0].enabled : null
}

output "global_accelerator_ip_address_type" {
  description = "IP address type of the Global Accelerator"
  value       = var.enable_global_accelerator ? aws_globalaccelerator_accelerator.main[0].ip_address_type : null
}

output "global_accelerator_listener_ids" {
  description = "IDs of the Global Accelerator listeners"
  value       = var.enable_global_accelerator ? aws_globalaccelerator_listener.main[*].id : []
}

output "global_accelerator_listener_arns" {
  description = "ARNs of the Global Accelerator listeners"
  value       = var.enable_global_accelerator ? aws_globalaccelerator_listener.main[*].arn : []
}

output "global_accelerator_endpoint_group_ids" {
  description = "IDs of the Global Accelerator endpoint groups"
  value       = var.enable_global_accelerator ? aws_globalaccelerator_endpoint_group.main[*].id : []
}

output "global_accelerator_endpoint_group_arns" {
  description = "ARNs of the Global Accelerator endpoint groups"
  value       = var.enable_global_accelerator ? aws_globalaccelerator_endpoint_group.main[*].arn : []
}

# =============================================================================
# Route 53 Outputs
# =============================================================================

output "route53_zone_id" {
  description = "ID of the Route 53 hosted zone"
  value       = var.enable_route53 && var.route53_domain_name != "" ? aws_route53_zone.main[0].zone_id : null
}

output "route53_zone_arn" {
  description = "ARN of the Route 53 hosted zone"
  value       = var.enable_route53 && var.route53_domain_name != "" ? aws_route53_zone.main[0].arn : null
}

output "route53_zone_name" {
  description = "Name of the Route 53 hosted zone"
  value       = var.enable_route53 && var.route53_domain_name != "" ? aws_route53_zone.main[0].name : null
}

output "route53_zone_name_servers" {
  description = "Name servers of the Route 53 hosted zone"
  value       = var.enable_route53 && var.route53_domain_name != "" ? aws_route53_zone.main[0].name_servers : []
}

output "route53_record_ids" {
  description = "IDs of the Route 53 records"
  value       = var.enable_route53 ? aws_route53_record.main[*].id : []
}

output "route53_record_names" {
  description = "Names of the Route 53 records"
  value       = var.enable_route53 ? aws_route53_record.main[*].name : []
}

output "route53_record_types" {
  description = "Types of the Route 53 records"
  value       = var.enable_route53 ? aws_route53_record.main[*].type : []
}

output "route53_health_check_ids" {
  description = "IDs of the Route 53 health checks"
  value       = var.enable_route53 ? aws_route53_health_check.main[*].id : []
}

output "route53_health_check_arns" {
  description = "ARNs of the Route 53 health checks"
  value       = var.enable_route53 ? aws_route53_health_check.main[*].arn : []
}

# =============================================================================
# Shield Outputs
# =============================================================================

output "shield_protection_id" {
  description = "ID of the Shield protection"
  value       = var.enable_shield && var.shield_protection_arn != null ? aws_shield_protection.main[0].id : null
}

output "shield_protection_arn" {
  description = "ARN of the Shield protection"
  value       = var.enable_shield && var.shield_protection_arn != null ? aws_shield_protection.main[0].resource_arn : null
}

output "shield_protection_name" {
  description = "Name of the Shield protection"
  value       = var.enable_shield && var.shield_protection_arn != null ? aws_shield_protection.main[0].name : null
}

# =============================================================================
# CloudWatch Alarms Outputs
# =============================================================================

output "cloudwatch_alarm_arns" {
  description = "ARNs of the CloudWatch alarms"
  value       = var.enable_monitoring ? aws_cloudwatch_metric_alarm.main[*].arn : []
}

output "cloudwatch_alarm_names" {
  description = "Names of the CloudWatch alarms"
  value       = var.enable_monitoring ? aws_cloudwatch_metric_alarm.main[*].alarm_name : []
}

output "cloudwatch_alarm_ids" {
  description = "IDs of the CloudWatch alarms"
  value       = var.enable_monitoring ? aws_cloudwatch_metric_alarm.main[*].id : []
}

# =============================================================================
# CloudFront Specific CloudWatch Alarms Outputs
# =============================================================================

output "cloudfront_4xx_errors_alarm_arn" {
  description = "ARN of the CloudFront 4xx errors alarm"
  value       = var.enable_monitoring && var.enable_cloudfront ? aws_cloudwatch_metric_alarm.cloudfront_4xx_errors[0].arn : null
}

output "cloudfront_5xx_errors_alarm_arn" {
  description = "ARN of the CloudFront 5xx errors alarm"
  value       = var.enable_monitoring && var.enable_cloudfront ? aws_cloudwatch_metric_alarm.cloudfront_5xx_errors[0].arn : null
}

output "cloudfront_cache_hit_ratio_alarm_arn" {
  description = "ARN of the CloudFront cache hit ratio alarm"
  value       = var.enable_monitoring && var.enable_cloudfront ? aws_cloudwatch_metric_alarm.cloudfront_cache_hit_ratio[0].arn : null
}

# =============================================================================
# Summary Outputs
# =============================================================================

output "summary" {
  description = "Summary of all created resources"
  value = {
    cloudfront_enabled     = var.enable_cloudfront
    waf_enabled           = var.enable_waf
    global_accelerator_enabled = var.enable_global_accelerator
    route53_enabled       = var.enable_route53
    shield_enabled        = var.enable_shield
    monitoring_enabled    = var.enable_monitoring
    ssl_certificate_enabled = var.enable_ssl_certificate
    total_resources_created = (
      (var.enable_cloudfront ? 1 : 0) +
      (var.enable_waf ? 1 : 0) +
      (var.enable_global_accelerator ? 1 : 0) +
      (var.enable_route53 && var.route53_domain_name != "" ? 1 : 0) +
      (var.enable_ssl_certificate && var.ssl_certificate_domain != null ? 1 : 0) +
      (var.enable_shield && var.shield_protection_arn != null ? 1 : 0) +
      (var.enable_monitoring ? length(var.cloudwatch_alarms) : 0) +
      (var.enable_monitoring && var.enable_cloudfront ? 3 : 0) +
      (var.enable_route53 ? length(var.route53_health_checks) : 0)
    )
  }
}

output "endpoints" {
  description = "All endpoint URLs and DNS names"
  value = {
    cloudfront_domain = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].domain_name : null
    global_accelerator_dns = var.enable_global_accelerator ? aws_globalaccelerator_accelerator.main[0].dns_name : null
    route53_zone_name = var.enable_route53 && var.route53_domain_name != "" ? aws_route53_zone.main[0].name : null
  }
}

output "configuration_summary" {
  description = "Summary of configuration parameters"
  value = {
    cloudfront_configuration = {
      enabled = var.enable_cloudfront
      price_class = var.cloudfront_price_class
      http_version = var.cloudfront_http_version
      ssl_support_method = var.cloudfront_ssl_support_method
      geo_restrictions = var.cloudfront_geo_restrictions
      custom_error_responses = var.cloudfront_custom_error_responses
    }
    waf_configuration = {
      enabled = var.enable_waf
      scope = var.waf_scope
      default_action = var.waf_default_action
      rules_count = length(var.waf_rules)
    }
    global_accelerator_configuration = {
      enabled = var.enable_global_accelerator
      ip_address_type = var.global_accelerator_ip_address_type
      listeners_count = length(var.global_accelerator_listeners)
      endpoint_groups_count = length(var.global_accelerator_endpoint_groups)
    }
    route53_configuration = {
      enabled = var.enable_route53
      domain_name = var.route53_domain_name
      records_count = length(var.route53_records)
      health_checks_count = length(var.route53_health_checks)
    }
    ssl_certificate_configuration = {
      enabled = var.enable_ssl_certificate
      domain = var.ssl_certificate_domain
      validation_method = var.ssl_certificate_validation_method
      subject_alternative_names_count = length(var.ssl_certificate_subject_alternative_names)
    }
    monitoring_configuration = {
      enabled = var.enable_monitoring
      alarms_count = length(var.cloudwatch_alarms)
      access_logs_enabled = var.enable_access_logs
    }
  }
} 