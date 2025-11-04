# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**SunEasy** is a comprehensive sunbed/beach reservation platform with a full-stack microservices architecture:

- **Frontend**: Angular 20+ Nx monorepo (`suneasy/`) with 6 applications and 40+ shared libraries
- **Backend**: .NET 8.0 microservices (`SunEasyBE/`) with 14 services communicating via gRPC
- **Infrastructure**: Kubernetes (k3d) with Skaffold for hot-reload development
- **Package Manager**: Yarn 4.9.3 (frontend), .NET CLI (backend)

## Quick Start

**One command to rule them all:**

```bash
bash start-dev.sh
```

This script:
- Creates/starts k3d cluster (`suneasy-dev`)
- Installs Traefik and cert-manager
- Deploys all frontend and backend services
- Enables hot-reload via Skaffold
- Services persist after Ctrl+C

**Access URLs:**
- Admin: https://admin.test.suneasy.app
- Dashboard: https://dashboard.test.suneasy.app
- API: https://api.test.suneasy.app
- Landing: https://www.test.suneasy.app
- Client Web: https://app.test.suneasy.app
- Business: https://business.test.suneasy.app
- Client: https://client.test.suneasy.app
- Dev Tools: https://adminer.test.suneasy.app, https://mailhog.test.suneasy.app, https://rabbitmq.test.suneasy.app

**Default Login:** admin@sunsetparadise.com / password123

## Development Architecture

### Frontend Structure (`suneasy/`)

```
suneasy/
├── apps/                    # 6 Applications
│   ├── admin/              # Admin panel (web)
│   ├── business/           # Business mobile app (iOS/Android via Capacitor)
│   ├── client/             # Client mobile app (iOS/Android via Capacitor)
│   ├── client-web/         # Client web application
│   ├── dashboard/          # Dashboard web app
│   └── landing/            # Marketing/landing page
│
└── libs/                    # 40+ Shared Libraries (all prefixed 's-')
    ├── s-core/             # Core utilities (base for all apps)
    ├── s-model/            # ALL types, interfaces, constants (SINGLE SOURCE OF TRUTH)
    ├── s-http/             # HTTP client with interceptors
    ├── s-auth/             # Authentication & JWT handling
    ├── s-navigation/       # Navigation service (wraps Angular Router)
    ├── s-storage/          # Encrypted storage (Capacitor Preferences)
    ├── s-modal/            # Modal service (replaces alert/confirm)
    ├── s-payment/          # Stripe integration
    └── ... (40+ total libraries)
```

**Critical Rules:**
1. **Type Centralization**: ALL interfaces/types MUST be in `@suneasy/s-model` - no types elsewhere
2. **Module Boundaries**: Nx enforces strict boundaries - apps cannot import from each other
3. **No Direct Router**: Use `NavigationService` from `@suneasy/s-navigation` (except in guards/resolvers/app.config.ts)
4. **No Direct Storage**: Use `StorageService` from `@suneasy/s-storage` (encrypted, never localStorage/sessionStorage)
5. **No Browser Dialogs**: Use `ModalService` from `@suneasy/s-modal` (never alert/confirm/prompt)

### Backend Structure (`SunEasyBE/`)

```
SunEasyBE/
├── Core/                   # Shared core library (models, base classes, utilities)
├── ApiGateway/             # REST API Gateway (translates REST to gRPC)
└── Microservices/          # 13 gRPC microservices
    ├── Auth/               # Authentication & authorization
    ├── Organization/       # Organization management
    ├── Resource/           # Resource management
    ├── Reservation/        # Booking system
    ├── Payment/            # Payment processing
    ├── Media/              # Image/file management
    ├── Notification/       # Push notifications
    ├── Email/              # Email service
    ├── Sms/                # SMS service
    ├── Log/                # Logging service
    ├── Config/             # Configuration management
    ├── Review/             # Reviews & ratings
    └── Geolocation/        # Location services
```

**Backend Architecture:**
- All services share the `Core` project (models, base repositories, helpers)
- Services communicate internally via gRPC
- Frontend calls REST API Gateway, which translates to gRPC calls
- Proto files in `Core/Protos/` define service contracts
- Routes centrally defined in `Core/Constant/RouteConfig.cs`

## Common Development Commands

### Frontend (Angular/Nx)

**Run Development Servers:**
```bash
# Individual apps (localhost)
yarn nx serve client          # Mobile client app
yarn nx serve business        # Mobile business app
yarn nx serve dashboard       # Dashboard web
yarn nx serve landing         # Landing page
yarn nx serve admin           # Admin panel
yarn nx serve client-web      # Client web

# Network-accessible (for mobile device testing)
yarn live-client              # Serve on 0.0.0.0
yarn live-business
yarn live-dashboard
yarn live-landing
yarn live-admin
yarn live-client-web
```

**Build Applications:**
```bash
# Web apps (production)
yarn nx build dashboard --configuration=production
yarn nx build landing --configuration=production
yarn nx build admin --configuration=production
yarn nx build client-web --configuration=production

# Mobile apps (with Capacitor sync)
yarn build-client              # Build + sync
yarn build-client-android      # Build + sync + open Android Studio
yarn build-client-ios          # Build + sync + open Xcode
yarn build-business
yarn build-business-android
yarn build-business-ios

# Production builds (with config validation)
yarn build-client-prod
yarn build-client-android-prod
yarn build-client-ios-prod
yarn build-business-prod
yarn build-business-android-prod
yarn build-business-ios-prod

# No-budget builds (faster, no size limits)
yarn build-client-no-budget
yarn build-business-no-budget

# Build everything
yarn s-build
yarn s-build-prod
```

**Code Quality:**
```bash
# Linting
yarn s-lint                   # Lint all projects
yarn s-lint-fix               # Lint + auto-fix
yarn nx lint client           # Lint specific project

# Formatting
yarn s-prettier               # Format with Prettier

# Testing
yarn s-test                   # Run all tests
yarn s-test-coverage          # Tests with coverage
yarn nx test client           # Test specific project
yarn nx test client --watch   # Watch mode
```

**Code Generation:**
```bash
# New library (always prefixed 's-')
yarn nx g @nx/angular:lib s-my-feature

# New component (standalone by default)
yarn nx g @nx/angular:component my-component --project=client

# New service
yarn nx g @nx/angular:service my-service --project=s-core
```

### Backend (.NET)

The backend runs in Kubernetes via Skaffold. Direct .NET commands are typically not needed, but available:

```bash
# Build solution
cd SunEasyBE
dotnet build SunEasyBE.sln

# Build specific service
cd SunEasyBE/Auth
dotnet build

# Run tests
cd SunEasyBE/Tests/ApiGateway.Tests
dotnet test

# Add NuGet package to service
cd SunEasyBE/Auth
dotnet add package PackageName
```

### Kubernetes & Infrastructure

**Cluster Management:**
```bash
# Check cluster status
k3d cluster list
kubectl config current-context

# View pods
kubectl get pods -n suneasy-dev

# View logs
kubectl logs -f <pod-name> -n suneasy-dev

# Stop/start cluster
k3d cluster stop suneasy-dev
k3d cluster start suneasy-dev

# Full reset
k3d cluster delete suneasy-dev
bash start-dev.sh
```

**Hot Reload:**
- Managed by Skaffold automatically
- Frontend changes: 2-3 seconds
- Backend changes: 5-10 seconds
- File sync configured in `skaffold.yaml`
- Ctrl+C stops hot-reload but services keep running

## Critical Coding Standards (Frontend)

This project uses **extremely strict** TypeScript and Angular rules. See `suneasy/.cursorrules` and `suneasy/.github/copilot-instructions.md` for complete details.

### TypeScript Strictness

**Always Required:**
- ❌ **No `any` type ever** - Explicit types always
- ✅ Explicit return types on ALL functions
- ✅ Explicit types on ALL class properties
- ✅ Strict boolean expressions - `length > 0` not `length`
- ✅ Prefer nullish coalescing `??` over `||`
- ✅ Catch variables are `unknown` - narrow type before use
- ✅ Array access returns `T | undefined` - handle explicitly
- ✅ All code paths must return a value

### Modern Angular Patterns (MANDATORY)

**Component Requirements:**
- ✅ **Standalone components only** (no NgModule)
- ✅ **OnPush change detection** (mandatory)
- ✅ **Signal inputs/outputs** - Use `input<T>()`, `output<T>()` instead of `@Input`, `@Output`
- ✅ **New control flow** - `@if`, `@for`, `@switch` (no `*ngIf`, `*ngFor`, `*ngSwitch`)
- ✅ **Always `track` in `@for`** - `@for (item of items(); track item.id)`
- ✅ **inject()** function preferred over constructor injection
- ✅ **Explicit accessibility** - `public`/`private`/`protected` on all members
- ✅ **ViewChild/ContentChild** must specify `{ static: true/false }`

**Component Template:**
```typescript
import { Component, ChangeDetectionStrategy, computed, signal, input, output, inject } from '@angular/core';
import { TranslatePipe } from '@ngx-translate/core';
import type { User } from '@suneasy/s-model';

@Component({
  selector: 's-user-profile',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [TranslatePipe],
  templateUrl: './user-profile.component.html',
  styleUrls: ['./user-profile.component.scss']
})
export class UserProfileComponent {
  // Signal inputs/outputs
  user = input.required<User>();
  userChange = output<User>();

  // Private signals
  private count = signal<number>(0);

  // Computed (memoized - use instead of functions)
  public displayName = computed(() => this.user().name);

  // Dependency injection
  private readonly http = inject(HttpClient);

  public updateUser(): void {
    this.userChange.emit(this.user());
  }
}
```

**Template with New Control Flow:**
```html
@if (user(); as currentUser) {
  <div class="tw-p-4">
    <h1>{{ 'USER_TITLE' | translate }}</h1>
    <p>{{ currentUser.name }}</p>
  </div>
}

@for (item of items(); track item.id) {
  <div>{{ item.name }}</div>
}

@switch (status()) {
  @case ('active') {
    <span class="tw-text-green-500">{{ 'STATUS_ACTIVE' | translate }}</span>
  }
  @default {
    <span class="tw-text-gray-500">{{ 'STATUS_UNKNOWN' | translate }}</span>
  }
}
```

### Performance Rules

- ❌ **No function calls in templates** - Use computed signals (memoized)
- ✅ Computed signals for expensive calculations
- ✅ `track` required in ALL `@for` loops
- ❌ No forced reflows (reading `offsetHeight`, `scrollTop` - use observers)
- ✅ Specific imports only - No `import * as rxjs`

### Security Requirements

- ❌ **No localStorage/sessionStorage** - Use `StorageService` from `@suneasy/s-storage`
- ❌ **No Math.random() for security** - Use `crypto.getRandomValues()`
- ❌ **No innerHTML** - Use Angular sanitization
- ❌ **No hardcoded secrets/API keys**
- ❌ **No alert/confirm/prompt** - Use `ModalService`
- ❌ **No eval() or new Function()**

### Styling & i18n

- ✅ **TailwindCSS only** - All classes use `tw-` prefix
- ❌ **No inline styles** - No `style` attribute, no `[ngStyle]`, no `[style.x]`
- ❌ **No hardcoded text** - ALL user-facing text uses `translate` pipe
- ✅ Translate attributes - `[placeholder]="'KEY' | translate"`

### Code Quality Limits

- Max 300 lines per file
- Max 30 lines per function (40 for mobile apps)
- Max complexity: 6 (8 for mobile apps)
- Max 3 function parameters (use object parameter for more)
- No magic numbers (import constants from `@suneasy/s-model`)
- Boolean variables must have `is/has/can/should` prefix
- No duplicate strings (max 2 occurrences)

### Import Organization

Auto-sorted by ESLint:
1. Angular framework (`@angular/**`)
2. External packages (npm)
3. Internal workspace (`@suneasy/**`)
4. Relative imports (`./`, `../`)

Blank line between groups, alphabetical within groups, use `import type` for types.

## Backend Development Patterns

### Migrating Monolith to Microservices

1. **Create Proto File** in `Core/Protos/` based on controller
2. **Add to csproj** in both microservice and API Gateway
3. **Update API Gateway Controller** to match proto methods
4. **Implement gRPC Service** in microservice (see `Auth/` for example)
5. **Create Repository** in microservice for database access

**Key Rules:**
- Only use DTOs generated by proto file (no manual DTOs)
- Import models from Core project
- Namespace must match microservice name
- Always inherit from Core project base classes
- No hardcoded values - use project settings
- Use Dapper for Organization and Reservation services

### Adding New Routes

1. **Define route constant** in `Core/Constant/RouteConfig.cs`
2. **Add HttpPath object** with path, method, and roles
3. **Add to AllowedRoutesForAll or AllRoutes** list
4. **Implement in controller** using route constant

## Infrastructure Details

### Kubernetes Configuration

- **Cluster**: k3d (lightweight K8s in Docker)
- **Ingress**: Traefik LoadBalancer
- **TLS**: cert-manager with Let's Encrypt (Cloudflare DNS challenge)
- **Namespace**: `suneasy-dev`
- **Registry**: `localhost:9500` (k3d internal)

**Manifest Structure:**
```
k8s/
├── base/
│   ├── namespace.yaml
│   ├── cert-manager/
│   └── secrets/
└── overlays/dev/
    ├── infrastructure/     # PostgreSQL, RabbitMQ, MailHog, Adminer
    ├── backend/            # 14 .NET microservices
    ├── frontend/           # 6 Angular apps
    └── ingress/            # Traefik routes + TLS
```

### Hot Reload with Skaffold

Skaffold watches file changes and syncs to running pods:
- **Frontend**: `apps/{app}/src/**/*` and `libs/*/src/**/*` → Auto-reload
- **Backend**: `{Service}/**/*.cs` and `Core/**/*.cs` → Auto-rebuild

Configure in `skaffold.yaml` under `build.artifacts[].sync.manual`.

### DNS & TLS

**Production (Cloudflare):**
- Wildcard A record: `*.test.suneasy.app` → LoadBalancer IP
- TLS certificates issued automatically by Let's Encrypt

**Local Testing:**
Add to `/etc/hosts`:
```
127.0.0.1 admin.test.suneasy.app
127.0.0.1 dashboard.test.suneasy.app
127.0.0.1 api.test.suneasy.app
# ... etc
```

## Troubleshooting

**Frontend won't build:**
- Check ESLint errors - strict rules enforced
- Verify all types are imported from `@suneasy/s-model`
- No magic numbers, no hardcoded strings
- See `suneasy/.cursorrules` for complete rules

**Backend service won't start:**
- Check `kubectl logs <pod-name> -n suneasy-dev`
- Verify proto files are in both microservice and ApiGateway csproj
- Ensure database connection strings in secrets

**Hot reload not working:**
- Verify Skaffold is running (`bash start-dev.sh`)
- Check sync paths in `skaffold.yaml`
- Ensure files match sync patterns

**Can't access domains:**
- Verify DNS: `dig admin.test.suneasy.app` or check `/etc/hosts`
- Get LoadBalancer IP: `kubectl get svc traefik -n traefik`
- Check Ingress: `kubectl get ingress -n suneasy-dev`

**Certificate issues:**
- Check cert-manager: `kubectl get certificaterequests -n suneasy-dev`
- Verify Cloudflare token: `kubectl get secret cloudflare-api-token -n cert-manager`
- Use staging issuer for testing: Change annotation to `letsencrypt-staging`

## Additional Resources

- Frontend coding rules: `suneasy/.cursorrules`
- Frontend Copilot instructions: `suneasy/.github/copilot-instructions.md`
- Existing CLAUDE.md: `suneasy/CLAUDE.md` (frontend-specific)
- Backend migration guide: `SunEasyBE/Documents/DEV_README.md`
- Backend architecture: `SunEasyBE/docs/README.md`
- Root README: `README.md`
- Port configuration: `PORTS.md`