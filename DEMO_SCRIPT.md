# Demo Video Script (15 Minutes)

This script will guide you through recording a comprehensive demo video for the DevOps challenge.

**Target Duration:** 12-14 minutes (leave buffer for 15 min limit)

---

## 🎬 Pre-Recording Checklist

### Setup Before Recording:

```bash
# 1. Start Minikube
minikube start --driver=docker --cpus=4 --memory=8192
minikube addons enable ingress metrics-server

# 2. Build images
eval $(minikube docker-env)
docker build -t ghcr.io/mohammed-makram/vote:latest ./vote
docker build -t ghcr.io/mohammed-makram/result:latest ./result
docker build -t ghcr.io/mohammed-makram/worker:latest ./worker

# 3. Deploy application
cd helm/voting-app
helm dependency update
helm upgrade --install voting-app . \
  --namespace voting-app \
  --create-namespace \
  --values values-dev.yaml \
  --set vote.image.pullPolicy=IfNotPresent \
  --set result.image.pullPolicy=IfNotPresent \
  --set worker.image.pullPolicy=IfNotPresent

# 4. Setup port forwarding in separate terminals
kubectl port-forward -n voting-app svc/voting-app-vote 8080:80
kubectl port-forward -n voting-app svc/voting-app-result 8081:4000

# 5. Have these files open in VS Code:
# - README.md
# - docker-compose.yml
# - helm/voting-app/values.yaml
# - .github/workflows/ci-cd.yml
# - terraform/modules/aks/main.tf
# - monitoring/servicemonitor.yaml
```

### Tools Ready:
- ✅ Browser with tabs: localhost:8080, localhost:8081, GitHub repo
- ✅ Terminal windows ready
- ✅ VS Code with project open
- ✅ Microphone tested

---

## 📝 Script Outline

### **[0:00 - 1:00] Introduction**

**Script:**
> "Hello! My name is Mohammed Makram, and this is my submission for the Junior DevOps Engineer hiring quest at Tactful.ai.
>
> In this demo, I'll walk you through a production-ready voting application that I've containerized, deployed on Kubernetes, and automated with CI/CD pipelines.
>
> The project demonstrates expertise in Docker, Kubernetes, Helm, Terraform, CI/CD, security best practices, and monitoring.
>
> Let me show you the architecture first."

**Actions:**
- Open `architecture.excalidraw.png` or draw on whiteboard
- Briefly explain: Vote → Redis → Worker → PostgreSQL → Result
- Mention two-tier networking (frontend/backend)

---

### **[1:00 - 4:00] Phase 1: Docker Compose & Local Setup**

**Script:**
> "Let's start with Phase 1: Containerization and local setup.
>
> I've containerized all four services: vote, result, worker, and seed-data. Each service runs as a non-root user for security.
>
> Let me show you the Docker Compose setup."

**Actions:**

1. **Show docker-compose.yml** (30 sec)
```bash
code docker-compose.yml
```
- Point out two-tier networking (frontend/backend)
- Show health checks for Redis and PostgreSQL
- Mention security options (no-new-privileges)

2. **Show Dockerfile** (30 sec)
```bash
code vote/Dockerfile
```
- Highlight non-root user creation
- Efficient multi-stage builds (for worker)

3. **Run Docker Compose** (1 min)
```bash
# Show it's not running
docker compose ps

# Start all services
docker compose up -d

# Show all services healthy
docker compose ps

# Show logs briefly
docker compose logs vote --tail=10
```

4. **Demo the Application** (1 min)
- Open browser: http://localhost:8080
- Cast a vote (Cats vs Dogs)
- Open browser: http://localhost:8081
- Show real-time results updating
- Explain the data flow

**Script:**
> "As you can see, the application is fully functional. Votes go through Redis, get processed by the worker, stored in PostgreSQL, and displayed in real-time on the result page."

---

### **[4:00 - 9:00] Phase 2: Kubernetes & Infrastructure**

**Script:**
> "Now let's move to Phase 2: Infrastructure and Kubernetes deployment.
>
> I've created Terraform modules for Azure AKS, but since I don't have an Azure subscription, I'm deploying to a local Minikube cluster. The infrastructure code is production-ready for Azure."

**Actions:**

1. **Show Terraform Structure** (1 min)
```bash
tree terraform/ -L 2
code terraform/modules/aks/main.tf
```
- Explain modular structure
- Multi-environment support (dev/prod)
- Show AKS configuration with RBAC, network policies

**Script:**
> "The Terraform code provisions a fully-configured AKS cluster with:
> - Managed identity and Azure AD RBAC
> - Network policies using Calico
> - Auto-scaling enabled
> - Log Analytics integration
> - Separate node pools for system and user workloads"

2. **Show Kubernetes Manifests** (1 min)
```bash
tree k8s/base/
code k8s/base/network-policies.yaml
```
- Show NetworkPolicies isolating backend
- Show PSA (Pod Security Admission) - restricted mode
- Show RBAC configuration

3. **Show Helm Chart** (1.5 min)
```bash
tree helm/voting-app/
code helm/voting-app/Chart.yaml
code helm/voting-app/values.yaml
```
- Explain production-grade Helm chart
- Dependencies: Bitnami PostgreSQL and Redis
- ConfigMaps, Secrets, resource limits
- HPA (Horizontal Pod Autoscaling)

**Script:**
> "I've created a production-grade Helm chart that includes:
> - Bitnami charts for PostgreSQL and Redis with persistence
> - Resource limits and requests for all services
> - Network policies for isolation
> - Pod Security Admission in restricted mode
> - Horizontal Pod Autoscaling
> - Ingress configuration"

4. **Show Running Deployment** (1.5 min)
```bash
# Show cluster info
kubectl cluster-info
kubectl get nodes

# Show all resources
kubectl get all -n voting-app

# Show pods with details
kubectl get pods -n voting-app -o wide

# Show network policies
kubectl get networkpolicies -n voting-app

# Describe a pod to show security context
kubectl describe pod -n voting-app -l app=vote | grep -A 10 "Security Context"
```

**Script:**
> "All pods are running with non-root users, resource limits, and proper health checks. Network policies ensure backend services are isolated from direct external access."

---

### **[9:00 - 12:00] Phase 3: CI/CD, Security & Monitoring**

**Script:**
> "Phase 3 covers CI/CD automation, security scanning, and observability."

**Actions:**

1. **Show CI/CD Pipeline** (1.5 min)
```bash
code .github/workflows/ci-cd.yml
```
- Explain build and push to GHCR
- Security scanning with Trivy
- Automated tests
- Terraform validation
- Deployment automation (commented for local)

**Script:**
> "The CI/CD pipeline:
> - Builds Docker images for all services
> - Pushes to GitHub Container Registry
> - Runs Trivy security scans for vulnerabilities
> - Executes unit tests
> - Validates Terraform configurations
> - Can auto-deploy to dev/prod environments"

2. **Show Security Workflow** (1 min)
```bash
code .github/workflows/security.yml
```
- SAST with Bandit (Python) and ESLint (Node.js)
- DAST with OWASP ZAP
- Container scanning
- Scheduled weekly scans

**Script:**
> "Security is integrated throughout:
> - SAST for static code analysis
> - DAST for runtime vulnerability testing
> - Container image scanning
> - Non-root containers
> - Network policies
> - Pod Security Admission
> - Secrets management (with Azure Key Vault recommendation for production)"

3. **Show Monitoring** (1.5 min)
```bash
code monitoring/servicemonitor.yaml
```
- Explain Prometheus + Grafana setup
- ServiceMonitor for metrics collection
- Alerting rules

```bash
# If monitoring is deployed, show it
kubectl get pods -n monitoring
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```
- Open Grafana dashboard
- Show metrics being collected

**Script:**
> "For observability, I've configured:
> - Prometheus for metrics collection
> - Grafana for visualization
> - ServiceMonitors for all application services
> - Alert rules for high error rates, pod crashes, and resource issues"

---

### **[12:00 - 13:30] Design Decisions & Trade-offs**

**Script:**
> "Let me quickly explain some key design decisions:
>
> **1. Local Cluster vs Azure AKS:**
> I deployed on Minikube due to Azure subscription limitations. The trade-offs are:
> - No managed updates or Azure-native integrations
> - No high availability across zones
> - But all Kubernetes features work identically
> - The Terraform code is production-ready for Azure
>
> **2. Helm over Kustomize:**
> I chose Helm for better templating, dependency management, and multi-environment support.
>
> **3. Bitnami Charts:**
> Using well-maintained Bitnami charts for PostgreSQL and Redis ensures production-ready defaults and regular security updates.
>
> **4. Two-Tier Networking:**
> Separating frontend and backend networks improves security by preventing direct external access to databases.
>
> **5. Non-Root Containers:**
> All services run as non-root users, meeting Pod Security Admission requirements and reducing attack surface."

**Actions:**
- Show README.md sections on design decisions
- Scroll through trade-offs section

---

### **[13:30 - 14:30] Documentation & Repository**

**Script:**
> "The repository includes comprehensive documentation:
> - README with full setup instructions
> - LOCAL_DEPLOYMENT guide for Minikube/k3s
> - TESTING_GUIDE for validation
> - Architecture diagrams
> - Clear comments in all configuration files"

**Actions:**
```bash
# Show repository structure
tree -L 2

# Open README
code README.md
```
- Scroll through README sections
- Show clear structure

**Script:**
> "Everything is well-documented with:
> - Step-by-step deployment instructions
> - Troubleshooting guides
> - Design rationale
> - Trade-off analysis
> - Future improvements"

---

### **[14:30 - 15:00] Conclusion & Demo**

**Script:**
> "Let me do a final demonstration of the working application."

**Actions:**
- Open http://localhost:8080
- Cast multiple votes
- Open http://localhost:8081
- Show results updating in real-time

**Script:**
> "To summarize, this project demonstrates:
> ✅ Containerization with Docker and Docker Compose
> ✅ Infrastructure as Code with Terraform
> ✅ Kubernetes deployment with Helm
> ✅ Production-grade security (PSA, NetworkPolicies, RBAC, non-root containers)
> ✅ Full CI/CD automation with GitHub Actions
> ✅ Security scanning (SAST, DAST, container scanning)
> ✅ Monitoring with Prometheus and Grafana
> ✅ Comprehensive documentation
>
> The repository is at: github.com/mohammed-makram/devops-Quest
>
> Thank you for watching! I'm excited about the opportunity to join Tactful.ai and contribute to your DevOps team."

---

## 🎥 Recording Tips

1. **Practice First:** Do a full dry run before recording
2. **Keep It Smooth:** If you make a mistake, pause and continue - you can edit later
3. **Clear Audio:** Use a good microphone, minimize background noise
4. **Screen Resolution:** Use 1920x1080 for clarity
5. **Font Size:** Increase terminal and editor font size for visibility
6. **Pace:** Speak clearly and not too fast
7. **Enthusiasm:** Show passion for the work!

---

## 📤 After Recording

1. **Edit Video:** Remove long pauses, mistakes
2. **Add Captions:** (Optional) Add subtitles for clarity
3. **Upload:** Upload to Google Drive or YouTube (unlisted)
4. **Test Link:** Make sure the link works and is accessible
5. **Add to README:** Include the video link in your README.md

---

## 🎬 Alternative: Shorter Version (10 min)

If you need a shorter version:
- **Skip:** Detailed code walkthroughs
- **Focus on:** Live demos and running systems
- **Show:** Results, not process

Good luck with your recording! 🚀
