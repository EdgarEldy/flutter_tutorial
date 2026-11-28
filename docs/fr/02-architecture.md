# Architecture

Le projet applique une séparation par feature, puis par couche. Chaque feature reste autonome tout en utilisant les infrastructures communes situées dans `lib/core`.

---

## Structure globale

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

Les pages sont des `HookConsumerWidget` ou `ConsumerWidget`. Elles observent les providers Riverpod, rendent les états et délèguent les actions aux notifiers.

### domain

Les entités sont des types Dart purs. Les repository interfaces décrivent les opérations. Les use cases contiennent les règles métier et retournent toujours `Either<Failure, T>`.

### data

Les datasources parlent à Dio ou sqflite. Les modèles Freezed sont limités à cette couche. Les implementations de repository combinent réseau, cache et mapping vers les entités.

## Providers Riverpod

Les providers sont générés avec `riverpod_annotation`. Les providers keepAlive servent aux infrastructures et aux états globaux. Les notifiers exposent les mutations et reconstruisent les états.

## Erreurs

Toutes les opérations métier retournent `Either<Failure, T>`. Les échecs réseau, serveur, validation, authentification et cache sont représentés par des types distincts dans `Failure`.

## Navigation

Le garde de route lit `AuthNotifier`. Les routes publiques ne redirigent pas un utilisateur anonyme. Les routes protégées redirigent vers `/sign-in`. L'utilisateur authentifié accède au shell à quatre onglets.
