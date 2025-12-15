# Ansible Configuration Management

This directory contains Ansible playbooks and configurations for automating the deployment and configuration of the Django Channels Chat application.

## Structure

```
ansible/
├── playbook.yml           # Main playbook
├── hosts.ini              # Static inventory file
├── vars/                  # Environment-specific variables
│   ├── dev.yml
│   └── prod.yml
├── templates/             # Jinja2 templates
│   └── env.j2
└── README.md
```

## Prerequisites

1. **Ansible installed** (version >= 2.10)

   ```bash
   pip install ansible
   ```

2. **Ansible collections** for Kubernetes and Docker

   ```bash
   ansible-galaxy collection install community.docker
   ansible-galaxy collection install kubernetes.core
   ```

3. **SSH access** to target servers

   - Configure SSH keys
   - Update `hosts.ini` with server IPs

4. **AWS CLI configured** (for dynamic inventory)
   ```bash
   aws configure
   ```

## Quick Start

### 1. Update Inventory

Edit `hosts.ini` with your server information:

```ini
[docker_hosts]
docker-host-1 ansible_host=10.0.1.10

[k8s_masters]
k8s-master-1 ansible_host=10.0.2.10
```

### 2. Test Connection

```bash
ansible all -i hosts.ini -m ping
```

### 3. Run Playbook

For development:

```bash
ansible-playbook -i hosts.ini playbook.yml -e "env=dev"
```

For production:

```bash
ansible-playbook -i hosts.ini playbook.yml -e "env=prod" --ask-vault-pass
```

## Playbook Tasks

The main playbook performs the following tasks:

### System Setup

1. Updates package repositories
2. Installs required system packages
3. Installs Docker and Docker Compose
4. Installs AWS CLI and kubectl
5. Creates application user and directories

### Docker Deployment

1. Clones/updates application repository
2. Configures environment variables
3. Pulls Docker images
4. Starts services with Docker Compose
5. Waits for health checks

### Kubernetes Deployment

1. Creates Kubernetes namespace
2. Applies ConfigMaps and Secrets
3. Deploys application pods
4. Creates services and ingress
5. Waits for pods to be ready

### Monitoring Setup

1. Deploys Prometheus
2. Deploys Grafana
3. Configures dashboards

## Usage Examples

### Deploy to Docker Hosts

```bash
ansible-playbook -i hosts.ini playbook.yml \
  -e "env=dev" \
  -e "docker_deploy=true" \
  --tags docker
```

### Deploy to Kubernetes

```bash
ansible-playbook -i hosts.ini playbook.yml \
  -e "env=prod" \
  -e "k8s_deploy=true" \
  --tags kubernetes
```

### Configure Only System

```bash
ansible-playbook -i hosts.ini playbook.yml \
  --tags system \
  -e "env=dev"
```

### Setup Monitoring

```bash
ansible-playbook -i hosts.ini playbook.yml \
  --tags monitoring \
  -e "monitoring_enabled=true"
```

### Dry Run (Check Mode)

```bash
ansible-playbook -i hosts.ini playbook.yml -e "env=dev" --check
```

## Dynamic Inventory (AWS)

For AWS EC2 instances, use dynamic inventory:

### 1. Install boto3

```bash
pip install boto3 botocore
```

### 2. Create aws_ec2.yml

```yaml
plugin: aws_ec2
regions:
  - us-east-1
filters:
  tag:Environment: production
  tag:Project: django-channels-chat
  instance-state-name: running
keyed_groups:
  - key: tags.Role
    prefix: role
hostnames:
  - private-ip-address
```

### 3. Use Dynamic Inventory

```bash
ansible-playbook -i aws_ec2.yml playbook.yml -e "env=prod"
```

## Environment Variables

Set via command line or environment files in `vars/`:

| Variable            | Description              | Example       |
| ------------------- | ------------------------ | ------------- |
| `env`               | Environment name         | dev, prod     |
| `django_secret_key` | Django secret key        | random-string |
| `django_debug`      | Debug mode               | true, false   |
| `postgres_host`     | Database host            | localhost     |
| `postgres_password` | Database password        | secure-pass   |
| `redis_host`        | Redis host               | localhost     |
| `docker_deploy`     | Enable Docker deployment | true, false   |
| `k8s_deploy`        | Enable K8s deployment    | true, false   |

## Secrets Management

### Using Ansible Vault

1. **Create encrypted file**:

   ```bash
   ansible-vault create vars/secrets.yml
   ```

2. **Edit encrypted file**:

   ```bash
   ansible-vault edit vars/secrets.yml
   ```

3. **Run with vault**:

   ```bash
   ansible-playbook -i hosts.ini playbook.yml --ask-vault-pass
   ```

4. **Store password in file**:
   ```bash
   echo "your-vault-password" > .vault_pass
   chmod 600 .vault_pass
   ansible-playbook -i hosts.ini playbook.yml --vault-password-file .vault_pass
   ```

### Example secrets.yml

```yaml
---
django_secret_key: "very-secret-key-here"
postgres_password: "secure-database-password"
redis_password: "secure-redis-password"
aws_access_key: "AKIAIOSFODNN7EXAMPLE"
aws_secret_key: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
```

## Troubleshooting

### Connection Issues

```bash
# Test SSH connection
ssh -i ~/.ssh/id_rsa ubuntu@<host-ip>

# Verify Python is installed
ansible all -i hosts.ini -m raw -a "python3 --version"

# Check connectivity
ansible all -i hosts.ini -m ping -vvv
```

### Permission Issues

```bash
# Run with become (sudo)
ansible-playbook -i hosts.ini playbook.yml --become --ask-become-pass

# Verify sudo access
ansible all -i hosts.ini -m shell -a "sudo whoami" --become
```

### Docker Issues

```bash
# Restart Docker service
ansible docker_hosts -i hosts.ini -m systemd -a "name=docker state=restarted" --become

# Check Docker status
ansible docker_hosts -i hosts.ini -m shell -a "docker ps"
```

### Kubernetes Issues

```bash
# Check kubectl access
ansible k8s_masters -i hosts.ini -m shell -a "kubectl get nodes"

# Verify kubeconfig
ansible k8s_masters -i hosts.ini -m shell -a "cat ~/.kube/config"
```

## Best Practices

1. **Use roles** for complex playbooks
2. **Implement idempotency** - playbooks should be rerunnable
3. **Use handlers** for service restarts
4. **Tag tasks** for selective execution
5. **Validate before applying** with `--check`
6. **Use vault** for sensitive data
7. **Keep inventory updated**
8. **Test in dev first**
9. **Use version control** for playbooks
10. **Document changes**

## Example Workflow

### Complete Deployment

```bash
# 1. Update inventory
vim hosts.ini

# 2. Test connectivity
ansible all -i hosts.ini -m ping

# 3. Run system setup
ansible-playbook -i hosts.ini playbook.yml -e "env=dev" --tags system

# 4. Deploy application
ansible-playbook -i hosts.ini playbook.yml -e "env=dev" --tags docker

# 5. Verify deployment
ansible docker_hosts -i hosts.ini -m shell -a "docker ps"
```

### Rolling Update

```bash
# 1. Pull new images
ansible docker_hosts -i hosts.ini -m shell -a "cd /opt/django-channels-chat && docker-compose pull"

# 2. Restart services one by one
ansible docker_hosts -i hosts.ini -m shell -a "cd /opt/django-channels-chat && docker-compose up -d" --serial 1

# 3. Wait and verify
ansible docker_hosts -i hosts.ini -m uri -a "url=http://localhost:8000/chat/ status_code=200"
```

## Integration with CI/CD

Add to your CI/CD pipeline:

```yaml
# Example GitHub Actions step
- name: Deploy with Ansible
  run: |
    ansible-playbook -i ansible/hosts.ini ansible/playbook.yml \
      -e "env=prod" \
      -e "docker_image_tag=${{ github.sha }}" \
      --vault-password-file .vault_pass
```

## Support

For issues or questions:

1. Check Ansible documentation: https://docs.ansible.com/
2. Review playbook output with `-vvv` flag
3. Test individual tasks with ad-hoc commands
4. Verify inventory configuration
