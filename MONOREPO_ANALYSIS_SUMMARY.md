# SunEasy Nx Monorepo - Quick Reference Summary

## Key Statistics

| Metric | Value |
|--------|-------|
| **Applications** | 6 (2 mobile, 4 web) |
| **Shared Libraries** | 40 (all prefixed `s-`) |
| **Tier Levels** | 6 (0-5 with acyclic constraints) |
| **Angular Version** | 20.3.2 (latest) |
| **TypeScript Version** | 5.9.2 (strict mode) |
| **Nx Version** | 22.0.1 |
| **Package Manager** | Yarn 4.9.3 |
| **Code Lines** | ~22K (mostly libraries) |
| **Capacitor Plugins** | 15+ (Stripe, Barcode, Calendar, etc.) |

---

## Applications (6 Total)

### Mobile Apps (Capacitor)
- **client** (Port 4200) - End-user mobile app
- **business** (Port 4201) - Vendor/business mobile app

### Web Apps (Angular)
- **dashboard** (Port 4202) - Business dashboard (SSR)
- **landing** (Port 4203) - Marketing landing page
- **admin** (Port 4204) - Admin control panel (SSR)
- **client-web** (Port 4205) - Web version of client app

---

## Library Tiers (40 Libraries)

### Tier 0: Primitives (ZERO Dependencies)
- `s-model` - Types, interfaces, constants (SINGLE SOURCE OF TRUTH)
- `s-styles` - TailwindCSS & SCSS base
- `s-browser` - Browser detection utilities
- `s-platform` - Platform detection & capabilities

### Tier 1: Platform Services
- `s-http` - HTTP client with interceptors
- `s-storage` - Encrypted storage (Capacitor Preferences)
- `s-analytics` - Analytics tracking
- `s-i18n` - i18n & translation management

### Tier 2: Platform-Specific
- `s-native-tools` - Capacitor plugins wrapper (mobile only)

### Tier 3: Foundation UI
- `s-core` - Core utilities & base components
- `s-directives` - Custom directives
- `s-loader` - Loading spinner component
- `s-modal` - Modal service & components
- `s-skeleton` - Skeleton loader components
- `s-splash` - Splash screen (mobile only)

### Tier 4: Feature Services
- `s-auth` - Authentication & JWT handling
- `s-navigation` - Navigation service (router wrapper)
- `s-notification` - Push notifications
- `s-app-settings` - App configuration
- `s-app-updater` - Mobile app updates (Capacitor)
- `s-builder` - Dynamic form builder

### Tier 5: Domain Components & Features (20+ libs)
- `s-widgets` - Base reusable UI components
- `s-widgets-shared` - Shared widget variations
- `s-payment` - Stripe payment integration
- `s-calendar` - Calendar component & utilities
- `s-gallery` - Image gallery component
- `s-search` - Search functionality
- `s-scan` - QR code scanning (mobile)
- `s-story` - Story/feed components (client)
- `s-business-flow` - Business workflows (business)
- `s-invoice` - Invoice management (business)
- `s-order` - Order management (business)
- `s-report` - Business reporting (business)
- `s-destination` - Location/destination features
- `s-partials` - Reusable page sections
- `s-widgets-admin` - Admin-specific widgets (admin)
- Plus others...

---

## Architecture Highlights

### What Makes It Different

1. **Tiered Dependency System**
   - 6 tiers (0-5) with strict constraints
   - Tier N can only depend on Tier N-1 and below
   - Prevents circular dependencies, enforces clean architecture

2. **Complete App Isolation**
   - Apps CANNOT import from each other
   - Enforced by ESLint + Nx module boundaries
   - All sharing MUST go through libraries

3. **Scope-Based Organization**
   - `shared` - All apps
   - `mobile` - Mobile apps only (client, business)
   - `web` - Web apps only (dashboard, landing, admin, client-web)
   - `client` / `business` / `admin` - Single app scope

4. **Maximum TypeScript Strictness**
   - No `any` type
   - Explicit return types on all functions
   - Explicit types on all class properties
   - `noUnusedLocals`, `noUnusedParameters`
   - `exactOptionalPropertyTypes`, `noUncheckedIndexedAccess`
   - Catch variables are `unknown` (must narrow type)

5. **Modern Angular Patterns (Mandatory)**
   - Standalone components only (no NgModule)
   - OnPush change detection on all components
   - Signal inputs/outputs: `input<T>()`, `output<T>()`
   - New control flow: `@if`, `@for`, `@switch`
   - `track` required in all `@for` loops
   - `inject()` preferred over constructor injection
   - No function calls in templates (use computed signals)

---

## Key Rules Enforced by ESLint

### No Allowed
- ❌ `any` type - Explicit types always
- ❌ Cross-app imports - Use libraries instead
- ❌ localStorage/sessionStorage - Use StorageService
- ❌ Math.random() for security - Use crypto.getRandomValues()
- ❌ innerHTML - Use Angular sanitization
- ❌ alert/confirm/prompt - Use ModalService
- ❌ Direct router usage - Use NavigationService
- ❌ Function calls in templates - Use computed signals
- ❌ NgModule imports - Standalone components only

### Always Required
- ✅ Explicit return types on functions
- ✅ Explicit types on class properties
- ✅ OnPush change detection on components
- ✅ `track` in all `@for` loops
- ✅ Boolean variables: `is/has/can/should` prefix
- ✅ Proper import ordering (Angular, npm, workspace, relative)
- ✅ No unused imports or variables
- ✅ Explicit type narrowing in catch blocks

---

## Technology Stack

**Core Framework:**
- Angular 20.3.2 with new control flow & signals
- TypeScript 5.9.2 (maximum strict mode)
- RxJS 7.8.1

**Mobile:**
- Capacitor 7.4.3 (iOS/Android bridge)
- Stripe integration, QR scanning, calendar, push notifications

**Styling:**
- TailwindCSS 3.4.17 (all CSS classes use `tw-` prefix)
- SCSS for component-specific styles

**i18n:**
- @ngx-translate/core 17.0.0 (all text uses translate pipe)

**Testing:**
- Jest 29.7.0 (unit tests)
- Cypress 14.3.1 (E2E tests)

**Build Tools:**
- Nx 22.0.1 (monorepo orchestration)
- Webpack (bundling)
- ng-packagr (library builds)
- SWC (TypeScript compilation)

**Development:**
- Skaffold (hot reload, file sync to Kubernetes)
- k3d (local Kubernetes cluster)
- Prettier (code formatting)
- ESLint with flat config

---

## Common Commands

### Development
```bash
# Start everything (one command)
bash start-dev.sh

# Serve individual apps (localhost)
yarn nx serve client
yarn nx serve business
yarn nx serve dashboard

# Serve on network (for mobile testing)
yarn live-client
yarn live-business
```

### Building
```bash
yarn s-build                    # All apps
yarn build-client-prod          # Mobile prod + Capacitor
yarn build-client-android       # Mobile + Android Studio
yarn build-dashboard            # Single web app
```

### Testing & Quality
```bash
yarn s-test                     # All unit tests
yarn s-test-coverage            # With coverage
yarn s-lint                     # Lint all
yarn s-lint-fix                 # Lint + auto-fix
yarn s-prettier                 # Format all
```

### Analysis
```bash
yarn optimize                   # Full bundle analysis
yarn nx graph                   # Dependency graph visualization
yarn nx show project client     # Project details
```

---

## Module Boundary System

### Tier Constraints (Enforced by ESLint)
```
Tier 5 can depend on → Tier 4, 3, 2, 1, 0 only
Tier 4 can depend on → Tier 3, 2, 1, 0 only
Tier 3 can depend on → Tier 2, 1, 0 only
Tier 2 can depend on → Tier 1, 0 only
Tier 1 can depend on → Tier 0 only
Tier 0 can depend on → npm packages ONLY
```

### Platform Isolation (Enforced)
```
Mobile apps (Capacitor) ≠ Web apps
Web apps ≠ Electron (future-proofed)
```

### App Isolation (Enforced)
```
client app ≠ business app ≠ admin app ≠ dashboard app ≠ landing app ≠ client-web app
Apps can ONLY import from:
  - scope:shared libraries
  - scope:{app-name} libraries
  - scope:web/mobile (depending on platform)
```

---

## Library Organization by Scope

### Shared (All Apps)
Most libraries: s-model, s-core, s-http, s-widgets, s-auth, s-payment, s-calendar, s-search, etc.

### Mobile Only (client + business)
- s-native-tools
- s-splash
- s-app-updater
- s-scan

### Web Only (dashboard, landing, admin, client-web)
- s-browser (web detection only)

### Client App Only
- s-story

### Business App Only
- s-invoice
- s-order
- s-report
- s-business-flow

### Admin App Only
- s-widgets-admin

---

## Code Quality Targets

- **Max file size:** 300 lines
- **Max function size:** 30 lines (40 for mobile)
- **Max complexity:** 6 (8 for mobile)
- **Max function params:** 3 (use object parameter for more)
- **Bundle size (initial):** 500KB warning, 1MB error
- **Code coverage target:** 80%+
- **No magic numbers** (import constants from s-model)

---

## Critical Patterns to Follow

### Component Structure (Mandatory)
```typescript
@Component({
  selector: 's-feature-name',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [TranslatePipe, OtherComponents],
  templateUrl: './feature-name.component.html',
  styleUrls: ['./feature-name.component.scss']
})
export class FeatureNameComponent {
  // Signal inputs/outputs
  data = input.required<Data>();
  dataChange = output<Data>();

  // Private signals
  private count = signal<number>(0);

  // Computed (memoized)
  public displayValue = computed(() => this.data().value);

  // Dependency injection
  private readonly http = inject(HttpClient);
  private readonly nav = inject(NavigationService);

  // Methods
  public handleChange(value: Data): void {
    this.dataChange.emit(value);
  }
}
```

### Template Structure
```html
@if (data(); as item) {
  <div class="tw-p-4">
    <h1>{{ 'TITLE_KEY' | translate }}</h1>
    
    @for (child of item.children; track child.id) {
      <p>{{ child.name }}</p>
    }
    
    @switch (item.status) {
      @case ('active') {
        <span class="tw-text-green-500">Active</span>
      }
      @default {
        <span class="tw-text-gray-500">Inactive</span>
      }
    }
  </div>
}
```

### Service Pattern
```typescript
@Injectable({ providedIn: 'root' })
export class MyService {
  private http = inject(HttpClient);
  private storage = inject(StorageService);

  public getData(): Observable<Data> {
    return this.http.get<Data>('/api/data');
  }

  public saveData(data: Data): void {
    this.storage.set('data_key', data);
  }
}
```

---

## Import Organization (Auto-sorted)

```typescript
// 1. Angular framework
import { Component, ChangeDetectionStrategy, computed, input, output, inject } from '@angular/core';

// 2. External packages (alphabetical)
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

// 3. Internal workspace (alphabetical by library)
import { CoreService } from '@suneasy/s-core';
import { NavigationService } from '@suneasy/s-navigation';
import type { User } from '@suneasy/s-model';

// 4. Relative imports (alphabetical)
import { LocalService } from './local.service';
```

---

## Deployment

### Kubernetes Integration
```bash
# Everything is containerized & orchestrated
# Services deployed to k3d cluster (local) or production K8s
# Skaffold enables hot reload during development
# TLS via cert-manager with Cloudflare DNS challenge
# Ingress via Traefik LoadBalancer
```

### Access URLs (Local Development)
```
https://admin.test.suneasy.app
https://dashboard.test.suneasy.app
https://api.test.suneasy.app
https://app.test.suneasy.app
https://business.test.suneasy.app
https://client.test.suneasy.app
https://www.test.suneasy.app
```

### Mobile Deployment
```bash
# iOS: Open Xcode, sign, build to App Store
yarn build-client-ios
cd apps/client && yarn cap open ios

# Android: Open Android Studio, sign, build to Play Store
yarn build-client-android
cd apps/client && yarn cap open android
```

---

## Unique Architectural Decisions

1. **Tiered System** - Most monorepos use flat tags. SunEasy enforces a 6-tier acyclic system.

2. **Scope Isolation** - Goes beyond app tags with `scope:shared/mobile/web/client/business/admin`.

3. **No Cross-App Imports** - Absolute enforcement via ESLint, not just recommendation.

4. **s-model as SSOT** - All types defined in ONE library. No scattered interfaces.

5. **Platform Isolation** - Mobile/Web/Electron libraries can't mix (even future-proofing).

6. **Maximum TypeScript** - Goes beyond standard strict mode with exact optionals, unchecked indexed access, etc.

7. **Signals + OnPush Only** - No legacy directives, no change detection cycles.

8. **Automated Rule Enforcement** - ESLint catches violations, not code review.

---

## For New Developers

**Important Rules to Remember:**

1. ✅ All code in libraries (not apps)
2. ✅ All types in s-model
3. ✅ Use StorageService, not localStorage
4. ✅ Use NavigationService, not router directly
5. ✅ Use ModalService, not alert/confirm
6. ✅ No cross-app imports (ESLint will fail)
7. ✅ Signals + OnPush on all components
8. ✅ Track required in all @for loops
9. ✅ Explicit types everywhere
10. ✅ No hardcoded strings (use translate pipe)

**First Steps:**
```bash
# Clone & setup
bash start-dev.sh

# Explore the codebase
yarn nx graph

# Look at existing libraries for patterns
# Check CLAUDE.md for rules
# Read .cursorrules for AI assistance guidelines

# Run tests to ensure environment works
yarn s-test
```

---

**For detailed analysis:** See `/root/projects/suneasy/SUNNEASY_NX_MONOREPO_ANALYSIS.md`

**Generated:** November 4, 2025
