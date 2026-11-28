# Branch: feature/product-catalog

This branch implements product browsing, filtering and product details.

---

## Screens

- Product list
- Product detail
- Bottom navigation for Products, Cart, Orders and Profile

## Catalog

`ProductsNotifier` loads categories and products. Search is debounced and categories are filtered by id.

`ProductCard` renders the image, name and price in a responsive grid.

## Cache

`ProductRepositoryImpl` uses a cache-first strategy:

1. Read local rows.
2. Return cached data immediately.
3. Refresh the network in the background.
4. Fetch directly if the cache is empty.

Web providers may use a memory cache when sqflite is unavailable.

## Pull-to-refresh

`RefreshProductsUseCase` forces a network fetch and replaces the local cache. It must not remain a cache-only read.

## Product detail

The detail page shows a 300dp image, category, name, price, description and quantity selector. Add-to-cart delegates to `CartNotifier`.
