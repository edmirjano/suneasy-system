# SunEasy Development Environment

## Quick Start

```bash
bash start-dev.sh
```

One command. That's it.

---

## Port Configuration

SunEasy uses dedicated ports in the **9079+** range to avoid conflicts with other projects:

- **HTTP**: http://localhost:9079
- **HTTPS**: https://localhost:9443
- **API**: http://localhost:9080
- **Registry**: localhost:9500

📖 See [PORTS.md](PORTS.md) for detailed port configuration and domain setup.

---

## What Happens

**First run:** Sets up Minikube, installs everything, deploys all services, enables hot reload
**Subsequent runs:** Just starts hot reload (everything already running)
**When you Ctrl+C:** Services keep running with latest code

---

## Access

- https://admin.test.suneasy.app
- https://dashboard.test.suneasy.app
- https://api.test.suneasy.app
- https://app.test.suneasy.app

**Login:** admin@sunsetparadise.com / password123

---

## Hot Reload

Edit files → Changes auto-deploy in 2-10 seconds

---

## Cloudflare DNS (One Time Setup)

1. Get IP: `minikube ip`
2. Cloudflare → DNS → Add A record:
   - Name: `*.test`
   - Content: [MINIKUBE_IP]

---

## Commands

```bash
./start-dev.sh              # Start everything
kubectl get pods -n suneasy-dev  # Check status
minikube stop               # Stop cluster
minikube delete             # Complete reset
```

---

**Simple. Persistent. Production-like.** 🚀
