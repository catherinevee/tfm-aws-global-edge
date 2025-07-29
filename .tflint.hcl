plugin "aws" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

config {
  module = true
  force  = false
}

# AWS Provider Configuration
rule "aws_provider_missing_region" {
  enabled = true
}

rule "aws_resource_missing_tags" {
  enabled = true
  tags = [
    "Environment",
    "Project",
    "Owner"
  ]
}

rule "aws_resource_invalid_name" {
  enabled = true
}

# CloudFront Rules
rule "aws_cloudfront_distribution_invalid_price_class" {
  enabled = true
}

rule "aws_cloudfront_distribution_invalid_viewer_protocol_policy" {
  enabled = true
}

# WAF Rules
rule "aws_wafv2_web_acl_invalid_scope" {
  enabled = true
}

rule "aws_wafv2_web_acl_invalid_name" {
  enabled = true
}

# Route 53 Rules
rule "aws_route53_record_invalid_type" {
  enabled = true
}

rule "aws_route53_zone_invalid_name" {
  enabled = true
}

# Global Accelerator Rules
rule "aws_globalaccelerator_accelerator_invalid_ip_address_type" {
  enabled = true
}

rule "aws_globalaccelerator_listener_invalid_protocol" {
  enabled = true
}

# ACM Rules
rule "aws_acm_certificate_invalid_validation_method" {
  enabled = true
}

# CloudWatch Rules
rule "aws_cloudwatch_metric_alarm_invalid_comparison_operator" {
  enabled = true
}

rule "aws_cloudwatch_metric_alarm_invalid_statistic" {
  enabled = true
}

# General Rules
rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
} 