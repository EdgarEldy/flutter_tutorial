# Branche : feature/auth

Cette branche implémente toute l'expérience d'authentification.

---

## Écrans

- Connexion
- Inscription
- Activation du compte
- Mot de passe oublié
- Vérification OTP
- Nouveau mot de passe
- Profil

## Flux principal

1. L'utilisateur se connecte.
2. `SignInUseCase` appelle `AuthRepository`.
3. L'implémentation sauvegarde les tokens dans le stockage sécurisé.
4. `AuthNotifier` passe à `AuthState.authenticated`.
5. Le garde GoRouter redirige vers `/products`.

## Shell d'authentification

Les écrans utilisent `AuthShellWidget` avec `Stack` et `ClipRRect`. Le hero partage le gradient violet, le chevauchement de 28dp et le card blanc arrondi.

La hauteur du hero vaut 300dp pour la connexion et 200dp pour les écrans secondaires.

## Réinitialisation

Le flux comprend trois étapes :

1. Email
2. OTP
3. Nouveau mot de passe

Les valeurs OTP restent uniquement dans l'état transient. Elles ne sont jamais enregistrées dans la base locale ou les logs.
