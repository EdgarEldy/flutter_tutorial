# Architecture

The project separates code by feature and layer. Shared infrastructure lives in `lib/core`.

---

## Global structure

```text
lib/
  app/
    router/
    theme/
  core/
    database/
    errors/
    network/
    pagination/
    providers/
    storage/
  features/
    auth/
    products/
    cart/
    orders/
```

## Feature Clean Architecture

```text
presentation/
  pages/
  providers/
  widgets/
      |
      v
domain/
  entities/
  repositories/
  usecases/
      |
      v
data/
  datasources/
  models/
  repositories/
  providers/
```

### presentation

Pages are `HookConsumerWidget` or `ConsumerWidget`. They watch providers, render state and delegate mutations to notifiers.

### domain

Entities are pure Dart types. Repository interfaces define contracts. Use cases contain business rules and return `Either<Failure, T>`.

### data

Datasources talk to Dio or sqflite. Freezed models stay in this layer. Repository implementations combine network, cache and model-to-entity mapping.

## Riverpod

Providers use `riverpod_annotation`. Keep-alive providers serve infrastructure and global state. Notifiers expose mutations and rebuild state.

## Errors

Business operations return `Either<Failure, T>`. Network, server, validation, authentication and cache failures use separate `Failure` types.

## Navigation

The route guard reads `AuthNotifier`. Anonymous users cannot enter protected routes. Authenticated users enter the four-tab shell.
