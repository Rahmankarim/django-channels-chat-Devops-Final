# Monitoring Stack for Django Channels Chat

This directory contains the monitoring configuration using Prometheus and Grafana.

## Components

- **Prometheus**: Metrics collection and storage
- **Grafana**: Metrics visualization and dashboards
- **Node Exporter**: System/host metrics
- **cAdvisor**: Container metrics
- **PostgreSQL Exporter**: Database metrics (optional)
- **Redis Exporter**: Cache metrics (optional)

## Structure

```
monitoring/
├── prometheus.yml              # Prometheus configuration
├── alerts/
│   └── django-alerts.yml       # Alert rules
├── grafana/
│   ├── datasources/
│   │   └── prometheus.yml      # Grafana datasource config
│   └── dashboards/
│       ├── dashboard-provider.yml
│       ├── django-overview.json
│       └── database-metrics.json
└── README.md
```

## Quick Start

### Using Docker Compose

The monitoring stack is already included in the main `docker-compose.yml`:

```bash
# Start all services including monitoring
docker-compose up -d

# Access Grafana
open http://localhost:3000
# Default credentials: admin/admin

# Access Prometheus
open http://localhost:9090
```

### Standalone Deployment

Create a separate `docker-compose.monitoring.yml`:

```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./alerts:/etc/prometheus/alerts
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    ports:
      - "9090:9090"
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    volumes:
      - ./grafana/datasources:/etc/grafana/provisioning/datasources
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    ports:
      - "3000:3000"
    networks:
      - monitoring

  node-exporter:
    image: prom/node-exporter:latest
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    ports:
      - "9100:9100"
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:

networks:
  monitoring:
    driver: bridge
```

Deploy:
```bash
docker-compose -f docker-compose.monitoring.yml up -d
```

## Kubernetes Deployment

### Deploy Prometheus

```bash
# Create namespace
kubectl create namespace monitoring

# Create ConfigMap for Prometheus config
kubectl create configmap prometheus-config \
  --from-file=prometheus.yml \
  -n monitoring

# Create ConfigMap for alert rules
kubectl create configmap prometheus-alerts \
  --from-file=alerts/ \
  -n monitoring

# Apply Prometheus deployment
kubectl apply -f k8s-monitoring/prometheus-deployment.yaml
```

### Deploy Grafana

```bash
# Create ConfigMaps for Grafana
kubectl create configmap grafana-datasources \
  --from-file=grafana/datasources/ \
  -n monitoring

kubectl create configmap grafana-dashboards \
  --from-file=grafana/dashboards/ \
  -n monitoring

# Apply Grafana deployment
kubectl apply -f k8s-monitoring/grafana-deployment.yaml
```

## Metrics Collected

### Application Metrics

- **Request metrics**: Rate, duration, status codes
- **WebSocket metrics**: Active connections, messages
- **Django metrics**: View execution time, database queries
- **Process metrics**: CPU, memory usage

### Database Metrics (PostgreSQL)

- **Connections**: Active, idle, total
- **Transactions**: Commits, rollbacks, rate
- **Queries**: Slow queries, query duration
- **Performance**: Cache hit rate, locks

### Cache Metrics (Redis)

- **Memory**: Used, available, fragmentation
- **Operations**: Commands/sec, hit rate
- **Connections**: Connected clients
- **Keys**: Total keys, expired keys

### System Metrics

- **CPU**: Usage per core, load average
- **Memory**: Used, available, swap
- **Disk**: Usage, I/O operations
- **Network**: Traffic, errors

### Container Metrics

- **Resource usage**: CPU, memory per container
- **Network**: Traffic per container
- **Disk I/O**: Read/write operations

## Grafana Dashboards

### 1. Application Overview Dashboard
- Request rate and response time
- HTTP status codes distribution
- Active WebSocket connections
- CPU and memory usage

### 2. Database & Redis Dashboard
- PostgreSQL connection count
- Transaction rate
- Redis memory usage
- Cache hit rate

### 3. Infrastructure Dashboard (optional)
- Node CPU and memory
- Disk space usage
- Network traffic
- Container resource usage

## Accessing Dashboards

### Grafana
```
URL: http://localhost:3000 (Docker Compose)
     http://<grafana-service>:3000 (Kubernetes)
Default credentials: admin/admin
```

### Prometheus
```
URL: http://localhost:9090 (Docker Compose)
     http://<prometheus-service>:9090 (Kubernetes)
```

## Alerts

Configured alerts in `alerts/django-alerts.yml`:

### Critical Alerts
- Application is down
- Database is down
- Redis is down
- High HTTP error rate (5xx)

### Warning Alerts
- High response time
- High CPU usage
- High memory usage
- Low disk space
- High database connections
- Low Redis cache hit rate
- Pod restarts

## Alert Configuration

### Email Notifications

Add to `prometheus.yml`:

```yaml
alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']
```

Create `alertmanager.yml`:

```yaml
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'alerts@yourdomain.com'
  smtp_auth_username: 'your-email@gmail.com'
  smtp_auth_password: 'your-app-password'

route:
  receiver: 'email-notifications'
  group_by: ['alertname', 'severity']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h

receivers:
  - name: 'email-notifications'
    email_configs:
      - to: 'team@yourdomain.com'
        headers:
          Subject: '[ALERT] {{ .GroupLabels.alertname }}'
```

### Slack Notifications

```yaml
receivers:
  - name: 'slack-notifications'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL'
        channel: '#alerts'
        title: '{{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
```

## Custom Metrics

### Adding Application Metrics

Install Django Prometheus:

```bash
pip install django-prometheus
```

Update `settings.py`:

```python
INSTALLED_APPS = [
    ...
    'django_prometheus',
]

MIDDLEWARE = [
    'django_prometheus.middleware.PrometheusBeforeMiddleware',
    ...
    'django_prometheus.middleware.PrometheusAfterMiddleware',
]
```

Add to `urls.py`:

```python
from django.urls import path, include

urlpatterns = [
    ...
    path('', include('django_prometheus.urls')),
]
```

### Custom WebSocket Metrics

```python
from prometheus_client import Counter, Gauge

websocket_connections = Gauge(
    'websocket_connections_active',
    'Number of active WebSocket connections'
)

websocket_messages = Counter(
    'websocket_messages_total',
    'Total number of WebSocket messages',
    ['type']
)

# In your consumer
class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        websocket_connections.inc()
        await self.accept()
    
    async def disconnect(self, close_code):
        websocket_connections.dec()
    
    async def receive(self, text_data):
        websocket_messages.labels(type='received').inc()
        # ... handle message
```

## Querying Metrics

### Prometheus Query Examples

**Request rate:**
```promql
rate(http_requests_total[5m])
```

**95th percentile response time:**
```promql
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

**Error rate:**
```promql
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])
```

**Active WebSocket connections:**
```promql
websocket_connections_active
```

**Database connections:**
```promql
pg_stat_database_numbackends
```

**Redis memory usage percentage:**
```promql
redis_memory_used_bytes / redis_memory_max_bytes * 100
```

## Troubleshooting

### Prometheus Not Scraping Targets

```bash
# Check Prometheus targets
curl http://localhost:9090/api/v1/targets

# Check Prometheus logs
docker-compose logs prometheus

# Verify network connectivity
docker-compose exec prometheus ping web
```

### Grafana Not Showing Data

1. Check datasource connection in Grafana UI
2. Verify Prometheus is collecting metrics
3. Check dashboard queries
4. Review Grafana logs:
   ```bash
   docker-compose logs grafana
   ```

### High Memory Usage

Prometheus stores metrics in memory. Adjust retention:

```yaml
command:
  - '--storage.tsdb.retention.time=15d'
  - '--storage.tsdb.retention.size=10GB'
```

### Missing Metrics

1. Verify metric is being exposed: `curl http://localhost:8000/metrics`
2. Check Prometheus scrape config
3. Verify target is UP in Prometheus
4. Check for label mismatches in queries

## Best Practices

1. **Set appropriate retention**: Balance storage vs history
2. **Use labels wisely**: Don't create too many unique label combinations
3. **Monitor the monitors**: Set alerts for Prometheus and Grafana
4. **Regular backups**: Backup Grafana dashboards and Prometheus data
5. **Resource limits**: Set appropriate CPU/memory limits
6. **Security**: Use authentication and HTTPS in production
7. **Dashboard organization**: Group related metrics
8. **Alert tuning**: Adjust thresholds to reduce false positives

## Performance Optimization

1. **Reduce scrape frequency** for less critical metrics
2. **Use recording rules** for expensive queries
3. **Limit cardinality** of labels
4. **Use metric relabeling** to drop unnecessary metrics
5. **Configure appropriate retention period**

## Production Considerations

1. **High availability**: Run multiple Prometheus instances
2. **Long-term storage**: Use Thanos or Cortex
3. **Federation**: For multi-cluster setups
4. **Access control**: Implement authentication
5. **Secure endpoints**: Use TLS/SSL
6. **Backup strategy**: Automated backups of dashboards and data
7. **Capacity planning**: Monitor monitoring system resources

## Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [PromQL Cheat Sheet](https://promlabs.com/promql-cheat-sheet/)
