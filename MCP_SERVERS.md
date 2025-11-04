# MCP Servers Configuration

This document describes the Model Context Protocol (MCP) servers configured for the SunEasy project.

## Configured MCP Servers

### Frontend-Specific

1. **Nx Monorepo MCP** (`nx-monorepo`)
   - Monorepo structure, project relationships, and generators
   - Package: `nx-mcp`
   - Status: ✅ Connected
   - Note: Also configured via `yarn nx configure-ai-agents` in `suneasy/.mcp.json`

### Version Control

2. **Git MCP** (`git`)
   - Git repository operations, status, diffs, commits, branches
   - Package: `mcp-server-git` (via uvx)
   - Repository: `/root/projects/suneasy`
   - Status: ✅ Connected

### Filesystem & Reasoning

3. **Filesystem MCP** (`filesystem`)
   - Secure file operations with access controls
   - Package: `@modelcontextprotocol/server-filesystem`
   - Allowed directories:
     - `/root/projects/suneasy/suneasy` (frontend)
     - `/root/projects/suneasy/SunEasyBE` (backend)
     - `/root/projects/suneasy` (root)
   - Status: ✅ Connected

4. **Sequential Thinking MCP** (`sequential-thinking`)
   - Advanced problem-solving through structured reasoning
   - Package: `@modelcontextprotocol/server-sequential-thinking`
   - Status: ✅ Connected

### Infrastructure

5. **PostgreSQL MCP** (`postgres`)
   - Database operations, schema exploration, query analysis
   - Package: `@henkey/postgres-mcp-server`
   - Status: ✅ Connected (⚠️  requires port-forward to access cluster DB)

6. **Kubernetes MCP** (`kubernetes`)
   - K8s cluster management, pod operations, logs
   - Package: `kubernetes-mcp-server`
   - Status: ✅ Connected (uses current kubectl context)

7. **Docker MCP** (`docker`)
   - Container and image management operations
   - Package: `mcp-server-docker` (via uvx)
   - Status: ✅ Connected (uses Docker daemon)

## Setup Requirements

### UV Package Manager

The Git and Docker MCP servers require `uvx` (part of the `uv` package manager):

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

This has been installed to `/root/.local/bin/uvx`.

### PostgreSQL Connection

The PostgreSQL MCP server requires a connection to the PostgreSQL database. Since PostgreSQL runs in the k3d cluster, you have two options:

#### Option 1: Port Forward (Recommended for Development)

In a separate terminal, run:

```bash
kubectl port-forward svc/postgres -n suneasy-dev 5432:5432
```

Then the MCP server will connect via `localhost:5432`.

#### Option 2: Update Connection String

Edit `.claude/mcp.json` and update the `DATABASE_URL` in the `postgres` server configuration:

```json
"env": {
  "DATABASE_URL": "postgresql://username:password@host:port/suneasy"
}
```

Get credentials from the cluster:

```bash
kubectl get secret suneasy-secrets -n suneasy-dev -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 -d
```

### GitHub Token

For the GitHub MCP server to work, set your GitHub token:

```bash
export GITHUB_TOKEN=your_github_personal_access_token
```

Or add it to your shell profile.

## Configuration Location

The MCP configuration is located at:
- **Claude Code (Global)**: `/root/.claude.json`

All servers have been configured using the `claude mcp add` command and are ready to use.

To view configured servers:
```bash
claude mcp list
```

To add a new MCP server:
```bash
claude mcp add --transport stdio <name> [--env KEY=VALUE] -- <command> [args...]
```

## Testing MCP Servers

After restarting Claude Code, the MCP servers should be automatically loaded. You can verify by asking Claude to:

- List projects in the Nx workspace (Nx MCP)
- Check Kubernetes pod status (Kubernetes MCP)
- List Docker containers (Docker MCP)
- Explore the codebase (Filesystem MCP)
- Query git history (Git MCP)

## Troubleshooting

### MCP Server Not Loading

1. Check Claude Code logs for errors
2. Verify package can be installed: `npx -y <package-name> --help`
3. For uvx commands, ensure `/root/.local/bin/uvx` exists

### PostgreSQL Connection Failed

1. Ensure port-forward is running: `kubectl port-forward svc/postgres -n suneasy-dev 5432:5432`
2. Test connection: `psql postgresql://localhost:5432/suneasy`
3. Check credentials in `suneasy-secrets`

### Kubernetes MCP Not Working

1. Verify kubectl context: `kubectl config current-context`
2. Ensure you can access cluster: `kubectl get pods -n suneasy-dev`
3. Check kubeconfig: `~/.kube/config`

## Benefits

These MCP servers provide Claude Code with:

- **Architectural awareness** of your Nx monorepo (40+ libraries, 6 apps)
- **Database insights** for PostgreSQL queries and schema
- **Infrastructure control** for Kubernetes and Docker
- **Version control** operations for Git/GitHub
- **Secure file access** with controlled permissions
- **Advanced reasoning** for complex architectural decisions
