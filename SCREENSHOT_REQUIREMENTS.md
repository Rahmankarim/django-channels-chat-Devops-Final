# Screenshot Requirements for DevOps Project Submission

This document lists all required screenshots for project submission.

## 📸 Required Screenshots

### Step 1: Containerization [Already Complete]
- ✅ Dockerfile (multistage build)
- ✅ docker-compose.yml
- Need to capture:
  - [ ] `docker-compose ps` - Running containers
  - [ ] `docker images` - Built images with sizes
  - [ ] Application running in browser (localhost:8000/chat/)
  - [ ] Grafana dashboard (localhost:3000)

### Step 2: Terraform Infrastructure [10 Marks]
Required screenshots:
- [ ] `terraform init` output
- [ ] `terraform plan` output
- [ ] `terraform apply` completion
- [ ] `terraform output` showing:
  - VPC ID
  - EKS cluster endpoint
  - RDS endpoint
  - Redis endpoint
- [ ] AWS Console showing:
  - VPC with subnets
  - EKS cluster details
  - RDS instance
  - ElastiCache cluster
  - Security groups
- [ ] `terraform destroy` confirmation

### Step 4: Ansible Configuration [5 Marks]
Required screenshots:
- [ ] `ansible-playbook` command execution
- [ ] Playbook run output showing:
  - Task completion
  - No failures
  - Recap summary
- [ ] Inventory file configuration
- [ ] Successful deployment verification

### Step 5: Kubernetes Deployment [10 Marks]
Required screenshots:
- [ ] `kubectl get nodes` - Cluster nodes
- [ ] `kubectl get pods -n django-chat` - Running pods
- [ ] `kubectl get svc -n django-chat` - Services
- [ ] `kubectl describe pod <pod-name> -n django-chat` - Pod details showing:
  - Events
  - Container status
  - Resource usage
- [ ] `kubectl get ingress -n django-chat` - Ingress configuration
- [ ] `kubectl get hpa -n django-chat` - HorizontalPodAutoscaler
- [ ] Application accessible via LoadBalancer URL

### Step 6: CI/CD Pipeline [10 Marks]
Required screenshots:
- [ ] GitHub Actions workflow file
- [ ] Pipeline execution showing all 8 stages:
  1. Lint & Security
  2. Build & Test
  3. Docker Build & Push
  4. Terraform Plan
  5. Terraform Apply
  6. Ansible Deploy
  7. K8s Deploy
  8. Smoke Tests
- [ ] All stages passed (green checkmarks)
- [ ] Docker Hub showing pushed image
- [ ] Security scan results (Trivy/Bandit)

### Step 7: Monitoring & Observability [10 Marks]
Required screenshots:

**Prometheus**:
- [ ] Prometheus targets page showing:
  - django-chat (UP)
  - postgres (UP)
  - redis (UP)
  - node-exporter (UP)
- [ ] Prometheus alerts page
- [ ] Sample PromQL query with results

**Grafana**:
- [ ] Grafana login/home page
- [ ] Dashboard list
- [ ] Application Overview Dashboard showing:
  - Request rate graph
  - Response time (p95)
  - HTTP status codes
  - Active WebSocket connections
  - CPU/Memory usage
- [ ] Database & Redis Dashboard showing:
  - PostgreSQL connections
  - Transaction rate
  - Redis memory usage
  - Cache hit rate
- [ ] Alert configuration

### Step 8: Documentation [5 Marks]
Required files (already created):
- ✅ README.md (comprehensive)
- ✅ devops_report.md (complete report)
- ✅ Infrastructure diagram
- ✅ Pipeline diagram
- ✅ Secret management strategy
- ✅ Monitoring strategy
- ✅ Lessons learned

## 📁 Screenshot Organization

Create this folder structure:

```
screenshots/
├── 01-containerization/
│   ├── docker-compose-ps.png
│   ├── docker-images.png
│   ├── app-running.png
│   └── grafana-dashboard.png
├── 02-terraform/
│   ├── terraform-init.png
│   ├── terraform-plan.png
│   ├── terraform-apply.png
│   ├── terraform-output.png
│   ├── aws-vpc.png
│   ├── aws-eks.png
│   ├── aws-rds.png
│   ├── aws-elasticache.png
│   └── terraform-destroy.png
├── 04-ansible/
│   ├── ansible-playbook-run.png
│   ├── playbook-success.png
│   └── inventory-config.png
├── 05-kubernetes/
│   ├── kubectl-get-nodes.png
│   ├── kubectl-get-pods.png
│   ├── kubectl-get-svc.png
│   ├── kubectl-describe-pod.png
│   ├── kubectl-get-ingress.png
│   ├── kubectl-get-hpa.png
│   └── app-on-k8s.png
├── 06-cicd/
│   ├── github-actions-workflow.png
│   ├── pipeline-all-stages.png
│   ├── stage-1-lint.png
│   ├── stage-2-test.png
│   ├── stage-3-docker.png
│   ├── stage-4-terraform-plan.png
│   ├── stage-5-terraform-apply.png
│   ├── stage-6-ansible.png
│   ├── stage-7-k8s-deploy.png
│   ├── stage-8-smoke-tests.png
│   ├── docker-hub-image.png
│   └── security-scan.png
└── 07-monitoring/
    ├── prometheus-targets.png
    ├── prometheus-alerts.png
    ├── prometheus-query.png
    ├── grafana-home.png
    ├── grafana-dashboard-list.png
    ├── grafana-app-dashboard-1.png
    ├── grafana-app-dashboard-2.png
    ├── grafana-db-dashboard.png
    └── grafana-alerts.png
```

## 🚀 How to Capture Screenshots

### For Local Development (Docker Compose)

```bash
# 1. Start services
docker-compose up -d

# 2. Capture screenshots
docker-compose ps          # Screenshot this
docker images              # Screenshot this
# Open http://localhost:8000/chat/ in browser and screenshot
# Open http://localhost:3000 and screenshot Grafana

# 3. Access monitoring
open http://localhost:9090  # Prometheus
open http://localhost:3000  # Grafana (admin/admin)
```

### For Terraform

```bash
cd infra

# Initialize (screenshot output)
terraform init

# Plan (screenshot output)
terraform plan -out=tfplan

# Apply (screenshot output and final summary)
terraform apply

# Outputs (screenshot)
terraform output

# Go to AWS Console and screenshot:
# - VPC Dashboard
# - EKS Cluster
# - RDS Databases
# - ElastiCache Clusters
```

### For Kubernetes

```bash
# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name django-chat-cluster

# Capture all these
kubectl get nodes
kubectl get pods -n django-chat
kubectl get svc -n django-chat
kubectl get ingress -n django-chat
kubectl describe pod <pod-name> -n django-chat
kubectl get hpa -n django-chat

# Get LoadBalancer URL and access in browser
kubectl get svc django-chat-lb -n django-chat
```

### For CI/CD

```bash
# Push code to trigger pipeline
git push origin main

# Go to GitHub Actions tab and screenshot:
# - Full pipeline view
# - Each stage details
# - Success status
```

### For Monitoring

```bash
# Port-forward to access services
kubectl port-forward -n monitoring svc/prometheus 9090:9090
kubectl port-forward -n monitoring svc/grafana 3000:3000

# Open browsers and screenshot:
# - Prometheus: http://localhost:9090
# - Grafana: http://localhost:3000
```

## ✅ Submission Checklist

### Code & Configuration Files
- [ ] All Terraform files (infra/)
- [ ] All Kubernetes manifests (k8s/)
- [ ] Ansible playbooks (ansible/)
- [ ] Dockerfile (optimized)
- [ ] docker-compose.yml
- [ ] GitHub Actions workflow (.github/workflows/)
- [ ] Monitoring configs (monitoring/)

### Documentation
- [ ] README.md (comprehensive)
- [ ] devops_report.md (detailed)
- [ ] Individual README files in each directory
- [ ] Architecture diagrams
- [ ] Pipeline flow diagrams

### Screenshots (Organized in folders)
- [ ] Terraform infrastructure (AWS Console + CLI)
- [ ] Kubernetes deployment
- [ ] CI/CD pipeline
- [ ] Monitoring dashboards
- [ ] Ansible playbook execution

### Proof of Completion
- [ ] Terraform output showing resources
- [ ] kubectl describe pod output
- [ ] GitHub Actions green checkmarks
- [ ] Grafana dashboards with data
- [ ] Terraform destroy confirmation

## 📤 How to Submit

1. Create a GitHub repository with all code
2. Organize screenshots in the `screenshots/` folder
3. Ensure all documentation is complete
4. Create a submission document with:
   - Repository link
   - Screenshot links/attachments
   - Video demo link (optional but recommended)
5. Submit via your learning management system

## 🎥 Optional: Video Demo

Record a short video (10-15 minutes) demonstrating:
1. Local development with Docker Compose
2. Terraform provisioning infrastructure
3. Kubernetes deployment
4. CI/CD pipeline execution
5. Monitoring dashboards

## 📝 Notes

- All screenshots should be clear and readable
- Include terminal commands used
- Show timestamps where relevant
- Highlight key information in screenshots
- Ensure no sensitive information (passwords, keys) visible

## 🏆 Grading Rubric Reference

| Component | Marks | Status |
|-----------|-------|--------|
| Containerization | Auto | ✅ |
| Terraform | 10 | Need screenshots |
| Ansible | 5 | Need screenshots |
| Kubernetes | 10 | Need screenshots |
| CI/CD | 10 | Need screenshots |
| Monitoring | 10 | Need screenshots |
| Documentation | 5 | ✅ Complete |
| **Total** | **50** | **In Progress** |

Good luck with your submission! 🚀
