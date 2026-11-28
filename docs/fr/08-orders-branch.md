# Branche : feature/orders

Cette branche ajoute l'historique des commandes et le détail de chaque commande.

---

## Écrans

- Mes commandes
- Détail commande

## Liste

Chaque carte affiche le numéro de commande, le badge de statut, le nombre d'articles, le total et une flèche de navigation.

Les statuts sont normalisés :

| Backend | Interface |
|---|---|
| PENDING | Processing |
| CONFIRMED | Confirmed |
| CANCELLED | Cancelled |
| autre | Unknown |

## Détail

Le header affiche le bouton retour, `Order #...` et le badge de statut.

Le corps contient :

1. Une timeline de suivi.
2. Une carte des articles.
3. Une carte de résumé avec sous-total, livraison gratuite et total.

L'écran n'affiche aucun champ de date car `created_at` n'est pas fourni par l'API.

## Cache

`OrderRepositoryImpl` sert les commandes cache-first. Un détail chargé depuis le réseau est sauvegardé avec `upsertOrder`, qui remplace uniquement cette commande et ses items sans effacer les autres commandes.

Le pull-to-refresh rechargement le réseau et remplace atomiquement la liste du cache.
