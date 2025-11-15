# Terraform Infrastructure for Voting App

This directory contains Terraform configurations for provisioning Azure infrastructure for the voting application.

## Structure

```
terraform/
├── modules/
│   ├── aks/          # AKS cluster module
│   └── network/      # Network resources module
└── environments/
    ├── dev/          # Development environment
    └── prod/         # Production environment
```

## Prerequisites

- Terraform >= 1.0
- Azure CLI installed and configured
- Appropriate Azure permissions
- Azure AD admin group object ID

## Usage

### Development Environment

1. Navigate to the dev environment:
```bash
cd environments/dev
```

2. Copy the example tfvars file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

3. Edit `terraform.tfvars` with your values

4. Initialize Terraform:
```bash
terraform init
```

5. Plan the deployment:
```bash
terraform plan
```

6. Apply the configuration:
```bash
terraform apply
```

### Production Environment

Follow the same steps in `environments/prod/`

## Backend Configuration

The backend is configured for Terraform Cloud. Update the `backend "remote"` block in `main.tf` files to match your Terraform Cloud organization and workspace names.

For local state, comment out the backend block and Terraform will use local state files.

## Outputs

After applying, you'll get:
- Resource group name
- Cluster name and FQDN
- Kubeconfig (sensitive)
- Subnet IDs

## Notes

- The configuration uses Azure AD RBAC for Kubernetes
- Network policies are enabled (Calico)
- Auto-scaling is enabled for node pools
- Log Analytics workspace is configured for monitoring
- Production uses larger VM sizes and higher node counts

