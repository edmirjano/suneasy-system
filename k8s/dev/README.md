# SunEasy Development Environment - Kubernetes Configuration

This directory contains all Kubernetes manifests for the SunEasy development environment.

## Quick Start

### 1. Create Secrets File

```bash
# Copy the template
cp secrets.yaml.example secrets.yaml

# Edit with your actual credentials
nano secrets.yaml
```

**Required credentials to fill in:**
- AWS S3 credentials (Access Key ID, Secret Access Key, bucket name)
- Stripe test API keys
- PayPal sandbox credentials
- Firebase service account JSON values
- Social login credentials (Facebook, Google, Apple)

See `secrets.yaml.example` for all required fields and instructions.

### 2. Apply All Manifests

```bash
# Using kubectl directly
kubectl apply -f namespace.yaml
kubectl apply -f secrets.yaml
kubectl apply -f infrastructure/
kubectl apply -f backend/
kubectl apply -f frontend/
kubectl apply -f ingress.yaml

# OR using kustomize
kubectl apply -k .
```

### 3. Verify Deployment

```bash
# Check all pods are running
kubectl get pods -n suneasy-dev

# Check all services
kubectl get svc -n suneasy-dev

# Check ingress routes
kubectl get ingressroute -n suneasy-dev
```

## Directory Structure

```
k8s/dev/
├── namespace.yaml                 # Namespace definition
├── secrets.yaml.example          # Template for secrets (copy to secrets.yaml)
├── secrets.yaml                  # Your actual secrets (git-ignored)
├── kustomization.yaml            # Kustomize configuration
├── ingress.yaml                  # Traefik ingress routes
├── infrastructure/               # Infrastructure services
│   ├── postgres-*.yaml          # PostgreSQL database
│   ├── redis-*.yaml             # Redis cache
│   ├── rabbitmq-*.yaml          # RabbitMQ message queue
│   ├── elasticsearch-*.yaml     # Elasticsearch
│   ├── adminer-*.yaml           # Database UI
│   ├── redis-commander-*.yaml   # Redis UI
│   └── mailhog-*.yaml           # Email testing
├── backend/                      # Backend microservices (14 services)
│   ├── api-gateway-*.yaml
│   ├── auth-*.yaml
│   ├── organization-*.yaml
│   ├── resource-*.yaml
│   ├── reservation-*.yaml
│   ├── payment-*.yaml
│   ├── media-*.yaml
│   ├── notification-*.yaml
│   ├── email-*.yaml
│   ├── config-*.yaml
│   ├── log-*.yaml
│   ├── sms-*.yaml
│   ├── review-*.yaml
│   ├── geolocation-*.yaml
│   └── backend-configmap.yaml
├── frontend/                     # Frontend applications (6 apps)
│   ├── admin-*.yaml
│   ├── dashboard-*.yaml
│   ├── landing-*.yaml
│   ├── client-web-*.yaml
│   ├── client-*.yaml
│   ├── business-*.yaml
│   └── frontend-configmap.yaml
└── certificates/                 # TLS certificates
    ├── self-signed-cert.yaml
    ├── cert-manager-issuer.yaml
    └── wildcard-certificate.yaml
```

## Service Ports

### Frontend Applications
- Admin: 4100
- Dashboard: 4000
- Landing: 4300
- Client Web: 4500
- Client Mobile: 4200
- Business Mobile: 4201

### Backend Services
- API Gateway: 8000
- Auth: 8010
- Organization: 8020
- Resource: 8030
- Reservation: 8040
- Payment: 8050
- Media: 8060
- Notification: 8070
- Email: 8080
- Config: 8090
- Log: 8100
- SMS: 8110
- Review: 8120
- Geolocation: 8130

### Infrastructure
- PostgreSQL: 5432
- Redis: 6379
- RabbitMQ: 5672 (AMQP), 15672 (Management)
- Elasticsearch: 9200
- Adminer: 8080
- Redis Commander: 8081
- MailHog: 1025 (SMTP), 8025 (Web UI)

## Accessing Services

### Via Ingress (DNS configured)
- https://admin.test.suneasy.app
- https://dashboard.test.suneasy.app
- https://www.test.suneasy.app
- https://app.test.suneasy.app
- https://api.test.suneasy.app
- http://adminer.test.suneasy.app
- http://mailhog.test.suneasy.app
- http://rabbitmq.test.suneasy.app

### Via Port Forward
```bash
# Frontend apps
kubectl port-forward -n suneasy-dev svc/admin 4100:4100
kubectl port-forward -n suneasy-dev svc/dashboard 4000:4000

# Backend API
kubectl port-forward -n suneasy-dev svc/api-gateway 8000:80

# Infrastructure
kubectl port-forward -n suneasy-dev svc/postgres 5432:5432
kubectl port-forward -n suneasy-dev svc/adminer 8080:8080
```

## ConfigMaps

### Backend ConfigMap
Location: `backend/backend-configmap.yaml`

Contains:
- Service URLs for inter-service communication
- Database connection strings
- Redis configuration
- RabbitMQ configuration
- Feature flags

### Frontend ConfigMap
Location: `frontend/frontend-configmap.yaml`

Contains:
- API_URL: Backend API endpoint
- WS_URL: WebSocket endpoint
- App URLs for reference

## Secrets Management

**IMPORTANT:** Never commit `secrets.yaml` to version control!

The `.gitignore` should include:
```
k8s/dev/secrets.yaml
k8s/test/secrets.yaml
k8s/production/secrets.yaml
```

### Generating Secure Keys

```bash
# JWT Secret (256-bit)
openssl rand -base64 32

# Encryption Key (256-bit hex)
openssl rand -hex 32

# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=*.test.suneasy.app"
```

## Troubleshooting

### Pods not starting
```bash
# Check pod status
kubectl get pods -n suneasy-dev

# Check pod logs
kubectl logs -n suneasy-dev <pod-name>

# Describe pod for events
kubectl describe pod -n suneasy-dev <pod-name>
```

### Database connection issues
```bash
# Check postgres is running
kubectl get pods -n suneasy-dev | grep postgres

# Test connection
kubectl exec -it -n suneasy-dev postgres-0 -- psql -U suneasy_user -d postgres -c '\l'

# Check database init
kubectl logs -n suneasy-dev postgres-0 | grep "database system is ready"
```

### Secrets not found
```bash
# Verify secrets exist
kubectl get secrets -n suneasy-dev

# Check secret content (base64 encoded)
kubectl get secret suneasy-secrets -n suneasy-dev -o yaml

# Decode a specific value
kubectl get secret suneasy-secrets -n suneasy-dev -o jsonpath='{.data.DB_PASSWORD}' | base64 -d
```

### Ingress not working
```bash
# Check ingress routes
kubectl get ingressroute -n suneasy-dev

# Check Traefik logs
kubectl logs -n kube-system -l app.kubernetes.io/name=traefik

# Test from inside cluster
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl http://api-gateway.suneasy-dev.svc.cluster.local/health
```

## Cleanup

```bash
# Delete all resources in namespace
kubectl delete namespace suneasy-dev

# Or delete specific resources
kubectl delete -k .
```

## Related Documentation

- [Skaffold Setup Guide](../../docs/SKAFFOLD_SETUP.md)
- [Architecture Overview](../../docs/ARCHITECTURE.md)
- [Cloudflare DNS Setup](../../docs/CLOUDFLARE_DNS_SETUP.md)
- [Ingress Configuration](../../docs/INGRESS_SETUP.md)
