#!/bin/bash

# Helper script to add DNS entries to /etc/hosts

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}SunEasy DNS Setup Helper${NC}"
echo ""

# Get LoadBalancer IP
LB_IP=$(kubectl get svc traefik -n traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "127.0.0.1")

echo -e "${YELLOW}LoadBalancer IP: ${LB_IP}${NC}"
echo ""

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}This script needs sudo access to modify /etc/hosts${NC}"
    echo -e "Run: ${GREEN}sudo $0${NC}"
    exit 1
fi

# Domains to add
DOMAINS=(
    "admin.test.suneasy.app"
    "dashboard.test.suneasy.app"
    "api.test.suneasy.app"
    "app.test.suneasy.app"
    "www.test.suneasy.app"
    "client.test.suneasy.app"
    "business.test.suneasy.app"
    "adminer.test.suneasy.app"
    "mailhog.test.suneasy.app"
    "rabbitmq.test.suneasy.app"
)

# Backup /etc/hosts
cp /etc/hosts /etc/hosts.suneasy.bak
echo -e "${GREEN}✓ Backed up /etc/hosts to /etc/hosts.suneasy.bak${NC}"

# Remove old entries (if any)
for domain in "${DOMAINS[@]}"; do
    sed -i "/$domain/d" /etc/hosts
done

# Add new entries
echo "" >> /etc/hosts
echo "# SunEasy Development Domains (added by setup-dns.sh)" >> /etc/hosts
for domain in "${DOMAINS[@]}"; do
    echo "${LB_IP} ${domain}" >> /etc/hosts
    echo -e "${GREEN}✓ Added ${domain}${NC}"
done

echo ""
echo -e "${GREEN}DNS entries added successfully!${NC}"
echo ""
echo -e "${YELLOW}Test with:${NC}"
echo -e "  curl -k https://admin.test.suneasy.app"
echo ""
echo -e "${YELLOW}To remove these entries:${NC}"
echo -e "  sudo cp /etc/hosts.suneasy.bak /etc/hosts"
echo ""
