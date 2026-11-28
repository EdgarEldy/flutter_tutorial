# Branch: feature/orders

This branch adds order history and order detail.

---

## Screens

- My Orders
- Order Detail

## Order list

Each card shows the order number, status badge, item count, total and navigation chevron.

Backend values are normalized:

| Backend | UI |
|---|---|
| PENDING | Processing |
| CONFIRMED | Confirmed |
| CANCELLED | Cancelled |
| other | Unknown |

## Order detail

The header contains a back control, `Order #...` and status badge.

The body contains:

1. Tracking timeline
2. Items card
3. Summary card with subtotal, free shipping and total

No date field is displayed because `created_at` is not exposed by the API.

## Cache

`OrderRepositoryImpl` serves orders cache-first. A detail loaded from the network is saved with `upsertOrder`, replacing only that order and its items.

Pull-to-refresh atomically replaces the order cache with the fresh network list.
