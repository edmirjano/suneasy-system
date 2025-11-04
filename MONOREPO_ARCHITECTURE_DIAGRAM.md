# SunEasy Nx Monorepo - Architecture Diagrams & Visual Reference

## 1. Application Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         SunEasy Frontend                            │
│                      Angular 20.3.2 + Nx 22                        │
└─────────────────────────────────────────────────────────────────────┘

        ┌─────────────────────────────────────────────────────┐
        │           6 Applications (Apps)                     │
        ├─────────────────────────────────────────────────────┤
        │                                                     │
        │  Mobile (Capacitor)          Web (Angular)         │
        │  ───────────────────         ──────────────        │
        │  • client       (4200)       • dashboard   (4202)  │
        │  • business     (4201)       • landing     (4203)  │
        │                             • admin       (4204)  │
        │                             • client-web  (4205)  │
        │                                                     │
        └─────────────────────────────────────────────────────┘
                           ▲
                           │
                    imports from
                           │
        ┌─────────────────────────────────────────────────────┐
        │        40+ Shared Libraries (All s-*)              │
        ├─────────────────────────────────────────────────────┤
        │                                                     │
        │  Tier 5: Domain Features (20 libs)                │
        │  ├─ s-widgets, s-payment, s-calendar              │
        │  ├─ s-business-flow, s-invoice, s-order           │
        │  └─ s-story, s-scan, s-search, etc.               │
        │                                                     │
        │  Tier 4: Feature Services (4 libs)                │
        │  ├─ s-auth, s-navigation, s-notification          │
        │  └─ s-builder, s-app-settings, s-app-updater      │
        │                                                     │
        │  Tier 3: Foundation UI (5 libs)                   │
        │  ├─ s-core, s-modal, s-directives                 │
        │  ├─ s-loader, s-skeleton, s-splash                │
        │  └─                                                │
        │                                                     │
        │  Tier 2: Platform Services (1 lib)                │
        │  └─ s-native-tools (Capacitor wrappers)           │
        │                                                     │
        │  Tier 1: Core Services (4 libs)                   │
        │  ├─ s-http, s-storage, s-i18n                     │
        │  └─ s-analytics                                    │
        │                                                     │
        │  Tier 0: Primitives (4 libs)                      │
        │  ├─ s-model (TYPES), s-styles, s-browser          │
        │  └─ s-platform                                     │
        │                                                     │
        └─────────────────────────────────────────────────────┘
                           ▲
                           │
                    depends on
                           │
        ┌─────────────────────────────────────────────────────┐
        │         External Dependencies (npm)                │
        ├─────────────────────────────────────────────────────┤
        │                                                     │
        │  @angular/*, RxJS, TailwindCSS, @ngx-translate     │
        │  Capacitor, Stripe, TypeScript, ESLint            │
        │  Jest, Cypress, SWC, ng-packagr                   │
        │                                                     │
        └─────────────────────────────────────────────────────┘
```

---

## 2. Tiered Dependency System (The Key Innovation)

```
TIER 5: Domain Components & Features
├─ s-widgets (UI components)
├─ s-payment (Stripe integration)
├─ s-calendar, s-search, s-gallery
├─ s-business-flow, s-invoice, s-order (business scope)
├─ s-story (client scope)
└─ s-widgets-admin, s-widgets-business, s-widgets-client (scope-specific)
    │
    │ can only import
    ▼
TIER 4: Feature Services
├─ s-auth (Authentication)
├─ s-navigation (Router wrapper)
├─ s-notification (Push notifications)
├─ s-builder (Form builder)
├─ s-app-settings (Configuration)
└─ s-app-updater (Mobile updates)
    │
    │ can only import
    ▼
TIER 3: Foundation UI
├─ s-core (Base services & components)
├─ s-modal (Modal service)
├─ s-directives (Custom directives)
├─ s-loader (Loading spinner)
├─ s-skeleton (Skeleton screens)
└─ s-splash (Splash screen - mobile)
    │
    │ can only import
    ▼
TIER 2: Platform-Specific
└─ s-native-tools (Capacitor wrapper - mobile only)
    │
    │ can only import
    ▼
TIER 1: Platform Services
├─ s-http (HTTP client with interceptors)
├─ s-storage (Encrypted storage service)
├─ s-i18n (i18n setup)
└─ s-analytics (Analytics tracking)
    │
    │ can only import
    ▼
TIER 0: Primitives (ZERO DEPENDENCIES)
├─ s-model (Types, interfaces, constants) ← SINGLE SOURCE OF TRUTH
├─ s-styles (TailwindCSS base)
├─ s-browser (Browser detection)
└─ s-platform (Platform capabilities)
    │
    │ can only import
    ▼
External (npm packages ONLY)
├─ @angular/*, RxJS, TailwindCSS, @ngx-translate
└─ Capacitor, Stripe, TypeScript, etc.
```

**Key Constraint:** Each tier ONLY depends on tiers below it. No upward dependencies allowed.

---

## 3. Scope-Based Access Control

```
┌──────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                        │
│                  (6 Applications)                            │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Mobile Apps              Web Apps                           │
│  ────────────             ────────                          │
│  • client                 • dashboard                       │
│  • business               • landing                         │
│                           • admin                           │
│                           • client-web                      │
│                                                              │
└──────────────────────────────────────────────────────────────┘
        ▼                           ▼
    Can import          Can import both:
    libraries with:     ├─ scope:shared
    ├─ scope:shared     ├─ scope:web
    ├─ scope:mobile     └─ scope:business
    └─ scope:client/business (specific apps only)
        │
        ▼
┌──────────────────────────────────────────────────────────────┐
│                    LIBRARY LAYER                             │
│                  (40+ Libraries)                             │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  scope:shared (30+ libraries)                               │
│  ├─ Can be imported by ANY app                              │
│  ├─ s-http, s-storage, s-auth, s-widgets, s-payment        │
│  └─ s-calendar, s-search, s-gallery, etc.                  │
│                                                              │
│  scope:mobile (4 libraries)                                 │
│  ├─ Can be imported by: client, business apps only         │
│  ├─ s-native-tools, s-splash, s-scan                       │
│  └─ s-app-updater                                          │
│                                                              │
│  scope:web (1 library)                                      │
│  ├─ Can be imported by: web apps only                       │
│  └─ s-browser                                              │
│                                                              │
│  scope:client (1 library)                                   │
│  ├─ Can be imported by: client app only                     │
│  └─ s-story                                                │
│                                                              │
│  scope:business (4 libraries)                               │
│  ├─ Can be imported by: business app only                   │
│  ├─ s-invoice, s-order, s-report                           │
│  └─ s-business-flow                                        │
│                                                              │
│  scope:admin (1 library)                                    │
│  ├─ Can be imported by: admin app only                      │
│  └─ s-widgets-admin                                        │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

**Result:** Complete app isolation + controlled sharing of features.

---

## 4. Module Boundary Enforcement (ESLint)

```
┌─────────────────────────────────────────────────────────────┐
│              ESLint Configuration (eslint.config.js)         │
└─────────────────────────────────────────────────────────────┘

①  @nx/enforce-module-boundaries
   └─ Tier system (0-5 constraints)
   └─ Scope constraints (shared, mobile, web, etc.)
   └─ App isolation (no cross-app imports)
   └─ Platform isolation (mobile vs web)
        │
        ├─ Violation: Upward dependency
        │ Example: s-http trying to import s-widgets (Tier 1 → Tier 5)
        │ Error: ❌ @nx/enforce-module-boundaries
        │
        ├─ Violation: Cross-app import
        │ Example: client app importing from business app
        │ Error: ❌ @nx/enforce-module-boundaries
        │
        └─ Violation: Platform mismatch
         Example: Web app importing s-scan (mobile-only)
         Error: ❌ @nx/enforce-module-boundaries

②  TypeScript Rules
   ├─ @typescript-eslint/no-explicit-any
   │  └─ Error: No `any` type allowed
   │
   ├─ @typescript-eslint/explicit-function-return-type
   │  └─ Warn: All functions need explicit return types
   │
   └─ @typescript-eslint/no-unused-vars
      └─ Error: No dead code

③  Angular Rules
   ├─ Standalone components required (no NgModule)
   ├─ OnPush change detection required
   └─ Signal inputs/outputs preferred over @Input/@Output

④  Security Rules
   ├─ No localStorage (use StorageService)
   ├─ No Math.random() (use crypto.getRandomValues())
   ├─ No innerHTML (use sanitization)
   └─ No hardcoded secrets

⑤  Performance Rules
   ├─ No function calls in templates (use computed signals)
   └─ track required in all @for loops

⑥  Import Organization
   ├─ Angular framework imports first
   ├─ npm packages second (alphabetical)
   ├─ @suneasy workspace imports third (alphabetical)
   └─ Relative imports last (alphabetical)
   └─ Auto-sorted by ESLint

RESULT: 700+ lines of automated enforcement
        Violations caught immediately, not in code review
```

---

## 5. Data Flow: Frontend to Backend

```
Angular Component (apps/client)
    │
    ├─ Injects HttpService (@suneasy/s-http)
    │
    ▼
HTTP Service (Tier 1)
    │
    ├─ Adds JWT token (from StorageService)
    ├─ Sets error handling
    ├─ Manages loading state
    │
    ▼
HTTP Interceptors
    │
    ├─ Authorization: Authorization Bearer {token}
    ├─ Error Handling: Convert errors to observables
    ├─ Retry Logic: Retry failed requests
    │
    ▼
REST API Gateway (.NET)
    │
    ├─ Route: POST /api/reservations
    ├─ Request: ReservationDTO (from @suneasy/s-model)
    │
    ▼
.NET API Gateway
    │
    ├─ Validates request
    ├─ Checks JWT token
    │
    ▼
gRPC Microservices (.NET)
    │
    ├─ Reservation Service
    ├─ Processes business logic
    │
    ▼
PostgreSQL Database
    │
    └─ Persists data

Response flows back through same path:
PostgreSQL → gRPC → API Gateway → HTTP → Interceptors → Component

TYPE SAFETY:
• Frontend: Types from @suneasy/s-model (TypeScript interfaces)
• Backend: Generated from proto files
• Result: Type-safe end-to-end communication
```

---

## 6. Library Dependency Graph (Simplified)

```
Apps Import From:

client app                business app              dashboard app
│                         │                         │
├─ @suneasy/s-widgets     ├─ @suneasy/s-widgets     ├─ @suneasy/s-core
├─ @suneasy/s-auth        ├─ @suneasy/s-invoice     ├─ @suneasy/s-payment
├─ @suneasy/s-payment     ├─ @suneasy/s-order       ├─ @suneasy/s-search
├─ @suneasy/s-story       ├─ @suneasy/s-report      ├─ @suneasy/s-calendar
├─ @suneasy/s-scan        ├─ @suneasy/s-business-flow
├─ @suneasy/s-native-tools├─ @suneasy/s-native-tools
└─ @suneasy/s-navigation  └─ @suneasy/s-navigation
   (+ shared libraries)      (+ shared libraries)    (+ shared libraries)
   │                         │                       │
   └─────────────────────────┴───────────────────────┘
                              │
                              ▼
                     Shared Libraries (scope:shared)
                     
s-widgets          s-auth           s-navigation
│                  │                │
├─ @suneasy/s-core ├─ @suneasy/s-http
│                  ├─ @suneasy/s-storage
s-payment          └─ @suneasy/s-core
│                  
├─ @suneasy/s-http
└─ @suneasy/s-storage
                   All depend on:
                   
                   ┌──────────────────────┐
                   │   @suneasy/s-model   │  ← SINGLE SOURCE OF TRUTH
                   │  (Tier 0: Types)     │
                   └──────────────────────┘
                            │
                   ┌──────────┴──────────┐
                   │                    │
            s-styles, s-platform    npm packages
```

---

## 7. File Structure (Complete Hierarchy)

```
suneasy/
├── apps/                          # 6 Applications
│   ├── client/
│   │   ├── src/
│   │   │   ├── app/              # App-specific code (minimal)
│   │   │   ├── environments/      # Config per environment
│   │   │   ├── main.ts            # Bootstrap
│   │   │   └── styles.scss        # App styles
│   │   ├── project.json           # Nx config + tags
│   │   ├── tsconfig.app.json
│   │   └── jest.config.ts
│   │
│   ├── business/                 # Similar structure
│   ├── dashboard/                # Web app (SSR support)
│   ├── landing/                  # Web app (SSR support)
│   ├── admin/                    # Web app (SSR support)
│   ├── client-web/               # Web app
│   └── client-web-e2e/           # E2E tests
│
├── libs/                          # 40+ Shared Libraries
│   ├── s-model/                  # Tier 0: Types (SINGLE SOURCE)
│   │   ├── src/
│   │   │   ├── lib/
│   │   │   │   ├── auth/
│   │   │   │   ├── organization/
│   │   │   │   ├── reservation/
│   │   │   │   ├── user/
│   │   │   │   ├── resource/
│   │   │   │   ├── constants/
│   │   │   │   └── ...
│   │   │   └── index.ts          # Exports all types
│   │   ├── project.json          # Tags: tier:0
│   │   └── ng-package.json
│   │
│   ├── s-core/                   # Tier 3: Base UI + Services
│   │   ├── src/
│   │   │   ├── lib/
│   │   │   │   ├── services/
│   │   │   │   ├── pipes/
│   │   │   │   ├── directives/
│   │   │   │   └── components/
│   │   │   └── index.ts
│   │   ├── i18n/                 # i18n files (auto-bundled)
│   │   └── jest.config.ts
│   │
│   ├── s-http/                   # Tier 1: HTTP Client
│   ├── s-auth/                   # Tier 4: Auth Feature
│   ├── s-payment/                # Tier 5: Payment Feature
│   ├── s-widgets/                # Tier 5: UI Components
│   ├── s-widgets-admin/          # Tier 5: Admin scope
│   ├── s-widgets-business/       # Tier 5: Business scope
│   ├── s-widgets-client/         # Tier 5: Client scope
│   │
│   └── ... (30+ more libraries)
│
├── tools/                         # Custom generators & utilities
│   └── ...
│
├── scripts/                       # Optimization & validation
│   ├── validate-production-config.sh
│   ├── fix-type-imports.js
│   └── optimization-tools.js
│
├── nx.json                        # Nx workspace configuration
├── package.json                   # Dependencies + scripts
├── tsconfig.base.json             # Base TypeScript config + path aliases
├── eslint.config.js               # ESLint rules (700+ lines)
├── jest.config.ts                 # Jest configuration
├── tailwind.config.shared.js       # TailwindCSS base config
├── .cursorrules                   # AI assistant rules
├── .prettierrc                     # Code formatting rules
│
└── dist/                          # Build outputs
    ├── apps/                      # Compiled apps
    └── libs/                      # Packaged libraries
```

---

## 8. Development Workflow

```
┌─────────────────────────────────────────────────────┐
│  Developer                                          │
│  ├─ Runs: bash start-dev.sh                         │
│  └─ (One command setup)                             │
└─────────────────────────────────────────────────────┘
             ▼
┌─────────────────────────────────────────────────────┐
│  Kubernetes Setup (k3d)                             │
│  ├─ Creates k3d cluster                             │
│  ├─ Installs Traefik LoadBalancer                   │
│  ├─ Installs cert-manager (TLS)                     │
│  └─ Sets up Cloudflare DNS challenge                │
└─────────────────────────────────────────────────────┘
             ▼
┌─────────────────────────────────────────────────────┐
│  Infrastructure Deployment                         │
│  ├─ PostgreSQL database                             │
│  ├─ RabbitMQ message queue                          │
│  ├─ MailHog (email testing)                         │
│  └─ Adminer (DB admin UI)                           │
└─────────────────────────────────────────────────────┘
             ▼
┌─────────────────────────────────────────────────────┐
│  Skaffold File Sync & Hot Reload                   │
│  ├─ Watches: apps/*/src, libs/*/src                │
│  ├─ Syncs files to running pods                     │
│  ├─ Frontend reload: 2-3 seconds                    │
│  └─ Backend rebuild: 5-10 seconds                   │
└─────────────────────────────────────────────────────┘
             ▼
┌─────────────────────────────────────────────────────┐
│  Local Testing (Ctrl+C stops sync but keeps running)│
│  ├─ Access: https://admin.test.suneasy.app         │
│  ├─ Edit files → Auto-deploy                        │
│  ├─ Services persistent (restart services later)    │
│  └─ Log in: admin@sunsetparadise.com / password123  │
└─────────────────────────────────────────────────────┘

During Development:

File Edit (Component/Service/Library)
    │
    ▼
ESLint checks
    ├─ No `any` type?
    ├─ Return type specified?
    ├─ Correct tier dependencies?
    ├─ No cross-app imports?
    └─ Correct scope?
    │
    ├─ ❌ Violation → Error message
    │    (Fix and retry)
    │
    └─ ✅ Pass
        │
        ▼
    Prettier formats
    │
    ▼
    File synced to pod
    │
    ▼
    Hot reload triggered
    │
    ▼
    Instant feedback in browser
```

---

## 9. Build Pipeline

```
yarn nx build {app}

    ▼

┌─────────────────────────┐
│  Dependency Analysis    │
│  Build dependent libs   │  (Task: ^build)
│  first (parallel)       │
└─────────────────────────┘
    │
    ├─ Tier 0: s-model, s-styles
    │
    ├─ Tier 1: s-http, s-storage, s-i18n, s-analytics
    │
    ├─ Tier 2: s-native-tools
    │
    ├─ Tier 3: s-core, s-modal, s-directives, s-loader, s-skeleton
    │
    ├─ Tier 4: s-auth, s-navigation, s-notification, s-builder
    │
    └─ Tier 5: All feature libraries
    │
    ▼

┌─────────────────────────┐
│  TypeScript Compilation │
│  (via ng-packagr/SWC)   │
│  - Type check            │
│  - Compile to JS         │
│  - Generate .d.ts files  │
└─────────────────────────┘
    │
    ▼

┌─────────────────────────┐
│  Build Application      │
│  - Import libs as       │
│    @suneasy/*           │
│  - Bundle with Webpack  │
│  - Optimize (tree-shake)│
│  - Apply budgets        │
└─────────────────────────┘
    │
    ▼

┌─────────────────────────┐
│  Bundle Analysis        │
│  500kb warning          │
│  1mb error limit        │
│  Per-component styles   │
│  checked too            │
└─────────────────────────┘
    │
    ▼

┌─────────────────────────┐
│  Cache Built Outputs    │
│  (for next builds)      │
│  Based on:              │
│  - Source files         │
│  - tsconfig changes     │
│  - package.json changes │
└─────────────────────────┘
    │
    ▼

dist/apps/{app}/        ← Ready to deploy
```

---

## 10. ESLint Error Examples

```
EXAMPLE 1: No any type
───────────────────────────
❌ function processData(data: any): void {
   Error: @typescript-eslint/no-explicit-any
   "Unexpected any. Specify a type."

✅ function processData(data: User): void {


EXAMPLE 2: Cross-app import
───────────────────────────
❌ import { SomeService } from '../../../business/src/app/services';
   Error: @nx/enforce-module-boundaries
   "Projects cannot be imported by a relative path"

✅ import { SomeService } from '@suneasy/s-core';


EXAMPLE 3: Upward tier dependency
─────────────────────────────────
In s-http (Tier 1), trying to import from s-widgets (Tier 5):

❌ import { CustomComponent } from '@suneasy/s-widgets';
   Error: @nx/enforce-module-boundaries
   "s-http can only depend on: tier:0"

✅ Only import from Tier 0 libraries


EXAMPLE 4: Missing return type
───────────────────────────────
❌ function getData() {
   Error: @typescript-eslint/explicit-function-return-type
   "Missing return type annotation"

✅ function getData(): Observable<Data> {


EXAMPLE 5: localStorage usage
─────────────────────────────
❌ localStorage.setItem('key', value);
   Error: eslint-plugin-no-secrets + custom rules
   "Use StorageService instead"

✅ inject(StorageService).set('key', value);


EXAMPLE 6: Function in template
────────────────────────────────
❌ <div>{{ calculateTotal() }}</div>
   Issue: Function called every change detection cycle
   
✅ total = computed(() => calculateTotal());
   <div>{{ total() }}</div>


EXAMPLE 7: Missing track in @for
─────────────────────────────────
❌ @for (item of items()) {
     <div>{{ item.name }}</div>
   }
   
✅ @for (item of items(); track item.id) {
     <div>{{ item.name }}</div>
   }
```

---

## 11. Key Statistics Visual

```
┌─────────────────────────────────────────────────────────┐
│                    SunEasy Metrics                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Applications:                                          │
│  ███████ 6 total                                        │
│  ███ 2 mobile (Capacitor)  ████ 4 web                  │
│                                                         │
│  Libraries by Tier:                                    │
│  ██ 4 Tier 0 (Primitives)                              │
│  ██ 4 Tier 1 (Services)                                │
│  █ 1 Tier 2 (Platform)                                 │
│  █████ 5 Tier 3 (UI)                                   │
│  ██ 4 Tier 4 (Features)                                │
│  ████████████████████ 20+ Tier 5 (Domain)              │
│                                                         │
│  Libraries by Scope:                                   │
│  ████████████████████████████████ 30+ scope:shared     │
│  ████ 4 scope:mobile                                   │
│  ███ 3 scope:business                                  │
│  ██ 2 scope:client                                     │
│  █ 1 scope:web                                         │
│  █ 1 scope:admin                                       │
│                                                         │
│  Code Quality:                                         │
│  ESLint Rules: 700+                                    │
│  TypeScript Strictness: MAXIMUM                        │
│  Angular Pattern: MODERN ONLY                          │
│  Build Budget: 500KB warning / 1MB error               │
│                                                         │
│  Development Speed:                                    │
│  Hot reload time: 2-3 seconds                          │
│  Single lib build: <5 seconds                          │
│  Full build: 2-3 minutes                               │
│  With cache: <2 seconds                                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 12. Comparison Matrix: Typical Nx vs SunEasy

```
┌──────────────────┬─────────────────┬──────────────────┐
│ Aspect           │ Typical Nx      │ SunEasy          │
├──────────────────┼─────────────────┼──────────────────┤
│ Dependency Mgmt  │ Tags only       │ Tiered system    │
│ App Isolation    │ Recommended     │ ENFORCED         │
│ Type Location    │ Scattered       │ Single (s-model) │
│ Libraries        │ 10-20           │ 40+              │
│ Platform Support │ Single          │ Mobile + Web     │
│ TypeScript       │ Standard strict │ Maximum strict   │
│ Components       │ Mixed (class+   │ Standalone only  │
│                  │  standalone)    │                  │
│ Change Detection │ Default + OnPush│ OnPush ONLY      │
│ Inputs/Outputs   │ @Input/@Output  │ Signal pattern   │
│ Control Flow     │ ngIf, ngFor     │ @if, @for ONLY   │
│ Import Ordering  │ Recommended     │ ENFORCED         │
│ Security         │ Recommendations │ ENFORCED rules   │
│ Performance      │ Best practices  │ Enforced patterns│
│ Scalability      │ ~20-30 libs     │ 100+ libraries   │
└──────────────────┴─────────────────┴──────────────────┘
```

---

## 13. Developer Checklist (Before Committing)

```
□ ESLint passes
  $ yarn s-lint

□ No TypeScript errors
  $ yarn nx build {app}

□ Tests pass
  $ yarn s-test

□ No unused imports/variables
  $ ESLint auto-fix should handle

□ Formatting correct
  $ yarn s-prettier

□ No hardcoded strings
  □ Used 'TRANSLATION_KEY' | translate

□ No localStorage/alert/confirm
  □ Used StorageService
  □ Used ModalService

□ Types are correct
  □ No `any` type
  □ All functions have return types
  □ All properties have types

□ Import organization
  □ Angular imports first
  □ npm imports second
  □ @suneasy imports third
  □ Relative imports last

□ Components follow pattern
  □ Standalone: true
  □ ChangeDetectionStrategy: OnPush
  □ Signal inputs/outputs
  □ Explicit member accessibility

□ No cross-app imports
  □ Not importing from apps/other-app
  □ Only importing from @suneasy libraries

□ Correct tier dependencies
  □ Not importing from higher tier
  □ Following dependency constraints
```

---

This visual reference provides a complete understanding of SunEasy's architecture through diagrams, examples, and comparisons.
