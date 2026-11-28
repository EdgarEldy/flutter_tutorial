# Branche : feature/core-architecture

Cette branche construit la fondation commune utilisée par toutes les features.

---

## Livrables

- Configuration `ProviderScope`
- Chargement dotenv par environnement
- Thème clair/sombre Material 3
- GoRouter avec garde d'authentification
- Client Dio
- Intercepteur JWT et refresh
- Stockage sécurisé des tokens
- Base sqflite
- Pagination générique
- Providers Riverpod core

## Configuration dotenv

Chaque entrée charge un fichier différent :

```text
.env
.env.development
.env.emulator
.env.production
.env.web
```

Chaque fichier définit `BASE_URL`. La valeur doit finir par `/`.

## Réseau

`DioClient` centralise le client HTTP. `AuthInterceptor` ajoute le Bearer, tente le refresh et publie une session expirée si nécessaire.

Les pages ne gèrent jamais les tokens manuellement.

## Stockage sécurisé

`SecureTokenStorage` lit, écrit et efface les access/refresh tokens via `flutter_secure_storage`. Les mots de passe et OTP ne sont jamais stockés.

## Base locale

`AppDatabase` ouvre la base sqflite. Les tables produits, catégories, commandes et leurs items sont ajoutées lors des branches concernées. Sur Web, certains modules utilisent un fallback mémoire lors des tests ou du runtime.
