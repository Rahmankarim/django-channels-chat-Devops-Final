# Kubernetes Deployment Guide

This directory contains Kubernetes manifests for deploying the Django Channels Chat application to a Kubernetes cluster (EKS, Minikube, or other K8s platforms).

## Structure

```
k8s/
├── namespace.yaml       # Namespaces for prod and dev
├── secret.yaml          # Secrets for sensitive data
├── configmap.yaml       # Configuration data
├── database.yaml        # PostgreSQL and Redis (for dev/local)
├── deployment.yaml      # Application deployment
├── service.yaml         # Services (ClusterIP, LoadBalancer)
├── ingress.yaml         # Ingress for HTTP/HTTPS routing
└── README.md
```

## Prerequisites

1. **kubectl** installed and configured

   ```bash
   kubectl version --client
   ```

2. **Kubernetes cluster** running (EKS, Minikube, etc.)

   ```bash
   kubectl cluster-info
   ```

3. **Container images** pushed to registry

   ```bash
   docker build -t your-registry/django-channels-chat:latest .
   docker push your-registry/django-channels-chat:latest
   ```

4. **AWS resources** provisioned (if using EKS)
   - RDS PostgreSQL instance
   - ElastiCache Redis cluster
   - Run Terraform from `../infra/`

## Quick Start

### 1. Create Namespaces

```bash
kubectl apply -f namespace.yaml
```

### 2. Update Configuration

Edit the following files with your values:

**configmap.yaml**:

- Update `POSTGRES_HOST` with RDS endpoint
- Update `REDIS_HOST` with ElastiCache endpoint
- Update `DJANGO_ALLOWED_HOSTS`

**secret.yaml**:

- Update secrets (or use external secrets manager)

**deployment.yaml**:

- Update image registry URL
- Update ServiceAccount role ARN

**ingress.yaml**:

- Update domain name
- Update ACM certificate ARN

### 3. Create Secrets

```bash
# Create secrets from command line (recommended)
kubectl create secret generic django-secrets \
  --from-literal=DJANGO_SECRET_KEY='your-secret-key' \
  --from-literal=POSTGRES_USER='dbadmin' \
  --from-literal=POSTGRES_PASSWORD='your-password' \
  --from-literal=POSTGRES_DB='channels_chat' \
  --namespace=django-chat

# Or apply from file (after updating)
kubectl apply -f secret.yaml
```

### 4. Apply ConfigMap

```bash
kubectl apply -f configmap.yaml
```

### 5. Deploy Database (for Development only)

```bash
# Only for local/dev environments
kubectl apply -f database.yaml
```

**Note**: For production, use managed services (RDS, ElastiCache) from Terraform.

### 6. Deploy Application

```bash
kubectl apply -f deployment.yaml
```

### 7. Create Services

```bash
kubectl apply -f service.yaml
```

### 8. Create Ingress (Optional)

```bash
kubectl apply -f ingress.yaml
```

### 9. Verify Deployment

```bash
# Check pods
kubectl get pods -n django-chat

# Check services
kubectl get svc -n django-chat

# Check ingress
kubectl get ingress -n django-chat

# Describe pod for details
kubectl describe pod <pod-name> -n django-chat

# View logs
kubectl logs -f <pod-name> -n django-chat
```

## Production Deployment (EKS)

### Prerequisites

1. **EKS cluster** provisioned via Terraform
2. **kubectl** configured for EKS

   ```bash
   aws eks update-kubeconfig --region us-east-1 --name django-chat-cluster
   ```

3. **AWS ALB Ingress Controller** installed

   ```bash
   kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

   helm repo add eks https://aws.github.io/eks-charts
   helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
     -n kube-system \
     --set clusterName=django-chat-cluster \
     --set serviceAccount.create=false \
     --set serviceAccount.name=aws-load-balancer-controller
   ```

### Deployment Steps

```bash
# 1. Create namespace
kubectl apply -f namespace.yaml

# 2. Create secrets
kubectl create secret generic django-secrets \
  --from-literal=DJANGO_SECRET_KEY="$(openssl rand -base64 32)" \
  --from-literal=POSTGRES_USER='dbadmin' \
  --from-literal=POSTGRES_PASSWORD='your-secure-password' \
  --from-literal=POSTGRES_DB='channels_chat' \
  --namespace=django-chat

# 3. Update ConfigMap with RDS and ElastiCache endpoints
# Get endpoints from Terraform outputs
cd ../infra
terraform output rds_endpoint
terraform output redis_endpoint

# Update configmap.yaml with these values
kubectl apply -f configmap.yaml

# 4. Deploy application
kubectl apply -f deployment.yaml

# 5. Create services
kubectl apply -f service.yaml

# 6. Setup ingress
kubectl apply -f ingress.yaml

# 7. Verify
kubectl get all -n django-chat
kubectl get ingress -n django-chat
```

## Development Deployment (Minikube)

```bash
# Start Minikube
minikube start --cpus=4 --memory=8192

# Enable ingress addon
minikube addons enable ingress

# Create namespace
kubectl apply -f namespace.yaml

# Deploy database (local Postgres and Redis)
kubectl apply -f database.yaml

# Wait for database to be ready
kubectl wait --for=condition=ready pod -l app=postgres -n django-chat-dev --timeout=300s
kubectl wait --for=condition=ready pod -l app=redis -n django-chat-dev --timeout=300s

# Create secrets (use dev values)
kubectl create secret generic django-secrets \
  --from-literal=DJANGO_SECRET_KEY='dev-secret-key' \
  --from-literal=POSTGRES_USER='postgres' \
  --from-literal=POSTGRES_PASSWORD='postgres' \
  --from-literal=POSTGRES_DB='channels_chat' \
  --namespace=django-chat-dev

# Apply ConfigMap for dev
kubectl apply -f configmap.yaml

# Build and load image to Minikube
eval $(minikube docker-env)
docker build -t django-channels-chat:latest ..

# Deploy application (update namespace to django-chat-dev)
kubectl apply -f deployment.yaml

# Create service
kubectl apply -f service.yaml

# Access application
minikube service django-chat-lb -n django-chat-dev
```

## Monitoring Pods

### View Pod Status

```bash
kubectl get pods -n django-chat
```

### View Pod Logs

```bash
# All logs
kubectl logs <pod-name> -n django-chat

# Follow logs
kubectl logs -f <pod-name> -n django-chat

# Previous logs (if pod restarted)
kubectl logs <pod-name> -n django-chat --previous
```

### Describe Pod

```bash
kubectl describe pod <pod-name> -n django-chat
```

### Execute Commands in Pod

```bash
# Get shell access
kubectl exec -it <pod-name> -n django-chat -- /bin/bash

# Run Django commands
kubectl exec <pod-name> -n django-chat -- python canal/manage.py createsuperuser
```

### Port Forward (for testing)

```bash
kubectl port-forward <pod-name> 8000:8000 -n django-chat
```

## Scaling

### Manual Scaling

```bash
# Scale to 5 replicas
kubectl scale deployment django-chat --replicas=5 -n django-chat

# Verify
kubectl get pods -n django-chat
```

### Auto-scaling

The HorizontalPodAutoscaler is already configured in `deployment.yaml`:

- Min: 2 replicas
- Max: 10 replicas
- Target CPU: 70%
- Target Memory: 80%

Check autoscaler status:

```bash
kubectl get hpa -n django-chat
kubectl describe hpa django-chat-hpa -n django-chat
```

## Rolling Updates

```bash
# Update image
kubectl set image deployment/django-chat \
  django-chat=your-registry/django-channels-chat:v2.0 \
  -n django-chat

# Check rollout status
kubectl rollout status deployment/django-chat -n django-chat

# View rollout history
kubectl rollout history deployment/django-chat -n django-chat

# Rollback to previous version
kubectl rollout undo deployment/django-chat -n django-chat

# Rollback to specific revision
kubectl rollout undo deployment/django-chat --to-revision=2 -n django-chat
```

## Troubleshooting

### Pod Not Starting

```bash
# Check events
kubectl get events -n django-chat --sort-by='.lastTimestamp'

# Check pod details
kubectl describe pod <pod-name> -n django-chat

# Check logs
kubectl logs <pod-name> -n django-chat
```

### Database Connection Issues

```bash
# Test connectivity from pod
kubectl exec <pod-name> -n django-chat -- nc -zv postgres 5432

# Check service endpoints
kubectl get endpoints -n django-chat

# Check secrets
kubectl get secret django-secrets -n django-chat -o yaml
```

### Image Pull Errors

```bash
# Create image pull secret (for private registries)
kubectl create secret docker-registry regcred \
  --docker-server=your-registry.com \
  --docker-username=your-username \
  --docker-password=your-password \
  --docker-email=your-email \
  -n django-chat

# Add to deployment
# spec:
#   imagePullSecrets:
#   - name: regcred
```

### Resource Issues

```bash
# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods -n django-chat

# Describe node
kubectl describe node <node-name>
```

## Cleanup

```bash
# Delete all resources in namespace
kubectl delete namespace django-chat

# Or delete individually
kubectl delete -f ingress.yaml
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
kubectl delete -f database.yaml
kubectl delete -f configmap.yaml
kubectl delete -f secret.yaml
kubectl delete -f namespace.yaml
```

## Best Practices

1. **Use namespaces** to isolate environments
2. **Use secrets** for sensitive data, never in ConfigMaps
3. **Set resource limits** to prevent resource exhaustion
4. **Use readiness/liveness probes** for health checks
5. **Implement PodDisruptionBudgets** for high availability
6. **Use HPA** for automatic scaling
7. **Use StatefulSets** for stateful applications
8. **Use PersistentVolumes** for data persistence
9. **Tag images** with versions, not just `latest`
10. **Test in dev/staging** before production

## Security Considerations

1. **RBAC**: Implement Role-Based Access Control
2. **Network Policies**: Restrict pod-to-pod communication
3. **Pod Security Standards**: Use restricted profiles
4. **Secrets encryption**: Enable encryption at rest
5. **Image scanning**: Scan images for vulnerabilities
6. **Service accounts**: Use dedicated service accounts
7. **External Secrets**: Use AWS Secrets Manager or Vault

## Next Steps

1. Setup monitoring (Prometheus/Grafana)
2. Configure logging (EFK stack)
3. Implement backup strategies
4. Setup CI/CD integration
5. Configure DNS and SSL certificates
6. Implement rate limiting
7. Setup alerting

## Support

For issues:

1. Check Kubernetes events: `kubectl get events`
2. Review pod logs: `kubectl logs`
3. Describe resources: `kubectl describe`
4. Check cluster status: `kubectl cluster-info`
