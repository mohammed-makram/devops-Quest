# Local Kubernetes Deployment Guide

This guide explains how to deploy the voting application on a **local Kubernetes cluster** (Minikube, k3s, or MicroK8s) instead of Azure AKS.

## 📋 Prerequisites

- Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- kubectl
- Helm 3.x
- One of the following:
  - **Minikube** (Recommended for Windows)
  - **k3s** (Lightweight, Linux/WSL2)
  - **MicroK8s** (Ubuntu/Linux)

---

## 🚀 Quick Start with Minikube (Recommended)

### 1. Install Minikube

**Windows (PowerShell):**
```powershell
# Using Chocolatey
choco install minikube

# Or download from: https://minikube.sigs.k8s.io/docs/start/
```

**Linux/Mac:**
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### 2. Start Minikube Cluster

```bash
# Start with sufficient resources
minikube start --driver=docker --cpus=4 --memory=8192 --disk-size=20g

# Enable required addons
minikube addons enable ingress
minikube addons enable metrics-server

# Verify cluster is running
kubectl get nodes
```

### 3. Build and Push Images to Minikube

**Option A: Build directly in Minikube (Faster)**
```bash
# Point Docker to Minikube's Docker daemon
eval $(minikube docker-env)

# Build all images
docker build -t ghcr.io/mohammed-makram/vote:latest ./vote
docker build -t ghcr.io/mohammed-makram/result:latest ./result
docker build -t ghcr.io/mohammed-makram/worker:latest ./worker
docker build -t ghcr.io/mohammed-makram/seed-data:latest ./seed-data

# Verify images
docker images | grep mohammed-makram
```

**Option B: Use GitHub Container Registry**
```bash
# Login to GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u mohammed-makram --password-stdin

# Build and push (CI/CD will do this automatically)
docker build -t ghcr.io/mohammed-makram/vote:latest ./vote
docker push ghcr.io/mohammed-makram/vote:latest

# Repeat for other services...
```

### 4. Deploy with Helm

```bash
# Add Bitnami repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Navigate to Helm chart
cd helm/voting-app

# Update dependencies (PostgreSQL and Redis)
helm dependency update

# Deploy to local cluster
helm upgrade --install voting-app . \
  --namespace voting-app \
  --create-namespace \
  --values values-dev.yaml \
  --set vote.image.pullPolicy=IfNotPresent \
  --set result.image.pullPolicy=IfNotPresent \
  --set worker.image.pullPolicy=IfNotPresent

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=voting-app -n voting-app --timeout=300s
```

### 5. Access the Application

```bash
# Get Minikube IP
minikube ip

# Add to /etc/hosts (Linux/Mac) or C:\Windows\System32\drivers\etc\hosts (Windows)
# Replace <MINIKUBE_IP> with the actual IP
echo "<MINIKUBE_IP> vote.local result.local" | sudo tee -a /etc/hosts

# Or use port forwarding (easier)
kubectl port-forward -n voting-app svc/voting-app-vote 8080:80
kubectl port-forward -n voting-app svc/voting-app-result 8081:4000

# Access in browser
# Vote: http://localhost:8080
# Result: http://localhost:8081
```

### 6. Verify Deployment

```bash
# Check all pods
kubectl get pods -n voting-app

# Check services
kubectl get svc -n voting-app

# Check ingress
kubectl get ingress -n voting-app

# View logs
kubectl logs -n voting-app -l app=vote --tail=50
kubectl logs -n voting-app -l app=result --tail=50
kubectl logs -n voting-app -l app=worker --tail=50
```

---

## 🔧 Alternative: k3s (Linux/WSL2)

### 1. Install k3s

```bash
# Install k3s
curl -sfL https://get.k3s.io | sh -

# Set kubeconfig
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

# Verify
kubectl get nodes
```

### 2. Deploy Application

```bash
# Same Helm commands as Minikube
helm upgrade --install voting-app ./helm/voting-app \
  --namespace voting-app \
  --create-namespace \
  --values helm/voting-app/values-dev.yaml
```

---

## 🔧 Alternative: MicroK8s (Ubuntu/Linux)

### 1. Install MicroK8s

```bash
# Install
sudo snap install microk8s --classic

# Add user to group
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
newgrp microk8s

# Enable addons
microk8s enable dns storage ingress metrics-server

# Alias kubectl
alias kubectl='microk8s kubectl'
```

### 2. Deploy Application

```bash
# Same Helm commands
microk8s helm3 upgrade --install voting-app ./helm/voting-app \
  --namespace voting-app \
  --create-namespace \
  --values helm/voting-app/values-dev.yaml
```

---

## 📊 Deploy Monitoring Stack

```bash
# Add Prometheus Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus + Grafana
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

# Apply ServiceMonitor
kubectl apply -f monitoring/servicemonitor.yaml

# Access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Default credentials: admin / prom-operator
```

---

## 🧪 Testing

### Run Smoke Tests

```bash
# Check if all pods are running
kubectl get pods -n voting-app

# Test vote service
curl http://localhost:8080

# Test result service
curl http://localhost:8081

# Check database connectivity
kubectl exec -n voting-app -it deployment/voting-app-postgresql -- psql -U postgres -c "SELECT * FROM votes;"
```

### Seed Test Data

```bash
# Run seed data job
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: seed-data
  namespace: voting-app
spec:
  template:
    spec:
      containers:
      - name: seed
        image: ghcr.io/mohammed-makram/seed-data:latest
        imagePullPolicy: IfNotPresent
      restartPolicy: Never
EOF

# Check job status
kubectl get jobs -n voting-app
kubectl logs -n voting-app job/seed-data
```

---

## 🔍 Troubleshooting

### Pods Not Starting

```bash
# Describe pod to see events
kubectl describe pod <pod-name> -n voting-app

# Check logs
kubectl logs <pod-name> -n voting-app

# Check resource constraints
kubectl top pods -n voting-app
```

### Image Pull Errors

```bash
# If using GHCR, create image pull secret
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=mohammed-makram \
  --docker-password=$GITHUB_TOKEN \
  --namespace=voting-app

# Update Helm values to use secret
helm upgrade voting-app ./helm/voting-app \
  --namespace voting-app \
  --set imagePullSecrets[0].name=ghcr-secret
```

### Network Issues

```bash
# Check network policies
kubectl get networkpolicies -n voting-app

# Temporarily disable for testing
kubectl delete networkpolicy --all -n voting-app

# Check service endpoints
kubectl get endpoints -n voting-app
```

### Database Connection Issues

```bash
# Check PostgreSQL pod
kubectl logs -n voting-app -l app.kubernetes.io/name=postgresql

# Connect to PostgreSQL
kubectl exec -n voting-app -it deployment/voting-app-postgresql -- psql -U postgres

# Check Redis
kubectl exec -n voting-app -it deployment/voting-app-redis-master -- redis-cli ping
```

---

## 🧹 Cleanup

```bash
# Delete application
helm uninstall voting-app -n voting-app

# Delete namespace
kubectl delete namespace voting-app

# Delete monitoring
helm uninstall prometheus -n monitoring
kubectl delete namespace monitoring

# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete
```

---

## 📝 Trade-offs: Local vs Azure AKS

### Local Cluster Limitations:
- ❌ No managed Kubernetes updates
- ❌ No Azure-native integrations (Key Vault, Azure AD, etc.)
- ❌ No high availability across zones
- ❌ Limited scalability
- ❌ No production-grade load balancing
- ❌ Manual maintenance required

### Local Cluster Advantages:
- ✅ No cost
- ✅ Fast iteration and testing
- ✅ Full control over cluster
- ✅ Works offline
- ✅ Same Kubernetes APIs as cloud

### Production Recommendation:
For production workloads, use managed Kubernetes services like:
- Azure AKS
- AWS EKS
- Google GKE
- DigitalOcean Kubernetes

The Terraform code in this repository is production-ready for Azure AKS deployment.

---

## 🎯 Next Steps

1. ✅ Verify all pods are running: `kubectl get pods -n voting-app`
2. ✅ Access the application via port-forward or ingress
3. ✅ Test voting functionality
4. ✅ Check monitoring dashboards
5. ✅ Review logs for any errors
6. ✅ Prepare demo video showing the deployment

---

## 📚 Additional Resources

- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [k3s Documentation](https://k3s.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
