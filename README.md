# Edge Network Services Terraform Module

A comprehensive Terraform module for deploying edge network services to optimize user performance and traffic management for global architectures on AWS.

## 🚀 Features

This module provides a complete solution for edge network services including:

- **CloudFront Distribution** - Global content delivery network
- **AWS Global Accelerator** - Network performance optimization
- **Route 53** - DNS management and traffic routing
- **WAF (Web Application Firewall)** - Security protection
- **AWS Shield** - DDoS protection
- **ACM Certificates** - SSL/TLS certificate management
- **CloudWatch Monitoring** - Performance monitoring and alerting

## 📋 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## 🔧 Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## 📦 Modules

No modules.

## 💾 Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_cloudfront_distribution.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudwatch_metric_alarm.cloudfront_4xx_errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cloudfront_5xx_errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cloudfront_cache_hit_ratio](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_globalaccelerator_accelerator.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/globalaccelerator_accelerator) | resource |
| [aws_globalaccelerator_endpoint_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/globalaccelerator_endpoint_group) | resource |
| [aws_globalaccelerator_listener.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/globalaccelerator_listener) | resource |
| [aws_route53_record.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_shield_protection.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_protection) | resource |
| [aws_wafv2_web_acl.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |

## 📝 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access_logs_bucket | S3 bucket for CloudFront access logs | `string` | `null` | no |
| access_logs_prefix | Prefix for CloudFront access logs | `string` | `"cloudfront-logs"` | no |
| acm_certificate_arn | ARN of ACM certificate for CloudFront distribution | `string` | `null` | no |
| cloudfront_acm_certificate_arn | ARN of ACM certificate for CloudFront distribution | `string` | `null` | no |
| cloudfront_aliases | Extra CNAMEs (alternate domain names) for CloudFront distribution | `list(string)` | `[]` | no |
| cloudfront_compression | Enable compression for CloudFront | `bool` | `true` | no |
| cloudfront_default_cache_behavior | Default cache behavior for CloudFront | `object({...})` | `{...}` | no |
| cloudfront_enabled | Whether the CloudFront distribution is enabled | `bool` | `true` | no |
| cloudfront_is_ipv6_enabled | Whether IPv6 is enabled for CloudFront distribution | `bool` | `true` | no |
| cloudfront_minimum_protocol_version | Minimum protocol version for CloudFront distribution | `string` | `"TLSv1.2_2021"` | no |
| cloudfront_ordered_cache_behaviors | Ordered cache behaviors for CloudFront | `list(object({...}))` | `[]` | no |
| cloudfront_origins | List of CloudFront origins | `list(object({...}))` | `[]` | no |
| cloudfront_price_class | Price class for CloudFront distribution | `string` | `"PriceClass_100"` | no |
| cloudwatch_alarms | List of CloudWatch alarms to create | `list(object({...}))` | `[]` | no |
| enable_access_logs | Enable access logs for CloudFront | `bool` | `true` | no |
| enable_cloudfront | Enable CloudFront distribution | `bool` | `true` | no |
| enable_cost_optimization | Enable cost optimization features | `bool` | `true` | no |
| enable_global_accelerator | Enable AWS Global Accelerator | `bool` | `false` | no |
| enable_monitoring | Enable CloudWatch monitoring and alarms | `bool` | `true` | no |
| enable_route53 | Enable Route 53 hosted zone and records | `bool` | `false` | no |
| enable_shield | Enable AWS Shield Advanced protection | `bool` | `false` | no |
| enable_ssl_certificate | Enable SSL certificate creation via ACM | `bool` | `false` | no |
| enable_waf | Enable WAF Web ACL | `bool` | `true` | no |
| environment | Environment name (e.g., dev, staging, prod) | `string` | `"prod"` | no |
| global_accelerator_endpoint_groups | List of endpoint groups for Global Accelerator | `list(object({...}))` | `[]` | no |
| global_accelerator_ip_address_type | IP address type for Global Accelerator | `string` | `"IPV4"` | no |
| global_accelerator_listeners | List of listeners for Global Accelerator | `list(object({...}))` | `[{...}]` | no |
| global_accelerator_name | Name of the Global Accelerator | `string` | `"edge-accelerator"` | no |
| project_name | Name of the project | `string` | `"edge-network"` | no |
| route53_domain_name | Domain name for Route 53 hosted zone | `string` | `""` | no |
| route53_records | List of Route 53 records to create | `list(object({...}))` | `[]` | no |
| shield_protection_arn | ARN of the resource to protect with Shield Advanced | `string` | `null` | no |
| ssl_certificate_domain | Domain name for SSL certificate | `string` | `null` | no |
| ssl_certificate_subject_alternative_names | Subject alternative names for SSL certificate | `list(string)` | `[]` | no |
| ssl_certificate_validation_method | Validation method for SSL certificate | `string` | `"DNS"` | no |
| tags | A map of tags to assign to all resources | `map(string)` | `{}` | no |
| waf_default_action | Default action for WAF Web ACL | `object({...})` | `{...}` | no |
| waf_description | Description of the WAF Web ACL | `string` | `"WAF Web ACL for edge network services"` | no |
| waf_name | Name of the WAF Web ACL | `string` | `"edge-waf"` | no |
| waf_rules | List of WAF rules | `list(object({...}))` | `[{...}]` | no |
| waf_visibility_config | Visibility configuration for WAF Web ACL | `object({...})` | `{...}` | no |

## 📤 Outputs

| Name | Description |
|------|-------------|
| acm_certificate_arn | ARN of the ACM certificate |
| acm_certificate_domain_name | Domain name of the ACM certificate |
| acm_certificate_id | ID of the ACM certificate |
| acm_certificate_status | Status of the ACM certificate |
| acm_certificate_subject_alternative_names | Subject alternative names of the ACM certificate |
| acm_certificate_validation_method | Validation method of the ACM certificate |
| cloudfront_4xx_errors_alarm_arn | ARN of the CloudFront 4xx errors alarm |
| cloudfront_5xx_errors_alarm_arn | ARN of the CloudFront 5xx errors alarm |
| cloudfront_cache_hit_ratio_alarm_arn | ARN of the CloudFront cache hit ratio alarm |
| cloudfront_distribution_arn | ARN of the CloudFront distribution |
| cloudfront_distribution_domain_name | Domain name of the CloudFront distribution |
| cloudfront_distribution_etag | ETag of the CloudFront distribution |
| cloudfront_distribution_hosted_zone_id | Hosted zone ID of the CloudFront distribution |
| cloudfront_distribution_id | ID of the CloudFront distribution |
| cloudfront_distribution_in_progress_validation_batches | Number of in-progress validation batches for the CloudFront distribution |
| cloudfront_distribution_last_modified_time | Last modified time of the CloudFront distribution |
| cloudfront_distribution_status | Status of the CloudFront distribution |
| cloudwatch_alarm_arns | ARNs of the CloudWatch alarms |
| cloudwatch_alarm_ids | IDs of the CloudWatch alarms |
| cloudwatch_alarm_names | Names of the CloudWatch alarms |
| common_tags | Common tags applied to all resources |
| endpoints | All endpoint URLs and DNS names |
| environment | Environment name |
| global_accelerator_arn | ARN of the Global Accelerator |
| global_accelerator_dns_name | DNS name of the Global Accelerator |
| global_accelerator_enabled | Whether the Global Accelerator is enabled |
| global_accelerator_endpoint_group_arns | ARNs of the Global Accelerator endpoint groups |
| global_accelerator_endpoint_group_ids | IDs of the Global Accelerator endpoint groups |
| global_accelerator_hosted_zone_id | Hosted zone ID of the Global Accelerator |
| global_accelerator_id | ID of the Global Accelerator |
| global_accelerator_ip_sets | IP sets of the Global Accelerator |
| global_accelerator_listener_arns | ARNs of the Global Accelerator listeners |
| global_accelerator_listener_ids | IDs of the Global Accelerator listeners |
| global_accelerator_name | Name of the Global Accelerator |
| module_name | Name of the edge network module |
| route53_record_ids | IDs of the Route 53 records |
| route53_record_names | Names of the Route 53 records |
| route53_record_types | Types of the Route 53 records |
| route53_zone_arn | ARN of the Route 53 hosted zone |
| route53_zone_id | ID of the Route 53 hosted zone |
| route53_zone_name | Name of the Route 53 hosted zone |
| route53_zone_name_servers | Name servers of the Route 53 hosted zone |
| shield_protection_arn | ARN of the Shield protection |
| shield_protection_id | ID of the Shield protection |
| shield_protection_name | Name of the Shield protection |
| summary | Summary of all created resources |
| waf_web_acl_arn | ARN of the WAF Web ACL |
| waf_web_acl_capacity | Capacity of the WAF Web ACL |
| waf_web_acl_description | Description of the WAF Web ACL |
| waf_web_acl_id | ID of the WAF Web ACL |
| waf_web_acl_name | Name of the WAF Web ACL |

## 🏗️ Architecture

This module creates a comprehensive edge network architecture:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Route 53      │    │   CloudFront    │    │ Global Accelerator│
│   DNS Service   │───▶│   Distribution  │───▶│   (Optional)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   WAF Web ACL   │    │   ACM Cert      │    │   CloudWatch    │
│   (Security)    │    │   (SSL/TLS)     │    │   (Monitoring)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Shield        │    │   S3 Logs       │    │   Alarms        │
│   (DDoS)        │    │   (Access)      │    │   (Alerts)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Quick Start

### Basic Usage

```hcl
module "edge_network" {
  source = "./edge-network"

  environment = "prod"
  project_name = "my-app"

  # CloudFront Configuration
  cloudfront_origins = [
    {
      domain_name = "my-app.s3-website-us-east-1.amazonaws.com"
      origin_id   = "S3-Origin"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  ]

  cloudfront_default_cache_behavior = {
    target_origin_id       = "S3-Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  # WAF Configuration
  enable_waf = true
  waf_rules = [
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

  # Monitoring
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
      alarm_description   = "High error rate detected"
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

  tags = {
    Environment = "production"
    Project     = "my-app"
    Owner       = "devops-team"
  }
}
```

### Advanced Usage with Global Accelerator

```hcl
module "edge_network_global" {
  source = "./edge-network"

  environment = "prod"
  project_name = "global-app"

  # Enable Global Accelerator
  enable_global_accelerator = true
  global_accelerator_name   = "global-app-accelerator"
  
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
          endpoint_id = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/1234567890abcdef"
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
  route53_domain_name = "myapp.com"
  
  route53_records = [
    {
      name = "www.myapp.com"
      type = "A"
      alias = {
        name                   = "d1234abcd.cloudfront.net"
        zone_id                = "Z2FDTNDATAQYW2"
        evaluate_target_health = false
      }
    },
    {
      name = "api.myapp.com"
      type = "A"
      alias = {
        name                   = "a1234567890abcdef.awsglobalaccelerator.com"
        zone_id                = "Z2BJ6XQ5FK7U4H"
        evaluate_target_health = true
      }
    }
  ]

  # SSL Certificate
  enable_ssl_certificate = true
  ssl_certificate_domain = "myapp.com"
  ssl_certificate_subject_alternative_names = ["www.myapp.com", "api.myapp.com"]

  tags = {
    Environment = "production"
    Project     = "global-app"
    Owner       = "devops-team"
  }
}
```

## 🔧 Configuration Examples

### Basic CloudFront Setup

```hcl
module "basic_cloudfront" {
  source = "./edge-network"

  environment = "dev"
  project_name = "basic-app"

  cloudfront_origins = [
    {
      domain_name = "my-bucket.s3.amazonaws.com"
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
}
```

### WAF with Custom Rules

```hcl
module "waf_protected" {
  source = "./edge-network"

  environment = "prod"
  project_name = "secure-app"

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
          country_codes = ["CN", "RU"]
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "GeoBlockMetric"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "AWSManagedRulesCommonRuleSet"
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
        metric_name                = "AWSManagedRulesCommonRuleSetMetric"
        sampled_requests_enabled   = true
      }
    }
  ]
}
```

## 📊 Monitoring and Alerting

The module includes built-in CloudWatch monitoring with the following default alarms:

- **4xx Error Rate** - Alerts when 4xx errors exceed 5%
- **5xx Error Rate** - Alerts when 5xx errors exceed 2%
- **Cache Hit Ratio** - Alerts when cache hit ratio falls below 80%

### Custom Monitoring

```hcl
module "monitored_edge" {
  source = "./edge-network"

  environment = "prod"
  project_name = "monitored-app"

  enable_monitoring = true
  cloudwatch_alarms = [
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
      alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:alerts-topic"]
      ok_actions          = ["arn:aws:sns:us-east-1:123456789012:alerts-topic"]
      dimensions = [
        {
          name  = "DistributionId"
          value = "E1234567890ABC"
        }
      ]
    }
  ]
}
```

## 🔒 Security Features

### WAF Protection

The module includes comprehensive WAF protection with:

- AWS Managed Rules
- Rate limiting
- Geographic blocking
- IP-based blocking
- Custom rules support

### SSL/TLS Configuration

- Automatic SSL certificate management via ACM
- TLS 1.2+ enforcement
- Custom domain support
- Certificate validation

### DDoS Protection

- AWS Shield integration (when enabled)
- CloudFront DDoS protection
- Global Accelerator DDoS protection

## 💰 Cost Optimization

The module includes several cost optimization features:

- **CloudFront Price Classes** - Choose appropriate price class for your regions
- **Compression** - Enable compression to reduce bandwidth costs
- **Caching** - Optimize cache settings to reduce origin requests
- **Monitoring** - Track costs with CloudWatch metrics

### Cost Optimization Example

```hcl
module "cost_optimized" {
  source = "./edge-network"

  environment = "prod"
  project_name = "cost-optimized-app"

  # Cost optimization settings
  enable_cost_optimization = true
  cloudfront_price_class   = "PriceClass_100"  # US, Canada, Europe only
  cloudfront_compression   = true

  # Optimized cache behavior
  cloudfront_default_cache_behavior = {
    target_origin_id       = "S3-Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    min_ttl                = 0
    default_ttl            = 86400    # 24 hours
    max_ttl                = 31536000 # 1 year
  }

  # Specific cache behaviors for different content types
  cloudfront_ordered_cache_behaviors = [
    {
      path_pattern     = "/images/*"
      target_origin_id = "S3-Origin"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods  = ["GET", "HEAD"]
      cached_methods   = ["GET", "HEAD"]
      compress         = true
      min_ttl          = 0
      default_ttl      = 604800    # 7 days
      max_ttl          = 31536000  # 1 year
    },
    {
      path_pattern     = "/api/*"
      target_origin_id = "S3-Origin"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods  = ["GET", "HEAD", "OPTIONS"]
      cached_methods   = ["GET", "HEAD"]
      compress         = true
      min_ttl          = 0
      default_ttl      = 300       # 5 minutes
      max_ttl          = 3600      # 1 hour
    }
  ]
}
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
make test

# Run examples
make examples

# Validate configuration
make validate

# Run linting
make lint
```

### Test Configuration

```hcl
# test/main.tf
module "edge_network_test" {
  source = "../"

  environment = "test"
  project_name = "test-app"

  # Minimal configuration for testing
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

  enable_waf = false  # Disable WAF for testing
  enable_monitoring = false  # Disable monitoring for testing
}
```

## 🚀 Deployment

### Quick Deployment

```bash
# Initialize and deploy
make quick

# Or step by step
make init
make plan
make apply
```

### Production Deployment

```bash
# Full production deployment with all checks
make full
```

### Workspace Management

```bash
# Switch to development workspace
make workspace-dev

# Switch to production workspace
make workspace-prod
```

## 📚 Additional Resources

- [AWS CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [AWS Global Accelerator Documentation](https://docs.aws.amazon.com/global-accelerator/)
- [AWS WAF Documentation](https://docs.aws.amazon.com/waf/)
- [AWS Route 53 Documentation](https://docs.aws.amazon.com/route53/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Run the test suite
6. Submit a pull request

## 📄 License

This module is licensed under the MIT License. See the LICENSE file for details.

## 🆘 Support

For support and questions:

1. Check the documentation
2. Review the examples
3. Open an issue on GitHub
4. Contact the development team

## 🔄 Version History

- **v1.0.0** - Initial release with comprehensive edge network services
- **v1.1.0** - Added Global Accelerator support
- **v1.2.0** - Enhanced monitoring and alerting
- **v1.3.0** - Added cost optimization features
- **v1.4.0** - Improved security and WAF configuration 