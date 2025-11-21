# Voting Application - Production-Ready DevOps Setup

[![CI/CD Pipeline](https://github.com/mohammed-makram/devops-Quest/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/mohammed-makram/devops-Quest/actions/workflows/ci-cd.yml)
[![Security Scanning](https://github.com/mohammed-makram/devops-Quest/actions/workflows/security.yml/badge.svg)](https://github.com/mohammed-makram/devops-Quest/actions/workflows/security.yml)

## 🎬 Demo Video

**Watch the full demo:** [Demo Video on Google Drive](https://drive.google.com/file/d/1vZABMYmm5oq-_oBzeBM7ORa0W2-FMBUP/view?usp=drive_link)

## Overview

This is a production-ready DevOps implementation of a distributed voting application built as part of the **Junior DevOps Engineer hiring quest at Tactful.ai**. The application consists of multiple microservices containerized with Docker, orchestrated with Kubernetes, and deployed on a **local Kubernetes cluster (Minikube)** with full CI/CD automation.

**Repository:** https://github.com/mohammed-makram/devops-Quest

> **Note:** This project is deployed on a local Kubernetes cluster (Minikube) due to Azure subscription limitations. The Terraform infrastructure code is production-ready for Azure AKS deployment. See [LOCAL_DEPLOYMENT.md](LOCAL_DEPLOYMENT.md) for detailed local setup instructions.

## Architecture

### Application Components

- **Vote Service** (`/vote`): Python Flask web application that provides the voting interface
  - Exposed on port 8080
  - Connects to Redis to queue votes
  
- **Result Service** (`/result`): Node.js web application that displays real-time voting results
  - Exposed on port 8081
  - Uses WebSocket for real-time updates
  - Queries PostgreSQL for vote counts

- **Worker Service** (`/worker`): .NET worker application that processes votes
  - Consumes votes from Redis queue
  - Stores processed votes in PostgreSQL

- **Redis**: Message broker that queues votes for processing
- **PostgreSQL**: Database that stores the final vote counts
- **Seed Data Service**: Utility service for populating test data

### Network Architecture

The application uses a **two-tier network architecture** for security:

- **Frontend Tier**: Vote and Result services (user-facing)
- **Backend Tier**: Worker, Redis, and PostgreSQL (internal services only)

This separation ensures that database and message queue services are not directly accessible from outside.

### Data Flow

1. Users visit the vote service to cast their votes
2. Votes are sent to Redis queue
3. Worker service processes votes from Redis and stores them in PostgreSQL
4. Result service queries PostgreSQL and displays real-time results via WebSocket

## Project Structure

```
.
├── vote/                  # Python Flask application
├── result/                # Node.js application
├── worker/                # .NET worker application
├── seed-data/             # Data seeding utility
├── docker-compose.yml     # Local development setup
├── k8s/                   # Kubernetes manifests
│   ├── base/              # Base Kubernetes resources
│   └── manifests/         # Additional manifests
├── helm/                  # Helm charts
│   └── voting-app/        # Production Helm chart
├── terraform/             # Infrastructure as Code
│   ├── modules/           # Reusable Terraform modules
│   └── environments/      # Environment-specific configs
├── monitoring/            # Prometheus & Grafana configs
└── .github/workflows/     # CI/CD pipelines
```

## Prerequisites

### Required:
- Docker and Docker Compose
- Minikube (or k3s/microk8s)
- kubectl
- Helm 3.x

### Optional (for Azure AKS deployment):
- Terraform >= 1.0
- Azure CLI
- Azure subscription

### Quick Links:
- 📖 [Local Deployment Guide](LOCAL_DEPLOYMENT.md) - Detailed Minikube/k3s setup
- 🎬 [Demo Video Script](DEMO_SCRIPT.md) - Guide for recording demo video
- 🧪 [Testing Guide](TESTING_GUIDE.md) - Comprehensive testing instructions

## Phase 1: Containerization & Local Setup

### Running Locally with Docker Compose

1. **Clone the repository:**
```bash
git clone https://github.com/mohammed-makram/devops-Quest.git
cd devops-Quest
```

2. **Build and start all services:**
```bash
docker compose up -d
```

3. **Verify services are running:**
```bash
docker compose ps
```

4. **Access the application:**
   - Vote service: http://localhost:8080
   - Result service: http://localhost:8081

5. **Populate test data (optional):**
```bash
docker compose --profile seed up
```

### Features

- ✅ All services containerized with non-root users
- ✅ Two-tier networking (frontend/backend isolation)
- ✅ Health checks for Redis and PostgreSQL
- ✅ Proper service dependencies
- ✅ Security best practices (no-new-privileges, read-only root filesystem where possible)

## Phase 2: Infrastructure & Deployment

### Terraform Infrastructure

The infrastructure is managed with Terraform and supports multi-environment deployments (dev/prod).

#### Prerequisites

1. Azure CLI installed and authenticated
2. Azure AD group for RBAC (required for AKS admin access)

#### Deploy Infrastructure

**Development Environment:**
```bash
cd terraform/environments/dev
terraform init
terraform plan -var="admin_group_object_id=<your-group-id>"
terraform apply
```

**Production Environment:**
```bash
cd terraform/environments/prod
terraform init
terraform plan -var="admin_group_object_id=<your-group-id>"
terraform apply
```

#### Infrastructure Features

- ✅ AKS cluster with managed identity
- ✅ Azure AD RBAC integration
- ✅ Network policies (Calico)
- ✅ Auto-scaling enabled
- ✅ Log Analytics workspace for monitoring
- ✅ Separate node pools for system and user workloads
- ✅ Multi-environment support (dev/prod)

**Note:** This project is deployed on Minikube. For detailed local cluster setup instructions, see [LOCAL_DEPLOYMENT.md](LOCAL_DEPLOYMENT.md).

The Terraform code is provided as a reference implementation for Azure AKS and demonstrates understanding of Infrastructure as Code principles.

### Kubernetes Deployment

#### Using Helm (Recommended)

1. **Add Helm repositories:**
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

2. **Install dependencies:**
```bash
cd helm/voting-app
helm dependency update
```

3. **Deploy to development:**
```bash
helm upgrade --install voting-app . \
  --namespace voting-app \
  --create-namespace \
  --values values-dev.yaml \
  --set vote.image.repository=ghcr.io/mohammed-makram/vote \
  --set vote.image.tag=latest \
  --set result.image.repository=ghcr.io/mohammed-makram/result \
  --set result.image.tag=latest \
  --set worker.image.repository=ghcr.io/mohammed-makram/worker \
  --set worker.image.tag=latest
```

4. **Deploy to production:**
```bash
helm upgrade --install voting-app . \
  --namespace voting-app \
  --create-namespace \
  --values values-prod.yaml \
  --set vote.image.repository=<your-registry>/vote \
  --set result.image.tag=<version-tag> \
  --set result.image.repository=<your-registry>/result \
  --set result.image.tag=<version-tag> \
  --set worker.image.repository=<your-registry>/worker \
  --set worker.image.tag=<version-tag>
```

#### Using Kubernetes Manifests

```bash
kubectl apply -k k8s/base
```

#### Kubernetes Features

- ✅ ConfigMaps for configuration management
- ✅ Secrets for sensitive data (use Azure Key Vault in production)
- ✅ Resource limits and requests
- ✅ Liveness and readiness probes
- ✅ Pod Security Admission (PSA) - Restricted mode
- ✅ NetworkPolicies for network isolation
- ✅ RBAC for access control
- ✅ Horizontal Pod Autoscaling (HPA)
- ✅ StatefulSets for PostgreSQL and Redis with persistence
- ✅ Ingress configuration for external access

### Local Cluster Setup (Current Deployment)

This project is deployed on **Minikube** for demonstration purposes.

#### Quick Start with Minikube:

```bash
# Start Minikube with sufficient resources
minikube start --driver=docker --cpus=4 --memory=8192

# Enable required addons
minikube addons enable ingress
minikube addons enable metrics-server

# Verify cluster
kubectl get nodes
```

#### Build Images for Minikube:

```bash
# Point Docker to Minikube's Docker daemon
eval $(minikube docker-env)

# Build all images
docker build -t ghcr.io/mohammed-makram/vote:latest ./vote
docker build -t ghcr.io/mohammed-makram/result:latest ./result
docker build -t ghcr.io/mohammed-makram/worker:latest ./worker
```

#### Deploy with Helm:

```bash
cd helm/voting-app
helm dependency update
helm upgrade --install voting-app . \
  --namespace voting-app \
  --create-namespace \
  --values values-dev.yaml \
  --set vote.image.pullPolicy=IfNotPresent \
  --set result.image.pullPolicy=IfNotPresent \
  --set worker.image.pullPolicy=IfNotPresent
```

#### Access the Application:

```bash
# Port forwarding (easiest method)
kubectl port-forward -n voting-app svc/voting-app-vote 8080:80
kubectl port-forward -n voting-app svc/voting-app-result 8081:4000

# Access in browser:
# Vote: http://localhost:8080
# Result: http://localhost:8081
```

**📖 For detailed instructions, troubleshooting, and alternatives (k3s/microk8s), see [LOCAL_DEPLOYMENT.md](LOCAL_DEPLOYMENT.md)**

#### Trade-offs: Local vs Azure AKS

**Local Cluster Limitations:**
- ❌ No managed Kubernetes updates
- ❌ No Azure-native integrations (Azure AD, Key Vault, etc.)
- ❌ No high availability across zones
- ❌ Limited scalability
- ❌ Manual maintenance required

**Local Cluster Advantages:**
- ✅ Zero cost
- ✅ Fast iteration and testing
- ✅ Full control
- ✅ Same Kubernetes APIs as cloud

**For production workloads, managed Kubernetes services (AKS, EKS, GKE) are strongly recommended.**

## Phase 3: CI/CD, Security & Observability

### CI/CD Pipeline

The project includes GitHub Actions workflows for:

1. **Build and Test** (`ci-cd.yml`):
   - Builds Docker images for all services
   - Runs security scans (Trivy)
   - Executes unit tests
   - Validates Terraform configurations
   - Automatically deploys to dev/prod environments

2. **Security Scanning** (`security.yml`):
   - SAST (Static Application Security Testing) with Bandit and ESLint
   - DAST (Dynamic Application Security Testing) with OWASP ZAP
   - Container image scanning with Trivy
   - Docker Bench Security checks

3. **Infrastructure Deployment** (`ci-cd.yml`):
   - Automatically deploys infrastructure changes when committed with `[infra]` or `[terraform]` prefix

#### GitHub Secrets Required

For automated deployment (currently disabled for local cluster):
- `GITHUB_TOKEN`: Automatically provided by GitHub Actions for GHCR access

For Azure AKS deployment (optional):
- `AZURE_CREDENTIALS`: Azure service principal credentials
- `AKS_RESOURCE_GROUP`: AKS resource group name (dev)
- `AKS_CLUSTER_NAME`: AKS cluster name (dev)
- `AKS_RESOURCE_GROUP_PROD`: AKS resource group name (prod)
- `AKS_CLUSTER_NAME_PROD`: AKS cluster name (prod)

**Note:** Deployment jobs are currently commented out in the CI/CD pipeline for local cluster deployment. See [LOCAL_DEPLOYMENT.md](LOCAL_DEPLOYMENT.md) for manual deployment steps.

### Monitoring

#### Prometheus & Grafana

Deploy monitoring stack:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

Apply ServiceMonitor and PrometheusRules:

```bash
kubectl apply -f monitoring/servicemonitor.yaml
```

#### Monitoring Features

- ✅ Metrics collection from all services
- ✅ Pre-configured Grafana dashboards
- ✅ Alerting rules for:
  - High error rates
  - Pod crash loops
  - High memory/CPU usage
  - Database connection failures
  - Redis connection failures

### Security

#### Implemented Security Measures

1. **Pod Security Admission (PSA)**: Restricted mode enforced at namespace level
2. **Network Policies**: Isolated backend services from direct external access
3. **RBAC**: Role-based access control for Kubernetes resources
4. **Non-root containers**: All services run as non-root users
5. **Security scanning**: Integrated SAST/DAST in CI/CD pipeline
6. **Secrets management**: Kubernetes Secrets (Azure Key Vault recommended for production)
7. **Image scanning**: Trivy scans all container images for vulnerabilities
8. **Azure AD RBAC**: Integrated with Azure AD for AKS access control

#### Security Best Practices

- Use Azure Key Vault CSI driver for secrets in production
- Enable Azure Defender for Kubernetes
- Implement pod security policies (where supported)
- Use managed identities for Azure resource access
- Regular security updates and patching
- Enable audit logging for all Kubernetes API calls

## Design Decisions

### 1. Two-Tier Network Architecture

**Decision**: Separate frontend and backend networks in Docker Compose

**Rationale**: 
- Prevents direct external access to database and message queue
- Improves security posture
- Aligns with defense-in-depth principles
- Makes network policies easier to implement in Kubernetes

### 2. Helm Charts over Raw Kubernetes Manifests

**Decision**: Use Helm for application deployment

**Rationale**:
- Better templating and value management
- Supports multi-environment deployments
- Easier upgrades and rollbacks
- Industry standard for Kubernetes deployments
- Includes dependency management (PostgreSQL, Redis via Bitnami charts)

### 3. Terraform Modules

**Decision**: Modularize Terraform code into reusable modules

**Rationale**:
- DRY principle (Don't Repeat Yourself)
- Easier maintenance and updates
- Consistent infrastructure across environments
- Better testing and validation

### 4. Non-root Containers

**Decision**: All containers run as non-root users

**Rationale**:
- Reduces attack surface
- Compliance with security best practices
- Required for Pod Security Admission (PSA)
- Defense-in-depth security

### 5. Resource Limits and Requests

**Decision**: Define resource limits and requests for all containers

**Rationale**:
- Prevents resource starvation
- Enables better scheduling decisions
- Supports Horizontal Pod Autoscaling
- Improves cluster stability

### 6. Health Checks

**Decision**: Implement liveness and readiness probes

**Rationale**:
- Enables Kubernetes to detect and restart unhealthy pods
- Prevents traffic routing to unready pods
- Improves application reliability
- Better user experience

## Trade-offs

### 1. Azure AKS vs. Local Cluster

**Azure AKS:**
- ✅ Fully managed service
- ✅ High availability
- ✅ Azure-native integrations
- ✅ Automatic updates and patching
- ❌ Requires Azure subscription
- ❌ Cost implications

**Local Cluster (minikube/k3s/microk8s):**
- ✅ No cost
- ✅ Easy to set up for development
- ✅ Full control
- ❌ Not suitable for production
- ❌ Manual maintenance required
- ❌ Limited scalability

**Decision**: Support both with clear documentation of trade-offs

### 2. Helm Charts vs. Kustomize

**Helm:**
- ✅ Mature ecosystem
- ✅ Dependency management
- ✅ Better templating
- ✅ Wide industry adoption

**Kustomize:**
- ✅ Native Kubernetes tool
- ✅ Simpler for basic use cases
- ❌ Limited templating
- ❌ No built-in dependency management

**Decision**: Use Helm for production deployments, provide Kustomize manifests as alternative

### 3. Bitnami Helm Charts vs. Custom Deployments

**Bitnami Charts:**
- ✅ Well-maintained
- ✅ Production-ready defaults
- ✅ Regular updates
- ✅ Good documentation
- ❌ Less customization

**Custom Deployments:**
- ✅ Full control
- ✅ Custom configurations
- ❌ More maintenance overhead
- ❌ Need to implement best practices ourselves

**Decision**: Use Bitnami charts for PostgreSQL and Redis, custom deployments for application services

### 4. Secrets Management

**Kubernetes Secrets:**
- ✅ Native Kubernetes solution
- ✅ Simple to implement
- ❌ Base64 encoded (not encrypted by default)
- ❌ No automatic rotation

**Azure Key Vault:**
- ✅ Enterprise-grade security
- ✅ Automatic rotation
- ✅ Audit logging
- ✅ Integration with Azure AD
- ❌ Requires additional setup
- ❌ Azure-specific

**Decision**: Use Kubernetes Secrets for development, document Azure Key Vault integration for production

### 5. Monitoring Stack

**Prometheus + Grafana:**
- ✅ Open-source
- ✅ Highly configurable
- ✅ Strong community
- ✅ Excellent alerting
- ❌ Requires more setup
- ❌ Manual maintenance

**Azure Monitor:**
- ✅ Fully managed
- ✅ Azure-native
- ✅ Easy integration
- ❌ Cost implications
- ❌ Less flexibility

**Decision**: Provide Prometheus + Grafana setup with documentation, mention Azure Monitor as alternative

## Troubleshooting

### Docker Compose Issues

**Services not starting:**
```bash
docker compose logs <service-name>
docker compose ps
```

**Network connectivity issues:**
```bash
docker network ls
docker network inspect <network-name>
```

### Kubernetes Issues

**Pods not starting:**
```bash
kubectl get pods -n voting-app
kubectl describe pod <pod-name> -n voting-app
kubectl logs <pod-name> -n voting-app
```

**Services not accessible:**
```bash
kubectl get svc -n voting-app
kubectl get ingress -n voting-app
```

**Network Policy issues:**
```bash
kubectl get networkpolicies -n voting-app
kubectl describe networkpolicy <policy-name> -n voting-app
```

### CI/CD Issues

Check GitHub Actions logs for specific job failures. Common issues:
- Missing secrets
- Authentication failures
- Image push failures
- Deployment timeouts

## Future Improvements

1. **Service Mesh**: Implement Istio or Linkerd for advanced traffic management
2. **GitOps**: Migrate to ArgoCD or Flux for declarative GitOps workflows
3. **Advanced Monitoring**: Implement distributed tracing with Jaeger
4. **Chaos Engineering**: Add chaos testing with Chaos Mesh
5. **Cost Optimization**: Implement cluster autoscaling and resource optimization
6. **Backup Strategy**: Automated backups for PostgreSQL
7. **Multi-region Deployment**: Active-active deployment across regions
8. **API Gateway**: Implement Azure API Management for API governance

## 📹 Demo Video

**Video Walkthrough:** [Link to be added]

For recording your own demo, see [DEMO_SCRIPT.md](DEMO_SCRIPT.md) for a detailed script and recording tips.

## 📊 Project Statistics

- **Total Services:** 4 (vote, result, worker, seed-data)
- **Kubernetes Resources:** 30+ (Deployments, Services, ConfigMaps, Secrets, NetworkPolicies, etc.)
- **Helm Charts:** 1 main chart + 2 dependencies (PostgreSQL, Redis)
- **CI/CD Workflows:** 3 (Build/Test, Security, Monitoring)
- **Terraform Modules:** 2 (AKS, Network)
- **Lines of Code:** 5000+
- **Documentation:** 4 comprehensive guides

## 🎯 Challenge Completion Checklist

### Phase 1: Containerization ✅
- ✅ All services containerized with efficient Dockerfiles
- ✅ Non-root users in all containers
- ✅ Docker Compose with two-tier networking
- ✅ Health checks for Redis and PostgreSQL
- ✅ Exposed ports: 8080 (vote), 8081 (result)
- ✅ Seed data service included

### Phase 2: Infrastructure & Deployment ✅
- ✅ Kubernetes cluster (Minikube) provisioned
- ✅ Terraform code for Azure AKS (production-ready)
- ✅ Multi-environment support (dev/prod)
- ✅ Kubernetes manifests with ConfigMaps, Secrets, resource limits
- ✅ Non-root policies enforced (PSA restricted mode)
- ✅ NetworkPolicies isolating database tier
- ✅ Production-grade Helm chart
- ✅ PostgreSQL and Redis via Bitnami Helm charts
- ✅ Trade-offs documented

### Phase 3: Automation, Security & Observability ✅
- ✅ CI/CD pipeline (GitHub Actions)
- ✅ Automated Docker image builds and pushes to GHCR
- ✅ Security scans (Trivy, Bandit, ESLint, OWASP ZAP)
- ✅ Automated tests
- ✅ Terraform validation
- ✅ Prometheus + Grafana monitoring
- ✅ ServiceMonitors and alerting rules
- ✅ RBAC implemented
- ✅ Secrets management

### Documentation ✅
- ✅ Comprehensive README
- ✅ Local deployment guide
- ✅ Testing guide
- ✅ Demo video script
- ✅ Architecture diagram
- ✅ Design decisions documented
- ✅ Trade-offs explained

## 🚀 Quick Start Commands

```bash
# 1. Start with Docker Compose
docker compose up -d

# 2. Or deploy to Minikube
minikube start --driver=docker --cpus=4 --memory=8192
eval $(minikube docker-env)
docker build -t ghcr.io/mohammed-makram/vote:latest ./vote
docker build -t ghcr.io/mohammed-makram/result:latest ./result
docker build -t ghcr.io/mohammed-makram/worker:latest ./worker
cd helm/voting-app && helm dependency update
helm upgrade --install voting-app . -n voting-app --create-namespace --values values-dev.yaml

# 3. Access the application
kubectl port-forward -n voting-app svc/voting-app-vote 8080:80
kubectl port-forward -n voting-app svc/voting-app-result 8081:4000
```

## 📚 Additional Documentation

- [LOCAL_DEPLOYMENT.md](LOCAL_DEPLOYMENT.md) - Complete local cluster setup guide
- [DEMO_SCRIPT.md](DEMO_SCRIPT.md) - Video recording script and tips
- [TESTING_GUIDE.md](TESTING_GUIDE.md) - Testing and validation procedures
- [terraform/README.md](terraform/README.md) - Infrastructure as Code documentation

## 👨‍💻 Author

**Mohammed Makram**
- GitHub: [@mohammed-makram](https://github.com/mohammed-makram)
- Repository: [devops-Quest](https://github.com/mohammed-makram/devops-Quest)

## 📝 License

This project is part of the Tactful.ai Junior DevOps Engineer hiring challenge.

## 🙏 Acknowledgments

- Tactful.ai for the challenging and comprehensive hiring quest
- Code Quest platform for organizing the challenge
- Open source community for amazing tools (Docker, Kubernetes, Helm, Terraform, Prometheus, Grafana)

 
 