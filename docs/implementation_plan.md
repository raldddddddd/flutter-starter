# Flutter Starter — Implementation Plan v1.0

**Status:** Approved for implementation  
**Architecture source of truth:** `docs/spec.md`  
**Purpose:** Define the ordered implementation work required to build Flutter Starter v1.0.

---

# 1. Implementation Rules

The implementation must follow `docs/spec.md`.

This plan defines **how and in what order** that architecture is built.

Each phase is implemented separately.

Codex must not begin the next phase automatically.

The standard workflow is:

```text
Implement one phase
        ↓
Run required checks
        ↓
Produce completion report
        ↓
Human review
        ↓
Commit
        ↓
Begin next phase
```

If implementation reveals a conflict with current Flutter, Dart, package, Android, or iOS behavior:

```text
identify conflict
      ↓
verify current documentation
      ↓
update docs/spec.md if necessary
      ↓
implement corrected decision
```

Do not silently deviate from the specification.

---

# 2. Phase 1 — Project Bootstrap

## Goal

Create a reproducible Flutter project foundation for Android and iOS.

The project should build successfully and contain the minimum architecture required for later phases.

## Required Work

Create the Flutter application in the existing Git repository while preserving:

```text
.git/
docs/spec.md
docs/implementation_plan.md
AGENTS.md
```

Target:

```text
Android
iOS
```

Do not enable additional platforms unless required later.

Pin the Flutter SDK using the repository's chosen version-management approach.

Use the current Flutter project template supported by the pinned SDK.

Establish:

```text
lib/
├── app/
├── core/
├── shared/
└── features/
```

Do not create empty architectural layers merely to populate directories.

Configure Riverpod 3 using modern generated APIs.

Add only the Riverpod generation infrastructure needed now:

```text
flutter_riverpod
riverpod_annotation
riverpod_generator
build_runner
```

Do not add legacy Riverpod APIs.

Disable global Riverpod automatic retry according to `docs/spec.md`.

Configure `go_router`.

Create only a minimal route/application shell.

Create the skeleton for the unified application gate without implementing real authentication, onboarding, or version checking.

Configure:

```text
dev
staging
prod
```

flavors.

Prefer one Dart entry point together with native flavors and environment configuration where supported.

Create a minimal immutable `AppConfig` containing only values genuinely required in Phase 1.

Developer-only compile-time constants must remain separate from runtime `AppConfig`.

Configure analyzer/linting:

```text
Flutter recommended baseline
strict-casts
strict-inference
strict-raw-types
deprecated member usage as error
current Riverpod analyzer plugin
```

Establish basic bootstrap/application-root separation.

## Explicitly Out of Scope

Do not implement:

```text
design system
Drift
preferences
secure storage
Dio
authentication
Result/AppFailure
sample feature
localization
version-policy implementation
CI
```

## Verification

Run:

```text
dart format
dart analyze
flutter test
```

Verify the development flavor can build.

Verify the basic application launches.

## Definition of Done

Phase 1 is complete when:

```text
Flutter version is pinned
Android/iOS project exists
dev/staging/prod foundation exists
Riverpod generation works
global retry policy is configured
go_router works
analyzer is clean
base tests pass
app builds
```

---

# 3. Phase 2 — Design Foundation

## Goal

Create the reusable visual foundation used by future applications.

## Required Work

Implement semantic design tokens using current Flutter theming APIs.

Cover:

```text
colors
typography
spacing
radius
basic layout constants where justified
```

Use:

```text
ThemeData
ColorScheme
ThemeExtension
```

where appropriate.

Implement light and dark themes.

Create only the starter components currently justified:

```text
primary button
secondary button
text button
text input
card/container
loading state
empty state
error state
```

Components must support:

```text
disabled states
loading states where appropriate
large text
semantics
appropriate interaction targets
```

Build the Component Showcase.

It should demonstrate:

```text
colors
typography
spacing
radius
buttons
inputs
cards
loading
empty
error
light/dark theme
long text
large text
```

Add a compile-time constant controlling whether the showcase exists.

Production configuration must not register the showcase route.

Do not store this flag only inside runtime `AppConfig`.

## Explicitly Out of Scope

Do not add speculative components such as:

```text
date picker wrappers
dropdown frameworks
skeleton framework
complex bottom sheets
custom notification UI
```

unless required by the showcase itself.

## Verification

Add useful widget tests for shared components.

Test:

```text
light theme
dark theme
large text
disabled/loading states
basic semantics
```

Run normal project verification.

## Definition of Done

The application has a reusable, brand-replaceable design foundation and a development-only visual showcase.

---

# 4. Phase 3 — Persistence and Local Scope

## Goal

Create safe local persistence and caching infrastructure.

## Required Work

Add current compatible releases of:

```text
shared_preferences
flutter_secure_storage
drift
current Drift Flutter/native integration
drift_dev
```

Verify package setup against the pinned Flutter version.

Use `SharedPreferencesAsync`.

Define preference namespaces:

```text
device.*
user.*
```

Implement the fresh-install marker.

Implement the default fresh-install/session policy from `docs/spec.md`.

Configure Android backup behavior so stale:

```text
secure-storage backing data
Drift user/cache database
installation marker
session-specific local state
```

is not incorrectly restored.

Verify exact paths and backup rules against the selected package/platform versions.

Create the Drift database.

Establish schema version 1.

Export the initial Drift schema immediately.

Configure migration tooling and migration tests from the beginning.

Implement cache metadata capable of representing:

```text
resource key
user/account scope
lastFetchedAt
```

Establish the convention:

> Cached/business tables are user-scoped by default.

Device-scoped tables require explicit documentation.

Implement centralized database lifecycle through Riverpod.

## Explicitly Out of Scope

Do not implement:

```text
network refresh
full offline sync
mutation queue
authentication backend
product-specific tables
```

## Verification

Test:

```text
database creation
basic transaction behavior
cache metadata
migration baseline
user/device preference namespace behavior
fresh-install logic
```

Run normal verification.

## Definition of Done

Local storage infrastructure is ready for repositories and network-backed caching.

---

# 5. Phase 4 — Models and Error Foundation

## Goal

Create the common data/error contracts that later networking and repositories depend on.

## Required Work

Add:

```text
freezed
freezed_annotation
json_serializable
json_annotation
```

Configure generation only where required.

Implement a small hand-written sealed:

```text
Result<T>
├── Success<T>
└── Failure<T>
```

Implement sealed `AppFailure` types such as:

```text
NetworkFailure
AuthenticationFailure
AuthorizationFailure
ValidationFailure
NotFoundFailure
ConflictFailure
ServerFailure
StorageFailure
UnknownFailure
```

`AppFailure` should implement `Exception`.

Do not embed localized user-facing strings inside failures.

Establish presentation-layer mapping from failure meaning to localized/user-readable messages later.

Add error normalization needed for Riverpod/provider dependency errors.

Add a `ProviderObserver` capable of surfacing unexpected failures to the logging infrastructure.

Do not classify errors using `runtimeType.toString()`.

Establish and document repository conventions:

```text
watchX()
→ Stream<T>

refreshX()
→ Future<Result<void>>

create/update/deleteX()
→ Future<Result<T or void>>
```

## Explicitly Out of Scope

Do not yet implement:

```text
real networking
auth refresh
product repositories
large command framework
```

## Verification

Unit-test:

```text
Result
failure mapping
provider error normalization
```

Run generation and normal verification.

## Definition of Done

Later repositories and networking can use stable error/data contracts without redesign.

---

# 6. Phase 5 — Session and Networking

## Goal

Create safe networking and authentication-session infrastructure without depending on a real backend.

## Required Work

Add Dio.

Create the central Dio configuration.

Support:

```text
base URL
timeouts
headers
request cancellation
multipart requests
redacted development logging
normalized errors
```

Create session/token infrastructure.

Default token strategy:

```text
access token
→ memory

refresh token
→ secure storage
```

Persist enough account/session identity to associate cached data with the correct user.

Implement session states including:

```text
unknown/restoring
unauthenticated
authenticatedOffline
authenticatedOnline
```

Integrate session state into the unified application gate.

Implement the session epoch/generation mechanism.

Epoch must change when:

```text
logout
identity changes
session is replaced
```

Implement safe logout ordering.

Create a separate Dio instance for refresh requests.

Implement queued/serialized refresh.

Distinguish:

```text
Refresh rejected
→ terminate session

Refresh unavailable because network/timeout/temporary server problem
→ retain local session
→ return NetworkFailure
```

Implement token-change detection so requests do not redundantly refresh after another request already succeeded.

Retry an original authenticated request at most once.

Prevent refresh recursion.

Implement multipart retry by cloning/recreating consumed multipart bodies as required by the selected Dio version.

Redact credentials from logs.

Tie request cancellation to provider lifecycle where appropriate.

Implement offline cold-start session restoration.

If local session material exists but the server cannot be reached:

```text
authenticatedOffline
```

must remain capable of displaying cached user data.

## Explicitly Out of Scope

Do not implement:

```text
real login backend
social authentication
production authentication service
full offline writes
```

## Verification

Add focused unit tests for session state and error mapping.

Detailed concurrency/race tests are Phase 7.

## Definition of Done

The starter has a safe networking/session architecture suitable for future real authentication providers.

---

# 7. Phase 6 — Reference Sample Feature

## Goal

Demonstrate the complete intended application architecture with a deliberately small removable feature.

## Required Work

Create a small sample entity.

Do not make it product-specific.

Example:

```text
SampleItem
```

Create:

```text
API DTO
domain model where useful
Drift representation
mapping
repository
presentation
```

Do not create separate representations unnecessarily if two layers are truly identical.

Create an API service contract because the starter now genuinely has two implementations:

```text
FakeSampleApiService
DioSampleApiService/reference implementation
```

The in-process fake service should support controlled:

```text
latency
success
empty result
network failure
5xx
401 where appropriate
```

Implement the reference online-first flow:

```text
Screen
 ↓
Drift stream
 ↓
cached data
```

and:

```text
screen lifecycle
 ↓
refreshIfStale action
 ↓
repository
 ↓
API
 ↓
session epoch check
 ↓
Drift transaction
 ↓
stream updates UI
```

Initial network refresh must not occur as a hidden side effect inside a data provider's `build`.

Presentation owns the explicit initial refresh trigger.

Repository/application logic decides whether data is stale.

Implement:

```text
refreshIfStale()
forceRefresh()
```

Use cache metadata.

Implement refresh request coalescing so duplicate equivalent refreshes are not launched simultaneously.

Visible screen state should be derived from:

```text
cached rows
+
metadata
+
refresh action state
```

Demonstrate:

```text
never fetched + refreshing → loading
never fetched + failure → initial error
successful zero result → empty
cached + refreshing → cached content remains
cached + failure → cached content + non-destructive refresh error
```

Use the unified action-provider convention for refresh/write operations.

Action providers must remain watched/listened to while running.

Action code checks `ref.mounted` after asynchronous gaps.

One-shot success effects use state transitions through `ref.listen`.

Implement complete-list cache replacement for the sample scope.

Document the membership-table pattern for future products with entities shared across multiple scopes.

All remote writes to user-scoped Drift data must check the session epoch inside the transaction.

## Verification

Add:

```text
repository tests
Riverpod tests
widget tests
cache-state tests
refresh tests
epoch-write guard test
```

## Definition of Done

A developer can study the sample feature and understand how a real feature should be structured.

---

# 8. Phase 7 — Authentication and Concurrency Tests

## Goal

Prove the networking/session architecture handles its critical race conditions.

## Required Work

Use a deterministic Dio test transport such as a controlled `HttpClientAdapter`.

Do not depend on an internet service.

Test:

## Concurrent 401

```text
several requests receive 401
→ exactly one refresh request occurs
```

## Token already refreshed

```text
failed request uses old token
current token is already newer
→ retry directly
→ no second refresh
```

## Refresh rejected

```text
refresh endpoint definitively rejects token
→ session becomes unauthenticated
```

## Refresh network failure

```text
refresh cannot complete
→ session remains locally valid
→ NetworkFailure
```

## Offline cold start

```text
local session exists
network unavailable
→ authenticatedOffline
→ cached data remains available
```

## Logout race

```text
request begins under epoch N
logout advances epoch
response arrives
transaction checks epoch
old response is not committed
```

## Multipart authenticated retry

Verify multipart data can be recreated/cloned correctly when a request is retried after authentication refresh.

## Definition of Done

The most dangerous session/network race conditions are reproducibly covered by automated tests.

---

# 9. Phase 8 — Localization and Platform Quality

## Goal

Make the starter localization-ready and validate its accessibility/platform baseline.

## Required Work

Configure Flutter's current `gen-l10n` workflow.

Generated localization code must live in project source.

Do not use the historical synthetic:

```text
package:flutter_gen
```

English is the starter language.

Move reusable user-facing starter strings into localization resources where appropriate.

Support future:

```text
parameters
plurals
dates
times
numbers
currencies
```

Use directional layout APIs where start/end semantics are intended.

Review shared widgets for:

```text
TextScaler behavior
large text
screen-reader semantics
tap target size
contrast
non-color-only communication
safe areas
keyboard/focus behavior where relevant
```

Validate current Android edge-to-edge behavior.

Validate current iOS template/lifecycle expectations.

## Verification

Run widget/accessibility-focused tests where practical.

Perform manual Component Showcase checks for:

```text
large text
light mode
dark mode
safe areas
long localized-style copy
```

## Definition of Done

The starter can add languages later without architectural rework and provides a responsible accessibility baseline.

---

# 10. Phase 9 — Developer Experience

## Goal

Make the starter practical to reuse for future products.

## Required Work

Implement app identity tooling.

It should assist with changing:

```text
display name
Dart package name
Android namespace
Android application IDs per flavor
iOS bundle identifiers per flavor
flavor display names
```

Changes must be reviewable.

Implement the version-policy hook.

Default behavior:

```text
current version allowed
```

Provide an abstraction for future:

```text
minimum supported version
recommended version
```

Integrate it into the unified app gate.

Do not depend on Firebase Remote Config or another vendor.

Create a local project verification command/script performing:

```text
generation
format verification
analysis
tests
```

Update `README.md` with:

```text
project purpose
Flutter SDK setup
flavors
running the app
generation
testing
verification
architecture overview
how to create a new product from the starter
```

Finalize `AGENTS.md`.

Keep it concise.

`AGENTS.md` links to:

```text
docs/spec.md
docs/implementation_plan.md
```

rather than duplicating them.

## Definition of Done

A new developer—or coding agent—can clone the repository and understand how to use it without hidden setup knowledge.

---

# 11. Phase 10 — CI and Release Foundation

## Goal

Make the starter reproducibly verifiable in GitHub.

## Required Work

Add GitHub Actions.

CI should use the exact Flutter SDK pinned by the repository.

Create checks for:

```text
generated code is current
formatting
dart analyze
tests
Android dev build
iOS dev no-codesign build
```

Use an appropriate macOS runner for iOS.

Generation verification must fail if regeneration produces an unexpected diff.

Add release documentation/tooling for:

```text
--obfuscate
--split-debug-info
```

when appropriate.

Symbol files must be treated as release artifacts.

Do not claim that obfuscation protects secrets.

Ensure no production behavior depends on source type-name strings.

## Verification

The full CI workflow must pass.

## Definition of Done

A clean checkout can be validated automatically without relying on the original developer's machine.

---

# 12. Final Starter Validation

After Phase 10, perform one final validation against `docs/spec.md`.

Confirm:

```text
Flutter SDK is pinned
Android builds
iOS builds
all three flavors exist
Riverpod uses modern APIs
global provider retry is disabled
router/app gate works
design system works
Component Showcase is dev-only
preferences work
secure storage behaves safely
Android backup rules exist
Drift migrations exist from schema v1
cache metadata works
Result/AppFailure boundaries work
Dio/session infrastructure works
offline restored session works
refresh concurrency tests pass
logout epoch race test passes
sample feature demonstrates online-first caching
localization works
accessibility baseline exists
verification script passes
CI passes
documentation is current
```

If any final behavior differs from the specification, update the specification before declaring Starter v1 complete.

---

# 13. Standard Codex Phase Prompt

Once this document exists in the repository, individual Codex prompts should remain small.

Use:

```text
Read AGENTS.md, docs/spec.md, and docs/implementation_plan.md.

Implement Phase <N> only.

Do not begin any later phase.

Follow the scope, exclusions, verification steps, and definition of done for that phase.

Before finishing, provide:
1. files significantly changed,
2. dependencies added or removed,
3. verification commands and results,
4. any deviations or conflicts with docs/spec.md,
5. anything the next phase needs to know.
```

Do not paste the entire architecture into every Codex conversation.

---

# 14. Commit Strategy

After a phase is reviewed and accepted, create a Git commit before moving on.

Suggested progression:

```text
docs: add Flutter starter specification and implementation plan

feat: bootstrap Flutter starter
feat: add design system and component showcase
feat: add local persistence infrastructure
feat: add result and error foundation
feat: add session and networking infrastructure
feat: add reference sample feature
test: cover authentication and session concurrency
feat: add localization and platform quality baseline
chore: add reusable developer tooling
ci: add validation and build workflows
```

Do not require these exact commit messages, but preserve the one-phase-per-checkpoint concept.

---

**End of Flutter Starter Implementation Plan v1.0**