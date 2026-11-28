# Vue d'ensemble Flutter

Flutter Tutorial est une application e-commerce complète construite avec Dart, Flutter et Material 3. Elle communique avec le backend Spring Boot et couvre l'authentification, le catalogue, le panier, les commandes et le profil.

---

## Parcours utilisateur

1. L'utilisateur crée un compte et active son adresse email avec un OTP.
2. Il se connecte avec email et mot de passe.
3. Il parcourt les produits et les catégories.
4. Il consulte un produit, choisit une quantité et ajoute celui-ci au panier.
5. Il met à jour ou supprime les articles, puis lance le checkout.
6. Il consulte l'ordre confirmé, son statut et son détail.

## Stack principale

| Domaine | Choix |
|---|---|
| Langage | Dart |
| Interface | Flutter + Material 3 |
| State management | Riverpod |
| State local dans les formulaires | flutter_hooks |
| Navigation | go_router |
| HTTP | Dio |
| Sérialisation | freezed + json_serializable |
| Cache local | sqflite |
| Stockage sécurisé | flutter_secure_storage |
| Configuration | flutter_dotenv |
| Tests | flutter_test + mocktail |

## Architecture

Le projet suit une architecture Clean par feature. Chaque feature contient ses couches `data`, `domain` et `presentation`. Les dépendances pointent vers l'intérieur : les pages ne parlent jamais directement à Dio et les repositories implémentent les contrats du domaine.

## Points d'entrée

- `lib/main.dart` : environnement standard
- `lib/main_development.dart` : backend local
- `lib/main_emulator.dart` : adresse réseau adaptée à l'émulateur
- `lib/main_production.dart` : configuration production
- `lib/main_web.dart` : Flutter Web
- `lib/bootstrap.dart` : chargement dotenv, `ProviderScope`, démarrage

## Navigation

Le routeur utilise `GoRouter` avec un garde d'authentification. Les routes publiques comprennent connexion, inscription, activation et récupération du mot de passe. Les routes protégées utilisent un `StatefulShellRoute.indexedStack` à quatre onglets : Produits, Panier, Commandes, Profil.
