# Flutter Starter — Agent Instructions

Before making changes, read:

- [docs/spec.md](docs/spec.md)
- [docs/implementation_plan.md](docs/implementation_plan.md)

`docs/spec.md` is the architectural source of truth.

`docs/implementation_plan.md` defines implementation order and phase scope.

## Rules

- Implement only the phase explicitly requested.
- Do not begin future phases prematurely.
- Use the Flutter SDK and dependency versions pinned by this repository.
- Use current, non-deprecated Flutter, Dart, and package APIs.
- Use Riverpod 3 modern APIs only.
- Never manually edit generated files.
- Do not add architectural abstractions or dependencies without a concrete need.
- If current platform/package behavior conflicts with the specification, report the conflict rather than silently changing the architecture.

## Before completing meaningful changes

- regenerate affected generated code;
- format source;
- run static analysis;
- run relevant tests;
- report remaining warnings or specification conflicts.

Use `./tool/verify.sh` for the shared local verification sequence.
