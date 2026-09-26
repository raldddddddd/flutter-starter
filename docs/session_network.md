# Session and networking contract (Phase 5)

`AppConfig.apiBaseUrl` comes from `API_BASE_URL` in each flavor's JSON file.
The committed `.invalid` URLs are placeholders; products must supply their own
endpoints. `appDioProvider` provides the authenticated Dio client. `refreshDioProvider`
is separate and has no auth interceptor. Both have centrally configured JSON
headers and connection, send and receive timeouts.

The default reference refresh protocol is `POST /auth/refresh` with a JSON
`refreshToken`, returning `accessToken` and an optional rotated `refreshToken`.
The login and refresh paths bypass authentication retry. A product can override
the `tokenRefresherProvider` when its backend uses another protocol. Phase 5
does not provide a login service.

`SessionManager` holds the access token only in memory. Secure storage contains
one `session.envelope` JSON value with the refresh token and account ID.
Restoration begins in `restoring`. Missing or unreadable secure material yields
`unauthenticated`. A temporary refresh failure yields `authenticatedOffline`
and preserves account-scoped cache; definitive rejection logs out. A later
call to `restore` retries an offline session. `AppRoot` retries restoration when
the app resumes while authenticated offline; overlapping retries share the
same in-flight refresh. The UI gate sends authenticated
online and offline sessions to the application shell and unauthenticated users
to the login placeholder.

Logout advances the epoch and publishes unauthenticated state before request
cancellation and storage cleanup. It then removes the secure envelope, the
active account's Drift data, and `user.*` preferences. Cleanup and session writes
are serialized so a later login cannot overtake cleanup. A definitively missing
or corrupt envelope clears all user preferences and account data because the
prior identity is unknown. A transient secure read exception preserves that
data until a new login clears it. Switching accounts clears the previous scope
before publishing the new session. Capture the account
ID and epoch when starting a user-scoped repository operation. Call
`isCurrentSession(accountId: ..., epoch: ...)` **inside** its Drift transaction
before writing any remote response. Cancellation alone is insufficient.

`AuthInterceptor` shares an in-flight refresh, notices when another request
already changed the access token, retries an authenticated request at most
once, and clones Dio `FormData` before retrying a multipart upload. Raw
one-shot stream request bodies cannot be replayed. `requestCancelToken(ref,
session)` ties a request to provider disposal; API services should release
tracked tokens when work completes. `mapNetworkError` converts Dio failures to
typed `AppFailure` values at service/repository boundaries. Redacted dev logs
record only HTTP method and outcome; headers, URLs and bodies are omitted.

Phase 6's fake API and sample repository should use these contracts while
keeping fake responses in process. Detailed interceptor concurrency and logout
race tests remain Phase 7 work.
