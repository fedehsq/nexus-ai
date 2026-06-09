# AGENTS.md

## Purpose

This Flutter project must follow strict architectural and organizational conventions.

The goal is to keep the codebase:
- clean
- consistent
- scalable
- production-ready

When generating or modifying code, you MUST follow all the rules defined below.

---

## Tech Stack

### Networking (AUTO-GENERATED)
- OpenAPI / Swagger
- Generated API client (DO NOT MODIFY manually)
- Generated DTO/models (DO NOT MODIFY manually)
- `swagger_parser` for code generation
- `dio`
- `retrofit`

### State Management
- `hooks_riverpod`
- `flutter_hooks`
- `riverpod_annotation`
- `riverpod_generator`

### Local Persistence
- `objectbox`
- `objectbox_flutter_libs`
- `objectbox_generator`

### Mapping
- `auto_mappr`
- `auto_mappr_annotation`

### Utilities
- `flutter_secure_storage`
- `permission_handler`

### Routing
- `go_router`

### Build tools
- `build_runner`

---

## CRITICAL RULE: API LAYER IS GENERATED

All API clients and DTOs are generated from Swagger thanks to `swagger_parser`.

You MUST:
- NEVER modify generated files manually
- NEVER use generated DTOs directly in UI if they represent external structures
- ALWAYS map API DTOs to internal app models using `auto_mappr`

Generated code is considered:
- unstable
- replaceable
- external to business logic

---

## Architecture Overview

Organize the codebase with clear separation of concerns:

- api (generated)
- models (app domain models)
- providers (state management)
- screens (UI entry points)
- widgets (UI components)
- router
- mappers
- repositories (optional but recommended)

Avoid mixing responsibilities.

---

## Models

The `models/` folder contains ONLY app domain models.

DO NOT:
- use Swagger-generated DTOs as UI models
- leak API structures into the UI layer

DO:
- create clean, UI-friendly models
- map API DTOs → app models using `auto_mappr`

---

## Mapping

Use `auto_mappr` for all non-trivial mappings.

Mappings must be:
- centralized
- predictable
- reusable

DO NOT:
- manually map objects across the codebase in an inconsistent way

---

## Providers (Riverpod)

Riverpod is the ONLY state management solution.

### Structure

Each provider should have its own folder when non-trivial:

```text
lib/
  providers/
    feature_x/
      feature_x_provider.dart
```
### Rules
- Keep providers focused and readable
- Do not mix unrelated providers in the same file
- Use meaningful names

### Api Providers
- wrap API skeleton inside `lib/providers/api/api_provider.dart`:
    - Define `Dio apiDio(Ref ref)`
    - Define a provider for each API client (e.g., `authClientProvider`)
- for each operation, create a dedicated provider file (e.g., `lib/providers/api/controllers/login_controller.dart`)

### CRITICAL RULE: Providers in UI
Inside screens:
- ALWAYS use ref.watch(...) for state
- NEVER rely on await ref.read(provider.future) for main UI flow

The UI must react to state, not drive it imperatively.

#### Allowed
- watch for rendering
- read only for user-triggered actions (submit, refresh, etc.)
#### Not allowed
- manual async orchestration inside UI
- loading data imperatively inside build logic

If logic is complex → move it into the provider.

### Complex Providers
If logic grows:
- use Notifier / AsyncNotifier
- create dedicated state classes
- extract services or repositories if needed
Avoid putting too much logic inside a single annotated function.

## Screens
Each screen must have its own folder:
```text
lib/
  screens/
    login/
      login_screen.dart
      widgets/
```

### Rules
- one screen.dart per screen
- screen = orchestration only
- no heavy logic inside UI
- keep it readable

## Widgets
Custom widgets for a screen must be inside:
```text
lib/
  screens/
    login/
      login_screen.dart
      widgets/
```
Reusable UI components go in `lib/widgets/` folders.  
Avoid duplication, but do not over-abstract small widgets.

## Routing
All routing is centralized in `lib/router/router.dart`.
All router args must be defined as typed classes into `lib/router/args/`.  
You MUST:
- define a constant for each route

Example:
```
const String loginRoute = '/login';
const String homeRoute = '/home';
```

DO NOT:
- hardcode route strings across the app

## Networking Usage
Since APIs are generated:
- use generated clients via dio / retrofit
- do not modify generated code
- wrap API calls inside provider

## Local Persistence (ObjectBox)
Rules:
- do not expose ObjectBox entities directly to UI
- map entities → domain models if needed
- avoid queries inside UI or widgets
- use repositories or providers

## Code Style

Write code that is:
- simple
- readable
- modular
- consistent
- idiomatic Flutter/Dart

Avoid:

- large files
- business logic inside widgets
- direct DTO usage in UI
- duplicated mapping logic
- scattered routing strings