# Phase 6 sample feature

`lib/features/sample/` is a small removable reference feature. In dev, the
login placeholder offers **Open sample demo**, which establishes a local demo
session. The in-process `FakeSampleApiService` supplies its data. Staging and
production select the `DioSampleApiService`; `/sample/items` is a reference
endpoint to replace with a product API. No public service is required.

`SampleItem` is both the immutable domain value and JSON API representation
because their fields are identical. Drift's `SampleItems` table is the local
representation; `SampleRepository.watchItems` maps table rows to `SampleItem`.
The fake has mutable `latency`, `outcome`, and `items`, including an empty list,
network failure, 503, and 401. Tests can change these before each request.

The screen watches the item and metadata streams. On mount it explicitly calls
`refreshIfStale`; a refresh button calls `forceRefresh`. The repository uses
`lastFetchedAt` and a five-minute threshold, and coalesces concurrent refreshes
for the same account and session epoch. A successful response replaces the
entire account list and marks it fetched in one transaction. The stream then
updates the screen. Refresh errors leave cached rows intact. The same action
provider convention handles refresh and create; the screen watches each action
while it runs and listens for completion transitions for one-shot messages.

The sample has one authoritative query scope per account. A product with
multiple scopes should keep an `entities(entityId, ...)` table and a
`scope_membership(scopeKey, entityId, position, ...)` table. Replacing one
scope's membership must not delete an entity still referenced by another
scope. Product rules decide when an unreferenced entity can be removed.

Every remote response that writes user-scoped data checks the captured account
and session epoch **inside** the Drift transaction, including the create action.
The check runs again before transaction completion. Cancellation is useful but
does not replace this guard. Logout removes sample rows and metadata for the
account. See `test/sample/` for repository, provider, widget, cache-state,
refresh, and epoch-guard examples.
