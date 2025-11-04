#!/bin/bash

# SunEasy Development Environment - k3d + Skaffold
# Production-like K8s cluster with hot-reload capabilities
# State persists after Ctrl+C - domains keep working!

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
CLUSTER_NAME="suneasy-dev"
NAMESPACE="suneasy-dev"
CLOUDFLARE_API_TOKEN="_R8V16p9TjQ2zwJgT_DKxV9o3NZjFrlbIH5-Cd8r"
K3D_CONFIG="k3d-config.yaml"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         SunEasy Development Environment (k3d)          ║${NC}"
echo -e "${BLUE}║     Production-like K8s with Hot-Reload Magic ✨      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# Phase 1: Prerequisites Check
# ============================================================================

echo -e "${CYAN}[1/6] Checking prerequisites...${NC}"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker not found. Please install Docker first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker installed${NC}"

# Check k3d
if ! command -v k3d &> /dev/null; then
    echo -e "${RED}✗ k3d not found. Please install k3d.${NC}"
    echo -e "${YELLOW}  Run: curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash${NC}"
    exit 1
fi
echo -e "${GREEN}✓ k3d installed ($(k3d version | head -1))${NC}"

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}✗ kubectl not found. Please install kubectl.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ kubectl installed${NC}"

# Check Skaffold
if ! command -v skaffold &> /dev/null; then
    echo -e "${RED}✗ Skaffold not found. Please install Skaffold.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Skaffold installed ($(skaffold version))${NC}"

# Check Helm
if ! command -v helm &> /dev/null; then
    echo -e "${YELLOW}Installing Helm...${NC}"
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi
echo -e "${GREEN}✓ Helm installed${NC}"

echo ""

# ============================================================================
# Phase 2: k3d Cluster Setup
# ============================================================================

echo -e "${CYAN}[2/6] Setting up k3d cluster...${NC}"

if k3d cluster list | grep -q "${CLUSTER_NAME}"; then
    echo -e "${GREEN}✓ k3d cluster '${CLUSTER_NAME}' already exists${NC}"
    
    # Check if it's running
    if k3d cluster list | grep "${CLUSTER_NAME}" | grep -q "running"; then
        echo -e "${GREEN}✓ Cluster is running${NC}"
    else
        echo -e "${YELLOW}Starting cluster...${NC}"
        k3d cluster start ${CLUSTER_NAME}
        sleep 5
    fi
else
    echo -e "${YELLOW}Creating k3d cluster (this takes ~30 seconds)...${NC}"
    k3d cluster create --config ${K3D_CONFIG}
    echo -e "${GREEN}✓ k3d cluster created successfully${NC}"
fi

# Set kubectl context
kubectl config use-context k3d-${CLUSTER_NAME}
echo -e "${GREEN}✓ kubectl context set to k3d-${CLUSTER_NAME}${NC}"

echo ""

# ============================================================================
# Phase 3: Install Infrastructure Components
# ============================================================================

echo -e "${CYAN}[3/6] Installing infrastructure components...${NC}"

# Install Traefik (since we disabled it in k3d config)
if ! kubectl get namespace traefik &> /dev/null; then
    echo -e "${YELLOW}Installing Traefik...${NC}"
    helm repo add traefik https://traefik.github.io/charts > /dev/null 2>&1 || true
    helm repo update > /dev/null 2>&1
    
    helm install traefik traefik/traefik \
        --create-namespace \
        --namespace traefik \
        --set ports.web.port=80 \
        --set ports.websecure.port=443 \
        --set ports.web.exposedPort=80 \
        --set ports.websecure.exposedPort=443 \
        --set service.type=LoadBalancer \
        --wait --timeout=180s
    
    echo -e "${GREEN}✓ Traefik installed${NC}"
else
    echo -e "${GREEN}✓ Traefik already installed${NC}"
fi

# Install cert-manager
if ! kubectl get namespace cert-manager &> /dev/null; then
    echo -e "${YELLOW}Installing cert-manager...${NC}"
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
    
    echo -e "${YELLOW}Waiting for cert-manager to be ready (this may take 1-2 minutes)...${NC}"
    kubectl wait --for=condition=available --timeout=180s deployment/cert-manager -n cert-manager 2>/dev/null || true
    kubectl wait --for=condition=available --timeout=180s deployment/cert-manager-webhook -n cert-manager 2>/dev/null || true
    kubectl wait --for=condition=available --timeout=180s deployment/cert-manager-cainjector -n cert-manager 2>/dev/null || true
    
    echo -e "${GREEN}✓ cert-manager installed${NC}"
else
    echo -e "${GREEN}✓ cert-manager already installed${NC}"
fi

echo ""

# ============================================================================
# Phase 4: Create Namespace and Secrets
# ============================================================================

echo -e "${CYAN}[4/6] Setting up namespace and secrets...${NC}"

# Create namespace
kubectl apply -f k8s/base/namespace.yaml
echo -e "${GREEN}✓ Namespace ${NAMESPACE} ready${NC}"

# Apply Cloudflare API token for cert-manager
kubectl create secret generic cloudflare-api-token \
    --from-literal=api-token=${CLOUDFLARE_API_TOKEN} \
    --namespace=cert-manager \
    --dry-run=client -o yaml | kubectl apply -f -
echo -e "${GREEN}✓ Cloudflare API token configured${NC}"

# Apply ClusterIssuer for Let's Encrypt
kubectl apply -f k8s/base/cert-manager/cluster-issuer.yaml
kubectl apply -f k8s/base/cert-manager/cluster-issuer-staging.yaml
echo -e "${GREEN}✓ ClusterIssuers configured${NC}"

# Apply application secrets
if [ -f "k8s/base/secrets/secrets.yaml" ]; then
    kubectl apply -f k8s/base/secrets/secrets.yaml
    echo -e "${GREEN}✓ Application secrets applied${NC}"
else
    # Create from template
    echo -e "${YELLOW}Creating secrets from template...${NC}"
    export CLOUDFLARE_API_TOKEN
    envsubst < k8s/base/secrets/secrets-template.yaml | kubectl apply -f -
    echo -e "${GREEN}✓ Application secrets created${NC}"
fi

echo ""

# ============================================================================
# Phase 5: Display Access Information
# ============================================================================

echo -e "${CYAN}[5/6] Preparing environment...${NC}"

# Get LoadBalancer IP
echo -e "${YELLOW}Waiting for LoadBalancer IP...${NC}"
sleep 5

LB_IP=$(kubectl get svc traefik -n traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")

if [ -z "$LB_IP" ]; then
    # Fallback to localhost for k3d
    LB_IP="127.0.0.1"
    echo -e "${YELLOW}Using localhost (k3d default)${NC}"
fi

echo -e "${GREEN}✓ LoadBalancer IP: ${LB_IP}${NC}"

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║             DNS Configuration Required                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Add these DNS records to Cloudflare:${NC}"
echo ""
echo -e "  ${CYAN}*.test.suneasy.app${NC}  →  ${MAGENTA}${LB_IP}${NC}"
echo ""
echo -e "${YELLOW}Or add to /etc/hosts for local testing:${NC}"
echo ""
echo -e "  ${LB_IP} admin.test.suneasy.app"
echo -e "  ${LB_IP} dashboard.test.suneasy.app"
echo -e "  ${LB_IP} api.test.suneasy.app"
echo -e "  ${LB_IP} app.test.suneasy.app"
echo -e "  ${LB_IP} www.test.suneasy.app"
echo -e "  ${LB_IP} client.test.suneasy.app"
echo -e "  ${LB_IP} business.test.suneasy.app"
echo -e "  ${LB_IP} adminer.test.suneasy.app"
echo -e "  ${LB_IP} mailhog.test.suneasy.app"
echo -e "  ${LB_IP} rabbitmq.test.suneasy.app"
echo ""

# ============================================================================
# Phase 6: Start Skaffold Development
# ============================================================================

echo -e "${CYAN}[6/6] Starting Skaffold hot-reload...${NC}"
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              🔥 Hot-Reload Activated! 🔥               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Your applications will be available at:${NC}"
echo ""
echo -e "  ${CYAN}🎨 Frontend Apps:${NC}"
echo -e "     Admin:      ${MAGENTA}https://admin.test.suneasy.app${NC}"
echo -e "     Dashboard:  ${MAGENTA}https://dashboard.test.suneasy.app${NC}"
echo -e "     Landing:    ${MAGENTA}https://www.test.suneasy.app${NC}"
echo -e "     Client Web: ${MAGENTA}https://app.test.suneasy.app${NC}"
echo -e "     Client:     ${MAGENTA}https://client.test.suneasy.app${NC}"
echo -e "     Business:   ${MAGENTA}https://business.test.suneasy.app${NC}"
echo ""
echo -e "  ${CYAN}🚀 Backend API:${NC}"
echo -e "     API Gateway: ${MAGENTA}https://api.test.suneasy.app${NC}"
echo ""
echo -e "  ${CYAN}🛠️  Dev Tools:${NC}"
echo -e "     Adminer:    ${MAGENTA}https://adminer.test.suneasy.app${NC}"
echo -e "     MailHog:    ${MAGENTA}https://mailhog.test.suneasy.app${NC}"
echo -e "     RabbitMQ:   ${MAGENTA}https://rabbitmq.test.suneasy.app${NC}"
echo ""
echo -e "${YELLOW}Hot-Reload Features:${NC}"
echo -e "  • Frontend changes: ${GREEN}Auto-reload in 2-3 seconds${NC}"
echo -e "  • Backend changes:  ${GREEN}Auto-rebuild in 5-10 seconds${NC}"
echo ""
echo -e "${YELLOW}Commands:${NC}"
echo -e "  • ${CYAN}Ctrl+C${NC} - Stop hot-reload (services keep running!)"
echo -e "  • ${CYAN}./start-dev.sh${NC} - Resume hot-reload"
echo -e "  • ${CYAN}k3d cluster stop ${CLUSTER_NAME}${NC} - Stop cluster"
echo -e "  • ${CYAN}k3d cluster delete ${CLUSTER_NAME}${NC} - Delete cluster"
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

# Start Skaffold with hot reload
# --cleanup=false: Keep deployments after exit
# --status-check=false: Don't wait for all pods (faster startup)
# --trigger=polling: Watch for file changes
skaffold dev \
    --cleanup=false \
    --status-check=false \
    --trigger=polling

echo ""
echo -e "${GREEN}✓ Hot-reload stopped${NC}"
echo ""
echo -e "${YELLOW}Your cluster is still running!${NC}"
echo -e "  • Services are accessible at the URLs above"
echo -e "  • Run ${CYAN}./start-dev.sh${NC} again to resume hot-reload"
echo -e "  • Run ${CYAN}k3d cluster stop ${CLUSTER_NAME}${NC} to stop the cluster"
echo ""
