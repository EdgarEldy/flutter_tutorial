# Conventions

Ce document résume les conventions à respecter dans tout le projet.

---

## Dart et Flutter

- Utiliser `dart format` sur les fichiers modifiés.
- Respecter les lints définis dans `analysis_options.yaml`.
- Ne pas exposer les modèles Freezed hors de la couche data.
- Utiliser `Either<Failure, T>` dans les use cases.
- Ne pas instancier Dio ou sqflite directement depuis une page.

## Widgets réutilisables

Extraire les widgets utilisés plusieurs fois dans `presentation/widgets/`.

Les widgets transverses à plusieurs features peuvent être placés dans `lib/core/widgets/`. Chaque widget doit recevoir les données nécessaires par constructeur plutôt que lire directement des providers.

Exemples réutilisés :

- champs d'authentification
- shell de page avec hero
- cartes produit
- cartes commande
- badges de statut
- indicateurs de chargement et d'erreur

## Commits

Les commits suivent Conventional Commits :

```text
feat(scope): sujet impératif court
fix(scope): sujet impératif court
docs(scope): sujet impératif court
test(scope): sujet impératif court
chore(scope): sujet impératif court
```

Le body explique la décision ou le pourquoi du changement. Il ne reprend pas simplement le sujet.

Ne jamais mentionner mockup/design dans un message. Ne jamais commit directement sur `master` ou `develop`.

## Tests

Les noms suivent :

```dart
test('_01_ShouldReturnRight_WhenCredentialsAreValid', () async {});
testWidgets('_02_ShouldShowForm_WhenPageLoads', (tester) async {});
```

Les groupes doivent nommer la classe ou le comportement testé.

## Branches

- `feature/core-architecture`
- `feature/auth`
- `feature/product-catalog`
- `feature/shopping-cart`
- `feature/orders`
- `feature/docs`

Une branche feature doit fusionner sa branche aval directe dans le sens demandé par le workflow, puis sa phase validée doit aller dans `develop`.
