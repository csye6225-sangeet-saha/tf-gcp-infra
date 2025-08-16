# Terraform GCP Infrastructure

This repository contains Terraform configuration for deploying a scalable web application infrastructure on Google Cloud Platform (GCP).

## Architecture Overview

The infrastructure includes:
- **VPC Network** with separate subnets for web application and database
- **Cloud SQL** (MySQL 8.0) instance with private IP configuration
- **Compute Engine** instances with autoscaling and load balancing
- **Cloud Functions** for serverless email verification
- **Cloud KMS** for encryption at rest
- **Secret Manager** for secure credential storage
- **Cloud Storage** bucket for function deployment
- **Pub/Sub** for asynchronous messaging
- **DNS** configuration for custom domain

## Prerequisites

- Terraform >= 0.15.0
- GCP Project with billing enabled
- Service account with appropriate permissions
- SendGrid API key for email functionality

## Project Structure

```
csye6225-sangeet-saha-tf-gcp-infra/
├── main.tf                 # Root module configuration
├── variables.tf            # Variable definitions
├── bucket/                 # Cloud Storage module
├── cloudFunction/          # Cloud Functions module
├── compute/                # Compute Engine & Load Balancer module
├── firewall/               # Firewall rules module
├── keyring/                # KMS encryption keys module
├── secrets/                # Secret Manager module
└── .github/workflows/      # CI/CD pipeline
```

## Key Features

### High Availability
- Regional Cloud SQL instance with automated backups
- Auto-scaling compute instances (1-3 replicas)
- HTTPS load balancer with health checks
- Multi-region secret replication

### Security
- Customer-managed encryption keys (CMEK) for all resources
- Private VPC networking with service peering
- IAM service accounts with least privilege
- Secrets stored in Secret Manager
- SSL/TLS certificates for HTTPS

### Monitoring & Operations
- Cloud Logging integration
- Metrics writer for monitoring
- Health checks for auto-healing
- Startup scripts for instance configuration

## Configuration

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `project_id` | GCP Project ID | `csye-6225-dev-415015` |
| `credentials_file` | Path to service account key | `/path/to/key.json` |
| `region` | GCP region | `us-east1` |
| `sendgrid_key` | SendGrid API key | `SG.xxx...` |

### Network Configuration
- VPC with custom subnets
- Web subnet: `10.0.3.0/24`
- Database subnet: `10.0.4.0/24`
- VPC connector for Cloud Functions: `10.8.0.0/28`

## Deployment

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Review the plan:**
   ```bash
   terraform plan -var="sendgrid_key=YOUR_API_KEY"
   ```

3. **Apply the configuration:**
   ```bash
   terraform apply -var="sendgrid_key=YOUR_API_KEY"
   ```

4. **Destroy resources (when needed):**
   ```bash
   terraform destroy -var="sendgrid_key=YOUR_API_KEY"
   ```

## Resources Created

### Compute Resources
- Regional instance template with startup script
- Managed instance group with autoscaling
- Global HTTPS load balancer
- Health checks

### Database
- Cloud SQL MySQL 8.0 instance
- 10GB SSD storage
- Private IP configuration
- Automated backups with binary logging

### Serverless
- Cloud Function for email verification
- Pub/Sub topic for async messaging
- VPC connector for private network access

### Storage & Encryption
- Cloud Storage bucket with CMEK
- KMS key ring with rotation policies
- Separate encryption keys for VMs, SQL, and Storage

## CI/CD Pipeline

GitHub Actions workflow validates Terraform configuration on pull requests:
- Terraform init
- Terraform validate
- Optional plan/apply steps (commented out)

## Service Accounts

Two main service accounts are created:
1. **Logging Service Account** - For VM instances with permissions for:
   - Cloud Logging Admin
   - Monitoring Metric Writer
   - Pub/Sub Publisher

2. **Cloud Function Service Account** - For serverless functions with permissions for:
   - Pub/Sub Subscriber
   - Storage Object Viewer
   - Cloud SQL Client
   - Logging Writer

## Domain Configuration

The infrastructure includes DNS record configuration for `paracloud.site` domain pointing to the load balancer IP.

## Security Considerations

- All data encrypted at rest using Cloud KMS
- Network isolation through VPC and private IPs
- Service accounts follow principle of least privilege
- Secrets managed through Secret Manager
- HTTPS-only traffic through managed SSL certificates

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

## Support

For issues or questions, please create an issue in the repository.
