# Flutter Starter Specification v1.0

**Status:** Approved for implementation  
**Purpose:** Reusable, production-oriented Flutter foundation for future mobile applications  
**Primary targets:** Android and iOS  
**Architecture:** Feature-first layered MVVM using Riverpod  
**Default data strategy:** Online-first with persistent local caching  
**Repository source of truth:** `docs/spec.md`

---

# 1. Purpose

The Flutter Starter provides reusable infrastructure for future mobile applications so new projects begin with a consistent architecture, design system, development workflow, quality gates, and common application patterns.

The starter must reduce repetitive setup without becoming a custom framework that hides Flutter and Dart concepts.

It should optimize for:

- maintainability;
- type safety;
- testability;
- accessibility;
- branding flexibility;
- predictable architecture;
- current Flutter/Dart practices;
- efficient development with coding agents;
- reproducible builds;
- safe extension into real products.

Product-specific functionality belongs in applications created from the starter.

---

# 2. Core Principles

1. Use current, non-deprecated APIs for the pinned SDK and dependency versions.
2. Prefer simple architecture over speculative abstraction.
3. Organize product capabilities by feature.
4. Use unidirectional data flow.
5. Repositories own application data behavior.
6. Infrastructure details must not leak into UI code.
7. Local ephemeral UI state stays local.
8. Shared/application state belongs in Riverpod where appropriate.
9. Build reusable functionality in a product first, then extract it into the starter after reuse is demonstrated.
10. Exception to Principle 9: infrastructure that is difficult or impossible to retrofit safely after release may be included from the beginning when the cost is low. Examples include version-policy hooks and reproducible app-identity tooling.
11. Optimize for correctness and clarity before cleverness.
12. The specification defines architecture; package-specific syntax must still be checked against the pinned versions before implementation.

---

# 3. SDK and Dependency Reproducibility

The Flutter SDK must be pinned to an exact version.

Preferred approach:

- use FVM or equivalent;
- commit the version configuration;
- use the identical Flutter version locally and in CI.

`pubspec.lock` must be committed.

Package versions should be selected from mutually compatible current stable releases.

Major dependency upgrades are migrations rather than blind version bumps.

---

# 4. State Management and Dependency Injection

Use **Riverpod 3** and current APIs only.

Use Riverpod code generation consistently.

Preferred forms:

```text
Functional @riverpod
├── synchronous provider
├── Future provider
└── Stream provider

Class-based @riverpod
├── Notifier
├── AsyncNotifier
└── StreamNotifier
```

Do not use:

```text
StateProvider
StateNotifier
StateNotifierProvider
ChangeNotifierProvider
flutter_riverpod/legacy.dart
```

Riverpod Notifiers serve as ViewModels/application controllers.

Do not create a redundant ViewModel around a Riverpod Notifier.

---

# 5. Riverpod Lifecycle

Generated providers are automatically disposable by default unless intentionally kept alive.

Use `keepAlive` only for infrastructure or state with a clear lifetime requirement.

Possible long-lived infrastructure:

- application configuration;
- database;
- networking client;
- token/session store.

After asynchronous gaps, a Notifier must verify that its `ref` remains mounted before mutating provider state.

Provider-family parameters require value equality.

Prefer:

- primitives;
- records;
- immutable Freezed values.

Resources must be disposed through provider lifecycle hooks where applicable.

Examples:

- Dio `CancelToken`;
- subscriptions;
- controllers;
- database resources.

---

# 6. Riverpod Automatic Retry

Global Riverpod automatic retry is disabled by default.

The starter must not depend on provider retry for network refresh behavior.

This is particularly important because the online-first architecture obtains cached read data from Drift streams while network refreshes occur through explicit repository/action methods.

Therefore:

```text
Riverpod provider retry
→ OFF by default

Network retry
→ repository/Dio layer
```

A bounded network retry may be applied only to known-safe, idempotent operations such as selected GET requests.

Do not automatically retry:

- validation errors;
- authentication rejection;
- create/update/delete operations;
- other non-idempotent commands.

Retry behavior belongs close to the network operation whose semantics are known.

---

# 7. Provider Error Observability

Provider dependency failures may be wrapped by Riverpod.

Expected operational errors should still resolve to `AppFailure` at presentation boundaries where appropriate.

Unexpected errors must remain observable for developers.

Install a `ProviderObserver` as part of application error/logging infrastructure.

It should:

- capture unexpected provider failures;
- avoid duplicate logging of dependency-propagated failures;
- preserve stack traces;
- send technical details to the logging/crash hook.

Do not rely on `runtimeType` string names for failure classification or production logging because release obfuscation may alter them.

Failure mapping must use actual types/enums/sealed cases.

---

# 8. Routing

Use **go_router**.

Responsibilities:

- declarative routing;
- nested navigation;
- parameters;
- deep-link readiness;
- shell navigation when needed.

Do not add a second custom routing framework.

---

# 9. Unified Application Gate

Router redirects should be derived from **one application-gate state** rather than independent ad hoc redirect checks.

Inputs may include:

```text
version policy
session state
onboarding state
```

Conceptual result:

```text
AppGateState
├── bootstrapping
├── updateRequired
├── onboardingRequired
├── unauthenticated
├── authenticatedOffline
└── authenticatedOnline
```

The exact sealed representation may vary, but router decisions should consume one derived gate state.

---

# 10. Networking

Use **Dio**.

Dio is configured centrally.

UI code must never instantiate or directly invoke Dio.

Flow:

```text
Dio
 ↓
API Service
 ↓
Repository
 ↓
Riverpod
 ↓
UI
```

Networking infrastructure should support:

- environment-specific base URL;
- timeouts;
- standard headers;
- authentication;
- cancellation;
- multipart requests;
- redacted development logging;
- normalized failures.

---

# 11. Access and Refresh Tokens

For access-token + refresh-token authentication:

```text
Access token
→ memory only

Refresh token
→ secure storage
```

The persisted session envelope should contain enough identity information to associate the refresh token with the correct locally cached user/account.

For example:

```text
refresh token
subject/account identifier
```

The networking interceptor depends on a token/session store rather than the authentication repository.

This avoids:

```text
Dio
→ AuthRepository
→ Dio
```

Refresh uses a separate Dio client that does not contain the standard refresh interceptor.

Never attempt token refresh for:

- login endpoint;
- refresh endpoint itself.

---

# 12. Concurrent Refresh

Refresh handling must be serialized.

```text
401 A ─┐
401 B ─┼→ one refresh request
401 C ─┘
```

Before starting refresh, compare the token used by the failed request against the current access token.

If another request already refreshed the token:

```text
skip refresh
→ retry with current token
```

A normal request may be retried after authentication refresh at most once.

No recursive refresh loops are permitted.

---

# 13. Refresh Rejection vs Refresh Unavailability

A refresh failure does **not** always mean logout.

There are two distinct outcomes.

## Refresh rejected

Examples:

- refresh endpoint returns an authentication rejection;
- token is invalid;
- token is revoked;
- protocol-specific `invalid_grant`;
- refresh endpoint returns an equivalent definitive unauthorized response.

Result:

```text
End authenticated session
→ clear authentication material
→ proceed through logout/session-expiration flow
```

## Refresh could not complete

Examples:

- no internet;
- timeout;
- DNS/network failure;
- temporary 5xx response.

Result:

```text
Do NOT log user out
Do NOT destroy cached user data
Return NetworkFailure to the requesting operation
```

The application may continue using locally cached data.

---

# 14. Cold-Start Session Restoration

Initial session state is:

```text
unknown / restoring
```

Normal online flow:

```text
App starts
   ↓
refresh token exists
   ↓
attempt restoration
   ↓
refresh accepted
   ↓
authenticatedOnline
```

If no refresh token exists:

```text
unauthenticated
```

If a refresh token/session identity exists but restoration cannot complete because of network failure:

```text
authenticatedOffline
```

`authenticatedOffline` means:

> The device has a previously established local session, but the server has not yet revalidated it during the current launch.

It does **not** claim that the remote session is definitely still valid.

In this state:

- cached user-scoped data may be displayed;
- local read-only functionality may continue;
- server-required commands fail gracefully or remain unavailable;
- connectivity recovery should trigger another restoration/refresh attempt.

If that later attempt is definitively rejected:

```text
authenticatedOffline
→ unauthenticated
→ cleanup
```

---

# 15. Session Epoch

Every authenticated session has a monotonically changing **session epoch/generation**.

Conceptually:

```text
SessionState
├── identity
├── epoch
└── authentication status
```

The epoch changes when:

- user logs out;
- authenticated identity changes;
- session is replaced/reset.

A repository operation captures the epoch when it starts.

Before committing user-scoped data to Drift, the repository checks the active epoch **inside the transaction**.

Conceptually:

```text
request starts at epoch 12
        ↓
user logs out
        ↓
epoch becomes 13
        ↓
old response arrives
        ↓
transaction checks 12 != 13
        ↓
DROP WRITE
```

This prevents stale in-flight work from restoring the previous user's data after logout.

Request cancellation remains useful but is not considered sufficient on its own.

---

# 16. User-Scoped Data Convention

All application cache/business data is **user-scoped by default**.

A table may be device-scoped only when explicitly documented as such.

User-scoped tables should contain or otherwise be partitioned by the authenticated account identity.

Cache metadata is scoped consistently with its resource/user.

Device-scoped tables require an explicit allowlist/documentation.

---

# 17. User-Scoped Preferences

Preferences follow naming conventions.

User-specific keys use:

```text
user.<key>
```

Device/application preferences use a separate prefix, for example:

```text
device.<key>
```

Examples that may survive logout:

```text
device.theme
device.locale
```

Examples cleared on logout:

```text
user.lastSelectedCat
user.dashboardPreference
```

---

# 18. User-Scoped Providers

Providers whose state depends on the active account must watch the session identity or session epoch.

This ensures they naturally rebuild when the authenticated session changes.

Do not maintain a manual central list of every provider that must be invalidated on logout unless a special case requires it.

---

# 19. Logout

Logout ordering must protect against stale asynchronous work.

Conceptually:

```text
1. advance/invalidate session epoch
2. mark session unauthenticated
3. cancel cancellable requests
4. clear access token
5. clear secure session material
6. wipe user-scoped Drift records
7. wipe user.* preferences
8. allow user-scoped providers to rebuild/dispose
```

The epoch changes **before** destructive cleanup so late network responses cannot commit as the old user.

Device preferences such as theme normally survive logout.

---

# 20. Preferences

Use **SharedPreferencesAsync** for small non-sensitive preferences.

Examples:

- onboarding completion;
- theme;
- locale;
- installation marker;
- small user settings.

Do not use legacy `SharedPreferences` in new starter code.

Use `SharedPreferencesWithCache` only with clear justification.

---

# 21. Secure Storage

Use the current supported `flutter_secure_storage` release selected at implementation time.

Do not copy platform options from historical tutorials.

Secure storage is considered **losable/recoverable storage**.

If secure session material disappears:

```text
session becomes unauthenticated
```

The application must not crash.

Nothing irreplaceable may exist only in secure storage.

---

# 22. Fresh Installation Policy

Default policy:

> A fresh installation represents a fresh local session.

A local installation marker is used as one part of this policy.

On a genuine fresh installation:

```text
clear stale authentication material if present
establish new installation marker
```

However, backup restoration can make an installation marker unreliable unless backup rules are configured.

Therefore Android backup configuration is part of the policy.

---

# 23. Android Backup Policy

The starter defaults to **selective backup exclusion**, rather than disabling all application backup.

The following local data should not be restored as if it belonged to the current installation:

- secure-storage backing data;
- Drift user/cache database;
- installation/fresh-install marker;
- other session-specific local state.

Configure Android backup rules for both relevant platform generations using the appropriate current Android mechanisms, including `data_extraction_rules.xml` where applicable.

Non-sensitive device preferences such as:

- theme;
- locale;

may remain eligible for backup if their backing storage can be isolated safely.

Exact paths depend on the pinned versions and storage backends and must be verified during implementation.

Products may choose a stricter policy such as disabling Auto Backup entirely.

---

# 24. Structured Local Persistence

Use **Drift + SQLite**.

Drift is responsible for:

- structured local data;
- remote cache;
- relational queries;
- transactions;
- migrations;
- reactive streams.

UI code does not execute Drift queries directly.

Use the current supported native Drift/sqlite setup for the pinned versions.

---

# 25. Drift Lifecycle

Expose the database through centralized Riverpod infrastructure.

Dispose database resources appropriately through provider lifecycle hooks.

Do not create independent database instances throughout features.

---

# 26. Drift Migrations

Migration infrastructure exists from schema version 1.

Requirements:

1. export/preserve initial schema;
2. increment schema versions;
3. create explicit migrations;
4. maintain migration tests.

Migration correctness forms part of automated testing.

---

# 27. Online-First Data Flow

Cached remote data follows:

```text
Screen
  ↓
Drift stream
  ↓
cached content
```

while network refresh follows:

```text
Refresh action
  ↓
Repository
  ↓
API
  ↓
transaction
  ↓
Drift
  ↓
stream emits updated content
```

The UI does not maintain separate competing network and local copies of the same cached resource.

---

# 28. Cache Metadata

Provide cache metadata such as:

```text
user/account scope
resource key
lastFetchedAt
```

This distinguishes:

```text
never fetched
fetched but empty
stale
fresh
```

Metadata participates in refresh decisions and screen-state derivation.

---

# 29. Refresh Ownership

Data providers must not cause hidden network side effects from their `build` methods.

The **presentation lifecycle** owns the initial refresh trigger.

Recommended pattern:

```text
screen mounts
   ↓
explicit refreshIfStale action
   ↓
repository examines lastFetchedAt
   ↓
refresh only when needed
```

The screen does not calculate staleness itself.

That logic belongs in repository/application infrastructure.

User-initiated pull-to-refresh invokes:

```text
forceRefresh()
```

which bypasses the normal freshness threshold.

Concurrent duplicate refresh requests should be coalesced/ignored while the same refresh action is already running.

---

# 30. Screen-State Derivation

A cached screen's visible state is derived from:

```text
cached rows
+
cache metadata
+
refresh action state
```

Examples:

## Never fetched + refresh running

```text
Loading
```

not empty.

## Never fetched + refresh failed

```text
Full-page initial error
```

## Successful fetch containing zero rows

```text
Empty state
```

## Cached rows + refresh running

```text
Display cached rows
+ subtle refresh state
```

## Cached rows + refresh failed

```text
Display cached rows
+ non-destructive error feedback
```

---

# 31. Streams vs Results

Repository conventions:

```text
watchX()
→ Stream<T>

refreshX()
→ Future<Result<void>>

create/update/delete X()
→ Future<Result<T or void>>
```

Reactive Drift streams are not wrapped in `Result` for every emission.

Operational commands use `Result`.

---

# 32. Unified Action-State Pattern

Refresh and write commands use the same stable action-state convention.

Examples:

```text
refreshCatsActionProvider
saveCatActionProvider
deleteCatActionProvider
```

Loaded resource state remains separate.

Example:

```text
catsProvider
→ watched cached cats

refreshCatsActionProvider
→ current refresh command

saveCatActionProvider
→ current save command
```

This avoids inventing one pattern for refresh and another for writes.

---

# 33. Action Provider Lifetime

Because generated Riverpod providers are auto-disposed by default, action providers must remain observed while their operation is running.

A screen invoking an action must:

```text
ref.watch(...)
or
ref.listen(...)
```

to the action provider for the duration of the operation.

Do not rely solely on:

```text
ref.read(actionProvider.notifier).save()
```

with no listener.

Action methods also check `ref.mounted` after asynchronous gaps before touching provider state.

Experimental Riverpod Mutations are not part of starter v1.

---

# 34. Action Success Effects

`AsyncData(null)` alone does not distinguish:

```text
initial idle
from
successful completion
```

One-shot UI effects such as:

- navigation;
- snackbar;
- confirmation message;

should react to an action **transition**, typically through `ref.listen`.

Example concept:

```text
loading
→ data
→ trigger success UI effect once
```

Do not continuously derive one-shot effects from current action state alone.

---

# 35. Cache Replacement and Server Deletions

When refreshing a complete authoritative query scope:

```text
server result
   ↓
transaction
   ↓
replace membership for that scope
```

This prevents deleted server records from remaining indefinitely in the cache.

---

# 36. Multi-Scope Membership Pattern

The same entity may appear in multiple query scopes.

Therefore a product requiring multiple scopes should avoid deleting the entity itself merely because it disappeared from one query.

Recommended normalized pattern:

```text
entities
└── entityId

scope_membership
├── scopeKey
├── entityId
└── position/metadata
```

Refreshing one scope replaces that scope's membership.

An entity can be deleted from the entity table only when product-specific rules determine it is no longer referenced/needed.

The starter sample may use one scope for simplicity but should document this pattern.

---

# 37. Session-Epoch Write Guard

Every user-scoped remote response that writes to Drift must validate the captured session epoch inside the database transaction.

This applies to:

- refreshes;
- creates returning server state;
- updates;
- background operations.

This requirement is independent of request cancellation.

---

# 38. Models and Serialization

Use:

- Freezed;
- json_serializable;
- build_runner.

Appropriate uses:

- immutable domain models;
- DTOs;
- value objects;
- complex presentation state.

Not every tiny object requires Freezed.

Recognize where useful:

```text
API DTO
Drift row
Domain model
```

Map representations in the data layer.

Do not mechanically create three types when responsibilities are truly identical.

---

# 39. Result

Use a small hand-written sealed `Result<T>`.

Conceptually:

```text
Result<T>
├── Success<T>
└── Failure<T>
```

Do not add a functional-programming package solely to gain a Result type.

---

# 40. AppFailure

Use a sealed `AppFailure` hierarchy implementing `Exception`.

Possible generic failures:

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

Feature-specific failures remain feature-specific.

Do not classify failures using string comparisons against `runtimeType`.

---

# 41. User-Facing Errors

`AppFailure` must not contain hardcoded UI copy.

Presentation maps failures to localized user-facing messages.

Example:

```text
NetworkFailure.timeout
        ↓
l10n mapper
        ↓
"Couldn't connect. Try again."
```

Technical diagnostic details remain in logging.

---

# 42. Architecture

Use feature-first layered MVVM.

```text
lib/
├── app/
├── core/
├── shared/
└── features/
```

`core/` contains only proven cross-cutting infrastructure:

- design;
- networking;
- persistence;
- routing;
- errors;
- logging;
- session/bootstrap.

No speculative notification or generic permission framework belongs in starter v1.

---

# 43. Feature Structure

A feature may use:

```text
feature/
├── presentation/
├── domain/
└── data/
```

Not every feature requires every folder.

Avoid empty architectural ceremony.

---

# 44. Presentation Responsibilities

Presentation contains:

- screens;
- feature widgets;
- Notifiers;
- action state;
- UI-specific state.

Presentation must not directly:

- call Dio;
- execute Drift SQL/queries;
- parse remote JSON;
- access secure-storage implementation;
- contain substantial persistence logic.

---

# 45. Domain Layer

Optional.

Use domain/use-case classes only when:

- substantial business rules exist;
- multiple repositories are coordinated;
- logic is reused by several ViewModels;
- direct ViewModel logic would become inappropriate.

Do not create forwarding-only use-case classes.

---

# 46. Repositories

Repositories coordinate:

- API services;
- Drift;
- cache metadata;
- mapping;
- refresh policy;
- network retry;
- session-epoch checks.

Default to concrete repositories.

Introduce an interface/contract when there is a real need such as:

- multiple implementations;
- genuine substitution;
- test architecture where a fake implementation is materially useful.

Do not mark fakeable repositories `final` without reason.

---

# 47. Services

Services are thin external-system adapters.

Examples:

```text
CatApiService
SessionApiService
FileApiService
```

Services do not own UI state.

---

# 48. Code Generation

Use:

- riverpod_generator;
- Freezed;
- json_serializable;
- drift_dev;
- build_runner.

Never manually edit generated files.

Generated files are committed.

Scope generators where useful.

Use build-runner watch mode during generator-heavy development.

---

# 49. Generated-Code Reproducibility

Reproducibility depends on:

- pinned Flutter SDK;
- committed lockfile;
- fixed generator versions.

CI should regenerate code and fail on unexpected diff.

Generated output may be excluded from manual formatter checks if generator output is deterministic.

---

# 50. Environments and Flavors

Provide:

```text
dev
staging
prod
```

Use one main entry point where practical.

Prefer:

```text
--flavor
+
--dart-define-from-file=config/<env>.json
```

where supported by the pinned Flutter version.

Distinct application/bundle IDs per flavor.

Development is the default flavor where supported.

---

# 51. Compile-Time Developer Flags

Developer-only capabilities such as the Component Showcase must be controlled by top-level compile-time constants.

Example concept:

```text
const bool kEnableComponentShowcase =
    bool.fromEnvironment(...);
```

Do not rely on a runtime Riverpod-provided `AppConfig` field for tree shaking.

Production routing must not register developer-only routes when the compile-time flag excludes them.

---

# 52. Runtime AppConfig

Use a centralized immutable `AppConfig` for runtime-safe public configuration such as:

- environment;
- API base URL;
- logging mode;
- other non-secret values.

Do not use `AppConfig` as a substitute for compile-time elimination of developer-only code.

---

# 53. Secrets

Anything shipped with Flutter is recoverable by the client and must not be treated as secret.

Never embed:

- database passwords;
- API private keys;
- payment secrets;
- backend signing keys;
- privileged OpenAI/service keys.

---

# 54. Design System

Use:

- ThemeData;
- ColorScheme;
- ThemeExtensions where useful;
- semantic design tokens.

Tokens cover:

- colors;
- typography;
- spacing;
- radius;
- appropriate layout constants.

Use current Material APIs.

Do not hardcode branding across individual widgets.

---

# 55. Component Showcase

Development-only showcase demonstrating components actually present in v1:

- colors;
- typography;
- spacing/radius;
- primary/secondary/text buttons;
- text field;
- card/container;
- loading state;
- empty state;
- error state;
- light/dark mode;
- long copy;
- large text.

Do not pre-build every possible component.

Add reusable components after actual products prove the need.

---

# 56. Localization

Use Flutter's current `gen-l10n` workflow.

Generated localization source lives inside the project source tree.

Do not use the historical synthetic `package:flutter_gen` approach.

English is the baseline language.

Additional languages are product-specific.

Support:

- parameters;
- plurals;
- date/time;
- number/currency formatting.

Exact configuration is verified against the pinned Flutter SDK before implementation.

---

# 57. Accessibility

Accessibility is baseline functionality.

Support:

- `TextScaler`;
- large system text;
- screen-reader semantics;
- adequate interaction targets;
- sufficient contrast;
- non-color-only status communication;
- safe-area behavior;
- TalkBack/VoiceOver validation.

Use current Flutter APIs rather than deprecated equivalents.

---

# 58. Static Analysis

Use Flutter's standard lint baseline plus strict analyzer settings:

```text
strict-casts
strict-inference
strict-raw-types
```

Deprecated-member use should be an analyzer error.

Use the current Riverpod analyzer plugin configuration.

Do not add obsolete lint infrastructure solely for Riverpod.

Canonical CI analysis includes:

```text
dart analyze
```

with appropriate fatal severity handling.

Verify behavior against the pinned toolchain.

---

# 59. Testing Strategy

No arbitrary global coverage percentage.

Priorities:

```text
1. unit tests
2. Riverpod/provider tests
3. widget tests
4. critical integration tests
```

Test observable behavior.

Prefer simple handwritten fakes.

Use Mocktail only when useful.

---

# 60. Fake Development API

The sample feature must not depend on a real public backend.

Provide a small **in-process fake API implementation** available to the dev environment and tests.

It should allow controlled behavior such as:

```text
artificial latency
successful response
network failure
5xx
401
refresh rejection
empty result
```

Because this constitutes a genuine second implementation, the sample API service may use an explicit contract shared by:

```text
FakeSampleApiService
Real/DioSampleApiService
```

The fake exists to demonstrate architecture and deterministic behavior, not as product mock data infrastructure.

---

# 61. Dio Authentication Test Adapter

Authentication/interceptor tests should use a controlled fake/mock Dio `HttpClientAdapter` or similarly deterministic test transport.

Do not require a real backend for interceptor correctness tests.

Required authentication tests include:

## Concurrent 401

```text
multiple failed requests
→ exactly one refresh
```

## Refresh rejected

```text
refresh receives definitive authentication rejection
→ session ends
```

## Refresh network failure

```text
refresh cannot connect
→ session retained
→ NetworkFailure
```

## Logout race

```text
request begins
→ logout changes epoch
→ response completes
→ old user data is not committed
```

---

# 62. Multipart Retry

A finalized multipart request body cannot simply be resent.

When an authenticated multipart request must be retried after token refresh, retry infrastructure must clone/recreate its `FormData`/multipart body appropriately.

Do not reuse an already consumed request body.

---

# 63. Logging and Crash Hooks

Provide a thin logging abstraction:

```text
debug
info
warning
error
```

Never log:

- Authorization headers;
- access tokens;
- refresh tokens;
- passwords;
- unnecessary sensitive user data.

Global error infrastructure includes:

- Flutter framework error hook;
- asynchronous/platform error hook as appropriate;
- Riverpod `ProviderObserver`.

No crash-reporting vendor is hardcoded.

---

# 64. Bootstrap Ordering

Before `runApp`, initialize only prerequisites that genuinely must exist first.

Examples:

```text
WidgetsFlutterBinding
environment configuration
installation/backup-sensitive setup required before session bootstrap
```

Application state initializes through providers after startup where practical.

Examples:

- database;
- session restoration;
- remote refresh.

Use splash/bootstrap UI while application gates resolve.

---

# 65. Version Policy Hook

Provide a minimal version-policy abstraction from the first release.

Default:

```text
allow current version
```

A future product may supply:

```text
minimumSupportedVersion
recommendedVersion
```

from a backend/config source.

It must not depend on a particular vendor.

The result feeds the unified `AppGateState`.

---

# 66. App Identity Tooling

Provide tooling/script support for creating a product from the starter.

It should assist with changing:

- app display name;
- Dart package name;
- Android namespace;
- Android IDs by flavor;
- iOS bundle identifiers by flavor;
- flavor display names.

Changes must be explicit and reviewable.

---

# 67. Production Symbols

Production build tooling should support:

```text
--obfuscate
--split-debug-info
```

when appropriate.

Debug-symbol output must be archived for crash symbolication.

Never use obfuscation as secret protection.

Production behavior must not depend on source/runtime type-name strings.

---

# 68. Platform Baseline

Create the project from a current Flutter template.

Do not copy historical Android/iOS runner folders.

Validate:

- edge-to-edge layouts;
- safe areas;
- current Android platform expectations;
- current iOS lifecycle/template requirements.

Plugin platform requirements must be reviewed before dependency adoption.

---

# 69. CI

Default provider:

**GitHub Actions**

CI covers:

```text
generated-code verification
format verification
dart analyze
tests
Android dev build
iOS dev --no-codesign build
```

iOS build uses a macOS runner.

CI must use the same pinned Flutter SDK.

---

# 70. Local Verification

Provide a single local verification command/script covering:

```text
generate
format check
analyze
test
```

Platform builds may remain separate because they are slower.

Humans and Codex use the same commands.

---

# 71. Specification Ownership

The complete specification is stored in:

```text
docs/spec.md
```

This is the architectural source of truth.

`AGENTS.md` should **link to the specification**, not duplicate the entire document.

This avoids rules diverging between two independently maintained copies.

---

# 72. AGENTS.md

`AGENTS.md` contains short operational instructions and links to relevant spec sections.

It should include high-value rules such as:

## Before implementing

- read `docs/spec.md`;
- inspect existing architecture;
- verify pinned package documentation for version-sensitive APIs.

## Riverpod

- modern Riverpod 3 only;
- generated APIs;
- no legacy providers;
- provider retry globally disabled;
- action providers must remain listened to during operations;
- check `ref.mounted` after asynchronous gaps;
- provider family parameters require value equality.

## Architecture

- UI does not call Dio/Drift;
- repositories own data behavior;
- Notifier acts as ViewModel;
- no speculative layers.

## Generation

- never edit generated code;
- regenerate after source/schema changes.

## Completion

```text
generate
format
analyze
relevant tests
```

---

# 73. Common Deprecated/Outdated Patterns to Reject

Coding agents should not introduce known historical patterns such as:

```text
legacy Riverpod providers
package:flutter_gen localization imports
textScaleFactor APIs
withOpacity where current APIs replace it
MaterialStateProperty where WidgetStateProperty is current
deprecated Material ColorScheme roles
obsolete Drift/sqlite support setup
old flutter_secure_storage Android options
```

Always verify against pinned package versions rather than treating this list as exhaustive.

---

# 74. Sample Feature

Include one small sample feature demonstrating the entire architecture.

Data:

```text
View
 ↓
Drift stream provider
 ↓
cached rows
```

Refresh:

```text
screen mount
 ↓
refreshIfStale action
 ↓
repository
 ↓
fake/Dio API
 ↓
epoch-checked Drift transaction
 ↓
stream updates
```

The sample demonstrates:

- never-fetched state;
- initial loading;
- empty result;
- cached result;
- freshness metadata;
- stale refresh;
- refresh failure with cached data retained;
- write action state;
- session epoch protection;
- testing.

It must remain easy to delete when starting a real app.

---

# 75. Sample Refresh State

The sample screen explicitly combines:

```text
cached content
metadata
refreshCatsActionProvider
```

This serves as the reference implementation for online-first screens.

No hidden network fetch occurs inside the data provider's `build`.

---

# 76. Starter V1 Scope

Starter v1 includes:

- pinned Flutter SDK;
- Riverpod 3;
- go_router;
- unified application gate;
- Dio;
- token/session infrastructure;
- offline-capable session restoration;
- session epoch;
- SharedPreferencesAsync;
- secure storage;
- Android backup rules;
- Drift;
- migration infrastructure;
- cache metadata;
- Freezed;
- json_serializable;
- Result/AppFailure;
- action-state convention;
- dev/staging/prod;
- design tokens;
- small shared component set;
- Component Showcase;
- localization foundation;
- accessibility baseline;
- testing infrastructure;
- fake sample API;
- deterministic authentication tests;
- logging + ProviderObserver;
- CI;
- app identity tooling;
- version-policy hook;
- README;
- `docs/spec.md`;
- AGENTS.md;
- sample feature.

---

# 77. Explicit Non-Goals

Starter v1 does not include:

- Docker;
- Kubernetes;
- backend implementation;
- PostgreSQL server;
- Redis;
- Firebase;
- Supabase;
- payments;
- RevenueCat;
- AI/LLM APIs;
- local LLMs;
- agents;
- analytics vendor;
- crash-reporting vendor;
- generic notifications framework;
- generic permission framework;
- push backend;
- full offline-first sync;
- generic conflict resolution;
- offline mutation queue;
- real authentication provider;
- social login;
- generic CRUD generator;
- mandatory use-case layer;
- universal application framework.

---

# 78. Implementation Phases

## Phase 1 — Bootstrap

Implement:

- current Flutter template;
- SDK pinning;
- base flavors/config;
- Riverpod;
- global retry disablement;
- go_router;
- unified app-gate skeleton;
- analyzer/lints;
- generation infrastructure;
- bootstrap structure;
- `docs/spec.md`;
- minimal AGENTS.md linking to it.

No product feature work.

## Phase 2 — Design Foundation

Implement:

- design tokens;
- themes;
- starter components;
- Component Showcase;
- compile-time exclusion;
- accessibility stress examples.

## Phase 3 — Persistence and Local Scope

Implement:

- SharedPreferencesAsync;
- secure storage;
- fresh-install policy;
- Android backup exclusions;
- Drift;
- schema v1 export;
- migration tests;
- cache metadata;
- user/device scope conventions.

## Phase 4 — Session and Networking

Implement:

- Dio;
- token/session store;
- session epoch;
- separate refresh Dio;
- queued refresh;
- rejected-vs-network-failed refresh distinction;
- cancellation;
- multipart retry cloning;
- redacted networking logs;
- offline session restoration.

No real authentication server/provider.

## Phase 5 — Models and Errors

Implement:

- Freezed;
- serialization;
- Result;
- AppFailure;
- error normalization;
- ProviderObserver;
- unified action-provider convention.

## Phase 6 — Sample Feature

Implement:

- fake API service;
- cache stream;
- refreshIfStale;
- forced refresh;
- metadata;
- initial loading/empty/error;
- retained cache on refresh error;
- action state;
- epoch-checked transaction;
- scope replacement;
- tests.

## Phase 7 — Authentication Infrastructure Tests

Implement deterministic tests for:

- concurrent 401s;
- one refresh only;
- refresh rejection logout;
- temporary refresh network failure;
- offline session restoration;
- logout race;
- multipart authenticated retry.

## Phase 8 — Localization and Platform Quality

Implement:

- current gen-l10n setup;
- accessibility baseline;
- edge-to-edge/safe-area verification.

## Phase 9 — Developer Experience

Implement:

- app identity tool;
- version-policy hook;
- verification script;
- README;
- final AGENTS.md.

## Phase 10 — CI and Release Foundation

Implement:

- generation validation;
- format validation;
- analyzer;
- tests;
- Android development build;
- iOS no-codesign development build;
- production symbol/obfuscation workflow documentation.

---

# 79. Completion Criteria

Starter v1 is ready when:

- exact Flutter SDK is reproducible;
- Android/iOS development builds succeed;
- dev/staging/prod configuration works;
- only modern Riverpod APIs are used;
- provider retry is controlled explicitly;
- unified routing gate works;
- online and offline-restored session states work;
- refresh rejection and refresh network failure behave differently;
- concurrent 401s trigger only one refresh;
- logout cannot allow an old request to restore previous-user data;
- user/device data scopes are defined;
- Android backup cannot restore stale user cache/session marker unexpectedly under default policy;
- themes/tokens work;
- Component Showcase is absent from production configuration;
- Drift schema/migrations work;
- cache freshness is represented;
- initial loading, empty, stale and refresh-error states are distinguishable;
- action providers remain alive while commands run;
- one-shot success effects are transition-driven;
- server-list replacement behaves correctly;
- Result/AppFailure boundaries work;
- fake API demonstrates controlled failures;
- authentication race tests pass;
- localization works;
- accessibility baseline is validated;
- ProviderObserver reports unexpected failures;
- no production logic relies on `runtimeType` strings;
- static analysis passes;
- tests pass;
- generated code is current;
- Android/iOS CI builds pass;
- app identity tooling works;
- README, AGENTS.md and `docs/spec.md` agree.

---

# 80. Specification Change Rule

When implementation reveals that the specification conflicts with:

- current Flutter behavior;
- current package APIs;
- platform requirements;
- a demonstrated architectural flaw;

do not silently improvise.

Use:

```text
identify conflict
      ↓
verify current documentation
      ↓
update docs/spec.md
      ↓
implement updated decision
```

Implementation feedback is expected.

The specification is a maintained engineering document rather than an immutable artifact.

---

**End of Flutter Starter Specification v1.0**