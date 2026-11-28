# Branche : feature/product-catalog

Cette branche construit la navigation produit, la grille filtrable et le détail produit.

---

## Écrans

- Liste produits
- Détail produit
- Bottom navigation : Produits, Panier, Commandes, Profil

## Catalogue

`ProductsNotifier` charge les catégories et les produits. La recherche est debouncée et les catégories sont filtrées par identifiant.

`ProductCard` affiche l'image, le nom et le prix dans une grille responsive de deux colonnes ou plus selon la largeur.

## Cache

`ProductRepositoryImpl` suit une stratégie cache-first :

1. Lire les lignes locales.
2. Si présentes, les afficher immédiatement.
3. Rafraîchir le réseau en arrière-plan.
4. Si le cache est vide, appeler directement le réseau.

Sur Web, un cache mémoire remplace sqflite si nécessaire.

## Pull-to-refresh

`RefreshProductsUseCase` force un fetch réseau puis reconstruit le cache local. Le refresh ne doit pas être remplacé par un simple appel cache-first.

## Détail produit

L'écran affiche une image 300dp, une catégorie, le nom, le prix, la description et un sélecteur de quantité. Le bouton add-to-cart appelle `CartNotifier` depuis la phase panier.
