# Branch: feature/shopping-cart

This branch implements the server-authoritative cart, quantity mutations, checkout and confirmation.

---

## Screens

- Cart
- Checkout confirmation

## Cart

`CartNotifier` loads the cart and exposes add, update, remove and checkout operations. Subtotals and total amount come from the server.

Each item card contains an image placeholder, product name, unit price, subtotal, quantity controls and remove action.

Quantity controls use a minimum 48dp touch target.

## Sticky summary

`CartSummaryBar` stays below the scrollable list and displays the server total followed by Checkout.

## Pull-to-refresh

Pull-to-refresh calls `GET /api/v1/cart` without replacing the current list with an initial loading indicator.

## Checkout

`CheckoutUseCase` posts `POST /api/v1/orders` with no body. `CartNotifier.checkout()` blocks concurrent submissions while `isCheckingOut` is true.

Success navigates to the confirmation page.
