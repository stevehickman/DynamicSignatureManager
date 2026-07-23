# ADR 0001: Modular Package Architecture

## Status

Accepted

## Decision

Dynamic Signature Manager will use a layered Swift Package architecture.

Core business rules remain independent of UI and external services.

## Packages

- Domain
- Application
- Infrastructure
- Plugin API
- Mail
- HTML

## Rationale

This improves:

- Testability
- Maintainability
- Platform portability
- Future extension support
