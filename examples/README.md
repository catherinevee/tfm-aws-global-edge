# Edge Network Services Examples

This directory contains example configurations for the Edge Network Services Terraform module, demonstrating different use cases and complexity levels.

## 📁 Example Configurations

### 🟢 Basic Example (`basic/`)

A simple configuration demonstrating the core functionality of the module.

**Features:**
- Single CloudFront distribution with S3 origin
- Basic WAF protection
- Default monitoring
- Minimal configuration for quick start

**Use Case:** Perfect for getting started with the module or for simple static content delivery.

**Files:**
- `main.tf` - Main configuration file
- `outputs.tf` - Output definitions

**Quick Start:**
```bash
cd examples/basic
terraform init
terraform plan
terraform apply
```

### 🔵 Advanced Example (`advanced/`)

A comprehensive configuration showcasing advanced features and best practices.

**Features:**
- Multiple CloudFront origins (S3, API, Media)
- Custom cache behaviors for different content types
- Enhanced WAF rules (rate limiting, geo-blocking, SQL injection protection)
- Custom domain names with SSL certificates
- Advanced monitoring and alerting
- Access logging

**Use Case:** Production-ready configuration for complex applications with multiple content types.

**Files:**
- `main.tf` - Advanced configuration with multiple origins
- `outputs.tf` - Comprehensive outputs

**Deployment:**
```bash
cd examples/advanced
terraform init
terraform plan
terraform apply
```

### 🌍 Global Example (`global/`)

A global architecture configuration demonstrating multi-region deployment.

**Features:**
- Global Accelerator for multi-region performance optimization
- Route 53 DNS management
- Multi-region endpoint groups
- Global WAF protection
- Comprehensive monitoring across regions
- SSL certificate management

**Use Case:** Enterprise applications requiring global presence and high availability.

**Files:**
- `main.tf` - Global configuration with multi-region setup
- `outputs.tf` - Global outputs and endpoint information

**Global Deployment:**
```bash
cd examples/global
terraform init
terraform plan
terraform apply
```

## 🚀 Getting Started

### Prerequisites

1. **AWS CLI configured** with appropriate permissions
2. **Terraform** version >= 1.0
3. **AWS Provider** version >= 5.0

### Common Setup Steps

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd edge-network/edge-network
   ```

2. **Choose an example:**
   ```bash
   cd examples/basic    # or advanced, global
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Review the plan:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

## 🔧 Configuration Customization

### Basic Customization

For the basic example, you can customize:

```hcl
module "edge_network_basic" {
  source = "../../"

  environment = "dev"
  project_name = "my-app"

  # Customize CloudFront origin
  cloudfront_origins = [
    {
      domain_name = "your-bucket.s3.amazonaws.com"
      origin_id   = "S3-Origin"
      s3_origin_config = {
        origin_access_identity = "origin-access-identity/cloudfront/YOUR-OAI"
      }
    }
  ]

  # Customize cache behavior
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

  tags = {
    Environment = "development"
    Project     = "my-app"
    Owner       = "your-team"
  }
}
```

### Advanced Customization

For the advanced example, you can add:

```hcl
# Custom WAF rules
waf_rules = [
  {
    name     = "CustomRule"
    priority = 1
    action = {
      type = "BLOCK"
    }
    statement = {
      byte_match_statement = {
        search_string         = "malicious-pattern"
        field_to_match        = { uri_path = {} }
        text_transformation   = { priority = 1, type = "LOWERCASE" }
        positional_constraint = "CONTAINS"
      }
    }
    visibility_config = {
      cloudwatch_metrics_enabled = true
      metric_name                = "CustomRuleMetric"
      sampled_requests_enabled   = true
    }
  }
]

# Custom monitoring
cloudwatch_alarms = [
  {
    alarm_name          = "custom-alarm"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 2
    metric_name         = "Requests"
    namespace           = "AWS/CloudFront"
    period              = 300
    statistic           = "Sum"
    threshold           = 1000
    alarm_description   = "High request volume"
    alarm_actions       = []
    ok_actions          = []
    dimensions = [
      {
        name  = "DistributionId"
        value = "YOUR-DISTRIBUTION-ID"
      }
    ]
  }
]
```

### Global Customization

For the global example, you can configure:

```hcl
# Multi-region endpoint groups
global_accelerator_endpoint_groups = [
  {
    listener_arn = "YOUR-LISTENER-ARN"
    region       = "us-east-1"
    endpoint_configurations = [
      {
        endpoint_id = "YOUR-US-EAST-1-ENDPOINT"
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

# Route 53 records
route53_records = [
  {
    name = "www.yourdomain.com"
    type = "A"
    alias = {
      name                   = "YOUR-CLOUDFRONT-DOMAIN"
      zone_id                = "Z2FDTNDATAQYW2"
      evaluate_target_health = false
    }
  }
]
```

## 📊 Cost Considerations

### Basic Example
- **Estimated Cost:** $10-50/month
- **Components:** CloudFront, WAF, basic monitoring

### Advanced Example
- **Estimated Cost:** $50-200/month
- **Components:** CloudFront, WAF, SSL certificate, enhanced monitoring, access logs

### Global Example
- **Estimated Cost:** $200-1000/month
- **Components:** CloudFront, Global Accelerator, Route 53, WAF, SSL certificate, comprehensive monitoring

## 🔒 Security Features

All examples include security best practices:

- **WAF Protection:** Web application firewall with managed rules
- **SSL/TLS:** HTTPS enforcement and certificate management
- **Access Control:** Origin access identities for S3
- **Monitoring:** Security-focused CloudWatch alarms
- **Logging:** Access logs for audit trails

## 🧪 Testing

### Running Tests

```bash
# Test the basic example
cd examples/basic
terraform init
terraform plan -detailed-exitcode

# Test the advanced example
cd examples/advanced
terraform init
terraform plan -detailed-exitcode

# Test the global example
cd examples/global
terraform init
terraform plan -detailed-exitcode
```

### Validation

```bash
# Validate Terraform configuration
terraform validate

# Run TFLint
tflint

# Check security with Checkov
checkov -f main.tf
```

## 🚨 Important Notes

1. **Costs:** These examples will create AWS resources that incur costs. Review the estimated costs before deployment.

2. **Permissions:** Ensure your AWS credentials have the necessary permissions for all services.

3. **Domains:** Replace example domains with your actual domains in production configurations.

4. **Certificates:** SSL certificates require domain validation. Ensure DNS is properly configured.

5. **Global Accelerator:** Requires specific AWS regions and endpoint configurations.

## 📚 Additional Resources

- [Module Documentation](../README.md)
- [AWS CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [AWS Global Accelerator Documentation](https://docs.aws.amazon.com/global-accelerator/)
- [AWS WAF Documentation](https://docs.aws.amazon.com/waf/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 🤝 Support

For questions or issues with these examples:

1. Check the module documentation
2. Review AWS service documentation
3. Open an issue on GitHub
4. Contact the development team 