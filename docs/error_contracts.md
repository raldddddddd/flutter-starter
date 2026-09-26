# Error and repository contracts (Phase 4)

Expected operational commands return `Result<T>` with `Success<T>` or
`Failure<T>` carrying an `AppFailure`. Errors are typed; failures carry no
localized copy. Presentation maps a failure through `messageKeyFor` to a
`FailureMessageKey`, then uses localization to render the message. Technical
causes and stack traces stay in logging and diagnostics.

Repository method conventions:

```text
watchX()             → Stream<T>
refreshX()           → Future<Result<void>>
create/update/deleteX() → Future<Result<T or void>>
```

Drift streams are not wrapped in `Result` on each emission. Explicit refresh
and mutation commands return `Result`. No repository is implemented in this
phase.

Riverpod may wrap a failed dependency in `ProviderException`. At a presentation
boundary, call `normalizeProviderError` before choosing a message key. It
unwraps nested provider exceptions and preserves expected `AppFailure` values.
The installed observer sends originating unexpected provider errors and their
stack traces to the logging boundary, and skips dependency wrappers to avoid
duplicate reports. Global Flutter and platform error hooks use the same
boundary. Framework errors retain Flutter's normal debug presentation. The
default logger includes the error object in debug mode, but omits arbitrary
exception text outside debug because it may contain credentials or response
bodies. Repositories log `UnknownFailure` with its original cause and stack
before returning it; expected operational failures are not error logs. A
product crash hook should redact the error object before forwarding it.
Never put credentials or sensitive personal data in log messages.

`freezed` and `json_serializable` are installed for concrete future DTOs and
models. No placeholder model is generated in Phase 4. The hand-written Result
and failure hierarchy intentionally require no generator.
