# Branche : feature/shopping-cart

Cette branche implémente le panier serveur, les quantités, le checkout et la confirmation.

---

## Écrans

- Panier
- Confirmation de commande

## Panier

`CartNotifier` charge le panier et expose les opérations add, update, remove et checkout. Les données restent autoritaires côté serveur : les sous-totaux et le total viennent de la réponse API.

La liste contient des cartes article avec image placeholder, nom, prix unitaire, sous-total, quantité et suppression.

Les contrôles quantité ont une zone tactile minimale de 48dp.

## Résumé sticky

Le widget `CartSummaryBar` reste en bas de l'écran et affiche le total serveur puis le bouton Checkout.

## Pull-to-refresh

Le refresh appelle à nouveau `GET /api/v1/cart` sans remplacer immédiatement la liste par un écran loading.

## Checkout

`CheckoutUseCase` poste `POST /api/v1/orders` sans corps. `CartNotifier.checkout()` bloque les soumissions concurrentes tant que `isCheckingOut` est vrai.

Après succès, l'utilisateur est dirigé vers la page de confirmation.
