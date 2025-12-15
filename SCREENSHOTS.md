# Django Channels Chat - DevOps Assignment Screenshots

**Student:** Rahman Karim  
**Date:** December 16, 2025  
**Course:** CSC418 - DevOps for Cloud Computing

---

## 📸 SCREENSHOT CHECKLIST

### ✅ Step 1: Containerization (COMPLETE)

**Screenshot 1.1: Docker Compose Running**
```bash
# Command to verify:
docker ps
```
**Expected:** All 6 containers running (web, db, redis, prometheus, grafana, node-exporter)

**Screenshot 1.2: Application Accessible**
- URL: http://localhost:8000/chat/
- Show: Chat interface loaded successfully

**Screenshot 1.3: Docker Images**
```bash
docker images
```
**Expected:** Show django-channels-chat-main-web image

**Screenshot 1.4: Docker Networks**
```bash
docker network ls
docker network inspect django-channels-chat-main_app-network
```

**Screenshot 1.5: Persistent Volumes**
```bash
docker volume ls
```
**Expected:** postgres_data, redis_data, grafana_data, prometheus_data

---

### ⏳ Step 2: Terraform Infrastructure (NEED TO RUN)

**Screenshot 2.1: Terraform Files**
```bash
ls -la infra/
```
**Expected:** main.tf, vpc.tf, eks.tf, rds.tf, elasticache.tf, outputs.tf, variables.tf

**Screenshot 2.2: Terraform Init**
```bash
cd infra/
terraform init
```

**Screenshot 2.3: Terraform Plan**
```bash
terraform plan
```

**Screenshot 2.4: Terraform Apply (If Running)**
```bash
terraform apply -auto-approve
```

**Screenshot 2.5: Terraform Output**
```bash
terraform output
```

**Screenshot 2.6: AWS Console**
- VPC created
- EKS cluster
- RDS instance
- ElastiCache Redis

**Screenshot 2.7: Terraform Destroy**
```bash
terraform destroy -auto-approve
```

---

### ⏳ Step 4: Ansible Configuration (NEED TO RUN)

**Screenshot 4.1: Ansible Files**
```bash
ls -la ansible/
cat ansible/playbook.yml
cat ansible/hosts.ini
```

**Screenshot 4.2: Ansible Playbook Execution**
```bash
ansible-playbook -i ansible/hosts.ini ansible/playbook.yml -e "env=dev"
```
**Expected:** All tasks completed successfully with green OK status

**Screenshot 4.3: Ansible Output Summary**
Show PLAY RECAP with successful task counts

---

### ⏳ Step 5: Kubernetes Deployment (NEED TO RUN)

**Screenshot 5.1: Kubernetes Manifests**
```bash
ls -la k8s/
```
**Expected:** namespace.yaml, deployment.yaml, service.yaml, configmap.yaml, secret.yaml, ingress.yaml

**Screenshot 5.2: Apply Namespace**
```bash
kubectl apply -f k8s/namespace.yaml
kubectl get namespaces
```

**Screenshot 5.3: Apply All Manifests**
```bash
kubectl apply -f k8s/
```

**Screenshot 5.4: Get Pods**
```bash
kubectl get pods -n django-chat
```
**Expected:** 3 django-chat pods running

**Screenshot 5.5: Get Services**
```bash
kubectl get svc -n django-chat
```
**Expected:** django-chat service and django-chat-lb LoadBalancer

**Screenshot 5.6: Describe Pod**
```bash
kubectl describe pod <pod-name> -n django-chat
```

**Screenshot 5.7: Pod Logs**
```bash
kubectl logs -f <pod-name> -n django-chat
```

**Screenshot 5.8: Get Ingress**
```bash
kubectl get ingress -n django-chat
```

---

### ✅ Step 6: CI/CD Pipeline (IN PROGRESS)

**Screenshot 6.1: GitHub Actions Workflows**
- Show: .github/workflows/ci-cd.yml exists
- URL: https://github.com/Rahmankarim/django-channels-chat-Devops-Final/actions

**Screenshot 6.2: Pipeline Running**
- All stages visible: lint-and-security, build-and-test, docker-build

**Screenshot 6.3: All Stages Passed**
- Green checkmarks for all stages
- Stage 1: Lint & Security ✓
- Stage 2: Build & Test ✓
- Stage 3: Docker Build & Push ✓

**Screenshot 6.4: Build Logs**
- Show successful test execution
- Migration successful
- Tests passed

**Screenshot 6.5: Docker Hub**
- URL: https://hub.docker.com/r/rahmankarim1/django-channels-chat/tags
- Show: Image pushed with latest tag and commit SHA tag

**Screenshot 6.6: Security Scan Results**
- Bandit report (if generated)
- Trivy scan results

---

### ✅ Step 7: Monitoring & Observability (READY TO CAPTURE)

**Screenshot 7.1: Prometheus Running**
```bash
# Access: http://localhost:9090
```
- Show Prometheus dashboard
- Show targets (Status → Targets)
- All targets should be UP

**Screenshot 7.2: Prometheus Targets**
- Show: web:8000, postgres-exporter, redis-exporter, node-exporter all UP

**Screenshot 7.3: Prometheus Query**
- Example query: `up`
- Show graph with metrics

**Screenshot 7.4: Grafana Login**
```bash
# Access: http://localhost:3000
# Default: admin / admin
```

**Screenshot 7.5: Grafana Dashboard - Django Overview**
- Show: Request rate, response time, active users
- CPU usage, Memory usage

**Screenshot 7.6: Grafana Dashboard - Database Metrics**
- PostgreSQL connections
- Transaction rate
- Cache hit rate

**Screenshot 7.7: Grafana Dashboard - Redis Metrics**
- Memory usage
- Commands per second
- Connected clients

**Screenshot 7.8: Alert Rules**
```bash
cat monitoring/alerts/django-alerts.yml
```

---

### ✅ Step 8: Documentation (COMPLETE)

**Screenshot 8.1: README.md**
```bash
cat README.md | head -50
```

**Screenshot 8.2: DevOps Report**
```bash
cat DEVOPS_REPORT_COMPLETE.md | head -100
```

**Screenshot 8.3: Repository Structure**
```bash
tree -L 2
# Or: ls -R
```

**Screenshot 8.4: Git Commits**
```bash
git log --oneline --graph --all -20
```

**Screenshot 8.5: All Files Present**
Show complete project structure with all required files

---

## 🎯 QUICK CAPTURE COMMANDS

### For Local Docker Compose (Do Now):
```bash
# 1. Show all running containers
docker ps

# 2. Access application
curl http://localhost:8000/chat/ | head -20

# 3. Access Prometheus
curl http://localhost:9090/targets

# 4. Check logs
docker-compose logs web | tail -50

# 5. Show volumes
docker volume ls
```

### For Monitoring (Do Now):
1. Open browser: http://localhost:3000 (Grafana)
2. Login: admin / admin
3. Take screenshots of dashboards

### For CI/CD:
1. Go to: https://github.com/Rahmankarim/django-channels-chat-Devops-Final/actions
2. Wait for pipeline to complete
3. Screenshot each stage

---

## 📊 REQUIRED SCREENSHOTS SUMMARY

| Category | Screenshots Needed | Status |
|----------|-------------------|--------|
| **Containerization** | 5 screenshots | ✅ Ready to capture |
| **Terraform** | 7 screenshots | ⏳ Need AWS setup |
| **Ansible** | 3 screenshots | ⏳ Need to run playbook |
| **Kubernetes** | 8 screenshots | ⏳ Need K8s cluster |
| **CI/CD** | 6 screenshots | ⏳ Pipeline running |
| **Monitoring** | 8 screenshots | ✅ Ready to capture |
| **Documentation** | 5 screenshots | ✅ Ready to capture |
| **TOTAL** | **42 screenshots** | **24 ready, 18 pending** |

---

## 🚀 IMMEDIATE ACTION ITEMS

### Do RIGHT NOW (5 minutes):
1. ✅ Open http://localhost:8000/chat/ → Screenshot
2. ✅ Open http://localhost:3000 → Grafana dashboards → Screenshots
3. ✅ Open http://localhost:9090 → Prometheus → Screenshots
4. ✅ Run: `docker ps` → Screenshot
5. ✅ Check GitHub Actions → Screenshot

### Do NEXT (if time permits):
1. ⏳ Run on Minikube for K8s screenshots
2. ⏳ Run Ansible playbook locally
3. ⏳ Deploy to Railway for live demo

---

## 📝 Notes:
- All timestamps will show December 16, 2025
- Docker images timestamped within exam period
- CI/CD logs show correct date
- GitHub commits visible with timestamps
