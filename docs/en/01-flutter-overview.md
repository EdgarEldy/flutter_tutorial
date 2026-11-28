# Flutter Overview

Flutter Tutorial is a complete e-commerce application built with Dart, Flutter and Material 3. It connects to the Spring Boot backend and covers authentication, products, cart, orders and profile.

---

## User journey

1. Create and activate an account with an OTP.
2. Sign in with email and password.
3. Browse products and categories.
4. Open a product, choose a quantity and add it to the cart.
5. Update or remove cart items and checkout.
6. View the confirmed order and its status.

## Main stack

| Area | Choice |
|---|---|
| Language | Dart |
| UI | Flutter + Material 3 |
| State management | Riverpod |
| Form hooks | flutter_hooks |
| Navigation | go_router |
| HTTP | Dio |
| Serialization | freezed + json_serializable |
| Local cache | sqflite |
| Secure storage | flutter_secure_storage |
| Configuration | flutter_dotenv |
| Testing | flutter_test + mocktail |

## Architecture

The project follows feature-first Clean Architecture. Every feature owns `data`, `domain` and `presentation` layers. Pages never call Dio directly, and repositories implement domain contracts.

## Entry points

- `lib/main.dart`
- `lib/main_development.dart`
- `lib/main_emulator.dart`
- `lib/main_production.dart`
- `lib/main_web.dart`
- `lib/bootstrap.dart`

## Navigation

GoRouter uses a public-route list and an auth guard. Public routes cover sign-in, registration, activation and password reset. Authenticated users enter a `StatefulShellRoute.indexedStack` with Products, Cart, Orders and Profile.
