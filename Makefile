# Makefile for Edge Network Services Terraform Module
# Usage: make <target>

.PHONY: help init plan apply destroy fmt validate lint clean test examples docs

# Default target
help:
	@echo "Edge Network Services Terraform Module"
	@echo "======================================"
	@echo ""
	@echo "Available targets:"
	@echo "  init      - Initialize Terraform"
	@echo "  plan      - Create Terraform plan"
	@echo "  apply     - Apply Terraform changes"
	@echo "  destroy   - Destroy Terraform resources"
	@echo "  fmt       - Format Terraform code"
	@echo "  validate  - Validate Terraform configuration"
	@echo "  lint      - Run TFLint"
	@echo "  clean     - Clean up Terraform files"
	@echo "  test      - Run tests"
	@echo "  examples  - Run examples"
	@echo "  docs      - Generate documentation"
	@echo "  security  - Run security scans"
	@echo "  cost      - Estimate costs"
	@echo ""

# Initialize Terraform
init:
	@echo "Initializing Terraform for Edge Network Services..."
	terraform init
	@echo "Terraform initialized successfully!"

# Create Terraform plan
plan:
	@echo "Creating Terraform plan for Edge Network Services..."
	terraform plan -out=tfplan
	@echo "Plan created successfully!"

# Apply Terraform changes
apply:
	@echo "Applying Terraform changes for Edge Network Services..."
	terraform apply tfplan
	@echo "Changes applied successfully!"

# Apply Terraform changes (auto-approve)
apply-auto:
	@echo "Applying Terraform changes (auto-approve)..."
	terraform apply -auto-approve
	@echo "Changes applied successfully!"

# Destroy Terraform resources
destroy:
	@echo "Destroying Edge Network Services resources..."
	terraform destroy -auto-approve
	@echo "Resources destroyed successfully!"

# Format Terraform code
fmt:
	@echo "Formatting Terraform code..."
	terraform fmt -recursive
	@echo "Code formatted successfully!"

# Validate Terraform configuration
validate:
	@echo "Validating Terraform configuration..."
	terraform validate
	@echo "Configuration is valid!"

# Run TFLint
lint:
	@echo "Running TFLint..."
	tflint --init
	tflint
	@echo "Linting completed!"

# Clean up Terraform files
clean:
	@echo "Cleaning up Terraform files..."
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f tfplan
	rm -f *.tfstate
	rm -f *.tfstate.backup
	@echo "Cleanup completed!"

# Run tests
test: validate lint
	@echo "Running tests for Edge Network Services..."
	cd test && terraform init
	cd test && terraform plan -detailed-exitcode
	@echo "Tests completed!"

# Run examples
examples:
	@echo "Running examples for Edge Network Services..."
	@echo "Running basic example..."
	cd examples/basic && terraform init
	cd examples/basic && terraform plan -detailed-exitcode
	@echo "Running advanced example..."
	cd examples/advanced && terraform init
	cd examples/advanced && terraform plan -detailed-exitcode
	@echo "Running global example..."
	cd examples/global && terraform init
	cd examples/global && terraform plan -detailed-exitcode
	@echo "Examples completed!"

# Generate documentation
docs:
	@echo "Generating documentation..."
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table . > README.md; \
		echo "Documentation generated successfully!"; \
	else \
		echo "terraform-docs not found. Please install it first."; \
		echo "Visit: https://terraform-docs.io/user-guide/installation/"; \
	fi

# Run security scans
security:
	@echo "Running security scans..."
	@if command -v terrascan >/dev/null 2>&1; then \
		terrascan scan -i terraform .; \
		echo "Security scan completed!"; \
	else \
		echo "Terrascan not found. Please install it first."; \
		echo "Visit: https://runterrascan.io/docs/getting-started/installation/"; \
	fi

# Estimate costs
cost:
	@echo "Estimating costs..."
	@if command -v infracost >/dev/null 2>&1; then \
		infracost breakdown --path .; \
		echo "Cost estimation completed!"; \
	else \
		echo "Infracost not found. Please install it first."; \
		echo "Visit: https://www.infracost.io/docs/"; \
	fi

# Development workflow
dev: fmt validate lint
	@echo "Development checks completed for Edge Network Services!"

# Production workflow
prod: fmt validate lint test examples security cost
	@echo "Production checks completed for Edge Network Services!"

# Quick deployment (for development)
quick: init plan apply-auto
	@echo "Quick deployment completed!"

# Full deployment with all checks
full: prod apply
	@echo "Full deployment with all checks completed!"

# Show outputs
outputs:
	@echo "Showing Terraform outputs..."
	terraform output

# Show state
state:
	@echo "Showing Terraform state..."
	terraform show

# Refresh state
refresh:
	@echo "Refreshing Terraform state..."
	terraform refresh

# Import resources (example)
import-example:
	@echo "Example import command:"
	@echo "terraform import aws_cloudfront_distribution.main <distribution-id>"

# Workspace management
workspace-dev:
	@echo "Switching to dev workspace..."
	terraform workspace select dev || terraform workspace new dev

workspace-staging:
	@echo "Switching to staging workspace..."
	terraform workspace select staging || terraform workspace new staging

workspace-prod:
	@echo "Switching to prod workspace..."
	terraform workspace select prod || terraform workspace new prod

# Backup state
backup:
	@echo "Backing up Terraform state..."
	@if [ -f terraform.tfstate ]; then \
		cp terraform.tfstate terraform.tfstate.backup.$$(date +%Y%m%d_%H%M%S); \
		echo "State backed up successfully!"; \
	else \
		echo "No terraform.tfstate file found."; \
	fi

# Restore state
restore:
	@echo "Available backups:"
	@ls -la terraform.tfstate.backup.* 2>/dev/null || echo "No backups found"
	@echo ""
	@echo "To restore, run: cp terraform.tfstate.backup.<timestamp> terraform.tfstate"

# Show module information
info:
	@echo "Edge Network Services Module Information"
	@echo "======================================="
	@echo "Module: Edge Network Services"
	@echo "Description: Comprehensive edge network services for global architectures"
	@echo "Services: CloudFront, Global Accelerator, Route 53, WAF, Shield, ACM"
	@echo "Version: 1.0.0"
	@echo ""

# Show help for specific service
help-cloudfront:
	@echo "CloudFront Configuration Help"
	@echo "============================"
	@echo "Variables to configure:"
	@echo "  - cloudfront_origins"
	@echo "  - cloudfront_default_cache_behavior"
	@echo "  - cloudfront_aliases"
	@echo "  - cloudfront_acm_certificate_arn"
	@echo ""

help-global-accelerator:
	@echo "Global Accelerator Configuration Help"
	@echo "===================================="
	@echo "Variables to configure:"
	@echo "  - global_accelerator_listeners"
	@echo "  - global_accelerator_endpoint_groups"
	@echo ""

help-waf:
	@echo "WAF Configuration Help"
	@echo "====================="
	@echo "Variables to configure:"
	@echo "  - waf_rules"
	@echo "  - waf_default_action"
	@echo ""

help-route53:
	@echo "Route 53 Configuration Help"
	@echo "=========================="
	@echo "Variables to configure:"
	@echo "  - route53_domain_name"
	@echo "  - route53_records"
	@echo "" 