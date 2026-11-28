# Flutter Tutorial

A complete, hands-on walkthrough of building a production-quality Flutter e-commerce application using **Dart, Flutter and Material 3**, connected to the [`spring-boot-tutorial`](https://github.com/EdgarEldy/spring-boot-tutorial) backend.

The application covers the full customer journey: account creation, authentication, product browsing, cart management, checkout and order tracking. It is both a realistic API client and a structured learning resource for modern Flutter development.

---

## Table of contents

- [Application features](#application-features)
- [Screens](#screens)
- [Tech stack](#tech-stack)
- [Architecture](#architecture)
- [Package structure](#package-structure)
- [Backend integration](#backend-integration)
- [Security](#security)
- [Development environment](#development-environment)
- [Build and test](#build-and-test)
- [CI](#ci)
- [Conventions](#conventions)
- [Branching strategy](#branching-strategy)
- [feature/core-architecture](#featurecore-architecture)
- [feature/auth](#featureauth)
- [feature/product-catalog](#featureproduct-catalog)
- [feature/shopping-cart](#featureshopping-cart)
- [feature/orders](#featureorders)
- [Implementation status](#implementation-status)
- [Concepts covered](#concepts-covered)

---

## Application features

**Authentication**
- Sign in with email and password
- Create an account (registration + 6-digit activation code sent by email)
- Restore a session automatically on app launch
- Reset a forgotten password using a 6-digit OTP sent by email
- Sign out and clear all local credentials

**Product discovery**
- Browse paginated product listings
- Filter products by category, name and price range
- View product details with images, description and price
- Browse products and categories while offline (served from local cache)

**Shopping**
- Add products to the server-side cart
- Update quantities or remove items
- View server-calculated cart totals
- Place an order from the cart in one tap
- Receive order confirmation

**Orders and account**
- Browse order history with status tracking
- View full order details and item breakdown
- Display profile information
- Sign out

---

## Screens

| Screen | Description |
|---|---|
| Sign in | Email + password form with form validation |
| Register | Multi-field registration form |
| Activate account | 6-digit OTP entry after registration |
| Forgot password | Email entry to request a reset OTP |
| Verify OTP | 6-digit OTP entry to validate before the new password screen |
| Reset password | New password + confirmation; submits OTP to the backend |
| Product list | Filterable, searchable, paginated product grid |
| Product detail | Images, description, price, quantity picker, add-to-cart |
| Cart | Line items, quantities, subtotals, server-calculated total, checkout button |
| Checkout confirmation | Order summary and confirmed order number |
| Order list | Paginated history of past orders with status badges |
| Order detail | Full order with item breakdown and total |
| Profile | User information and sign out |

---

## Tech stack

### Application

| Component | Choice |
|---|---|
| Language | Dart |
| UI framework | Flutter |
| Design system | Material 3 |
| Navigation | go_router |
| Image loading | cached_network_image |

### Architecture

| Component | Choice |
|---|---|
| Pattern | Feature-first Clean Architecture |
| Dependency injection | Riverpod (ProviderScope) |
| Async | Dart async/await |
| State management | Riverpod + Hooks (flutter_riverpod, hooks_riverpod, flutter_hooks) |
| Error handling | fpdart `Either<Failure, T>` |

### Data and networking

| Component | Choice |
|---|---|
| HTTP client | Dio v5 |
| Serialization | freezed + json_serializable |
| Secure storage | flutter_secure_storage |
| Local cache | sqflite v2 |
| Env configuration | flutter_dotenv |

### Testing

| Tool | Scope |
|---|---|
| flutter_test | Unit and widget tests |
| mocktail | Mocking |
| http_mock_adapter | Dio integration tests |
| sqflite_common_ffi | In-memory database tests |
| golden_toolkit | Golden / visual tests |

---

## Architecture

The application follows Clean Architecture inside a feature-first folder structure. Each feature is a self-contained folder with its own data, domain and presentation layers. Core infrastructure lives in `lib/core/`. Dependencies only point inward.

```
┌──────────────────────────────────────────────────────┐
│                  features/<name>/                     │
│  presentation/ (pages, providers, widgets)            │
│       calls domain/usecases/                          │
│  domain/ (entities, repository interfaces, usecases)  │
│       implemented by data/                            │
│  data/ (models, remote datasources, repositories)     │
└───────────────────────┬──────────────────────────────┘
                        │ depends on
┌───────────────────────▼──────────────────────────────┐
│  core/network · core/storage · core/database          │
│  core/providers · core/errors · core/pagination       │
└───────────────────────┬──────────────────────────────┘
                        │
              ┌─────────▼─────────┐
              │  Spring Boot API  │
              └───────────────────┘
```

### Layer responsibilities

| Layer | Contents |
|---|---|
| **presentation/** | `HookConsumerWidget` pages, `@riverpod` Notifiers, reusable widgets |
| **domain/** | Pure Dart entities, repository interfaces, use cases (all business logic) |
| **data/** | Repository implementations, freezed+json models, Dio datasources, sqflite mappers |
| **core/network** | Dio client factory, `AuthInterceptor` (JWT attach + silent refresh) |
| **core/storage** | `SecureTokenStorage` (flutter_secure_storage) |
| **core/database** | sqflite database, table schemas, DAOs |
| **core/providers** | Infrastructure Riverpod providers (Dio, DB, SecureStorage) |
| **core/errors** | Sealed `Failure` hierarchy |

### Key rules

- Pages (`HookConsumerWidget`) watch Riverpod providers; they never call Dio directly.
- Notifiers (`AsyncNotifier` / `Notifier`) expose state and mutations; they never contain SQL or HTTP code.
- Data models (`@freezed`) never leak out of `data/` — notifiers and pages only see domain entities.
- Backend business rules (prices, cart totals, order status) are never recalculated on the client.
- Use cases always return `Either<Failure, T>`; notifiers call `.fold()` to dispatch state.

---

## Package structure

```
flutter_tutorial/
├── lib/
│   ├── app/
│   │   ├── router/
│   │   │   └── app_router.dart               ← @riverpod GoRouter (StatefulShellRoute, auth guard)
│   │   └── theme/
│   │       └── app_theme.dart                ← Material 3 light + dark themes
│   ├── core/
│   │   ├── database/
│   │   │   └── app_database.dart             ← sqflite open, schema, DAOs
│   │   ├── errors/
│   │   │   └── failure.dart                  ← sealed Failure hierarchy
│   │   ├── network/
│   │   │   ├── dio_client.dart               ← Dio factory (.env base URL)
│   │   │   └── auth_interceptor.dart         ← Bearer attach + silent refresh
│   │   ├── pagination/
│   │   │   └── paginated_result.dart         ← generic PaginatedResult<T>
│   │   ├── providers/
│   │   │   ├── dio_provider.dart             ← @Riverpod(keepAlive: true) Dio
│   │   │   ├── database_provider.dart        ← @Riverpod(keepAlive: true) Database
│   │   │   └── secure_storage_provider.dart  ← @Riverpod(keepAlive: true) SecureTokenStorage
│   │   └── storage/
│   │       └── secure_token_storage.dart     ← flutter_secure_storage wrapper
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/              ← Dio remote datasource
│   │   │   │   ├── models/                   ← @freezed + json_serializable
│   │   │   │   └── repositories/             ← AuthRepositoryImpl
│   │   │   ├── domain/
│   │   │   │   ├── entities/                 ← User
│   │   │   │   ├── repositories/             ← AuthRepository interface
│   │   │   │   └── usecases/                 ← SignIn, Register, Logout, ...
│   │   │   └── presentation/
│   │   │       ├── pages/                    ← SignInPage, RegisterPage, ...
│   │   │       ├── providers/                ← AuthNotifier, PasswordResetNotifier
│   │   │       └── widgets/
│   │   ├── products/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/                 ← Product, Category
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── pages/                    ← ProductListPage, ProductDetailPage
│   │   │       ├── providers/                ← ProductsNotifier, ProductDetailNotifier
│   │   │       └── widgets/
│   │   ├── cart/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/                 ← Cart, CartItem
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── pages/                    ← CartPage, CheckoutConfirmationPage
│   │   │       ├── providers/                ← CartNotifier
│   │   │       └── widgets/
│   │   └── orders/
│   │       ├── data/
│   │       │   ├── datasources/
│   │       │   ├── models/
│   │       │   └── repositories/
│   │       ├── domain/
│   │       │   ├── entities/                 ← Order, OrderItem, OrderStatus
│   │       │   ├── repositories/
│   │       │   └── usecases/
│   │       └── presentation/
│   │           ├── pages/                    ← OrderListPage, OrderDetailPage
│   │           ├── providers/                ← OrdersNotifier, OrderDetailNotifier
│   │           └── widgets/
│   ├── bootstrap.dart                        ← dotenv → ProviderScope → runApp
│   ├── main.dart                             ← default entry point (.env.development)
│   ├── main_development.dart                 ← physical device flavor (.env.development)
│   ├── main_emulator.dart                    ← Android emulator flavor (.env.emulator)
│   ├── main_web.dart                         ← Flutter Web entry point (.env.web)
│   └── main_production.dart                  ← release flavor (.env.production)
├── test/
│   ├── core/
│   └── features/
│       ├── auth/
│       ├── products/
│       ├── cart/
│       └── orders/
├── openapi/
│   └── openapi.json
├── .env
├── .env.development
├── .env.production
├── pubspec.yaml
├── analysis_options.yaml
└── .gitignore
```

---

## Backend integration

The application is a pure API client. All business logic, authentication, prices, cart ownership and order management live exclusively in the backend.

| Item | Value |
|---|---|
| Backend | `spring-boot-tutorial` (Spring Boot 3.5.x) |
| API prefix | `/api/v1` |
| Auth | JWT Bearer (`access_token` + `refresh_token`) |
| OpenAPI snapshot | `openapi/openapi.json` |

### Network targets by environment

| File | Base URL | Target |
|---|---|---|
| `.env` | `http://localhost:8080/` | Default (`flutter run`) |
| `.env.development` | `http://localhost:8080/` | Physical device (`adb reverse tcp:8080 tcp:8080`) |
| `.env.emulator` | `http://10.0.2.2:8080/` | Android emulator host alias |
| `.env.web` | `http://localhost:8080/` | Flutter Web / browser |
| `.env.production` | HTTPS URL supplied per environment | Release build |

### Response envelope

Every API response is wrapped in a consistent envelope:

```json
{
  "success": true,
  "message": "Products retrieved successfully",
  "data": { ... },
  "timestamp": "2026-11-21T10:15:30Z"
}
```

Paginated endpoints return a `PageResponse<T>` in `data`:

```json
{
  "content": [ ... ],
  "page": 0,
  "size": 20,
  "totalElements": 42,
  "totalPages": 3
}
```

Error responses carry an RFC 7807 `ProblemDetail` in `data` with `success: false`.
All JSON field names use **snake_case** (`product_name`, `unit_price`, `access_token`).

### Authentication flows

**Sign in / session lifecycle**

```
POST /api/v1/auth/login          → { access_token, refresh_token, expires_in }
POST /api/v1/auth/refresh-token  → { access_token, refresh_token, expires_in }
POST /api/v1/auth/logout
GET  /api/v1/auth/me             → user profile
```

**Registration + activation**

```
POST /api/v1/auth/register          → account created (enabled = false)
POST /api/v1/auth/activate-account  → { email, activation_code (6 digits) }
```

**Mobile password reset (3-step OTP)**

```
POST /api/v1/password-reset/mobile      → { email }             # OTP sent by email
POST /api/v1/password-reset/verify-otp  → { email, otp }        # validates without consuming
POST /api/v1/password-reset/confirm     → ?token={otp}
                                           { new_password,
                                             confirm_password }  # resets and consumes OTP
```

> The web password reset endpoints at `/api/v1/auth/forgot-password` and `/api/v1/auth/reset-password` belong to the Angular frontend and are **never called** from this application.

### Mobile API surface

| Resource | Endpoint | Auth required |
|---|---|---|
| Products | `GET /api/v1/products` | No |
| Product detail | `GET /api/v1/products/{id}` | No |
| Categories | `GET /api/v1/categories` | No |
| Category detail | `GET /api/v1/categories/{id}` | No |
| Cart | `GET /api/v1/cart` | Yes |
| Add to cart | `POST /api/v1/cart/items` | Yes |
| Update cart item | `PATCH /api/v1/cart/items/{itemId}` | Yes |
| Remove cart item | `DELETE /api/v1/cart/items/{itemId}` | Yes |
| Clear cart | `DELETE /api/v1/cart/items` | Yes |
| Checkout | `POST /api/v1/orders` | Yes |
| Order history | `GET /api/v1/orders` | Yes |
| Order detail | `GET /api/v1/orders/{id}` | Yes |

---

## Security

- **Tokens** (`access_token`, `refresh_token`) are stored exclusively in `flutter_secure_storage` (platform Keychain/Keystore). They are never written to SharedPreferences, files or logs.
- **Passwords** are never stored or cached at any point.
- **OTP values** are held only in transient store state; they are never persisted or logged.
- **Authorization headers** are attached centrally by a Dio interceptor; no page manages tokens directly.
- **Token refresh** is handled transparently by the interceptor; concurrent refresh requests are serialized.
- **Logout** clears all stored credentials and invalidates the token server-side.

---

## Development environment

### Requirements

| Requirement | Notes |
|---|---|
| Flutter SDK | 3.13+ (stable channel) |
| Dart SDK | 3.1+ (bundled with Flutter) |
| Android SDK | Required for Android target |
| Xcode | Required for iOS target (macOS only) |
| VS Code or Android Studio | With Flutter/Dart extensions |

### Setup

```bash
# Install dependencies
flutter pub get

# Generate freezed + json_serializable + riverpod code
dart run build_runner build --delete-conflicting-outputs

# Copy env file (edit BASE_URL as needed)
cp .env.development .env
```

### Entry points

| Entry point | Env file | Use case |
|---|---|---|
| `lib/main.dart` | `.env.development` | Quick `flutter run` |
| `lib/main_development.dart` | `.env.development` | Physical device |
| `lib/main_emulator.dart` | `.env.emulator` | Android emulator |
| `lib/main_web.dart` | `.env.web` | Browser (Flutter Web) |
| `lib/main_production.dart` | `.env.production` | Release / CI |

### Environment file format

```
BASE_URL=http://localhost:8080/
```

---

## Build and test

```bash
# Physical device (requires adb reverse tcp:8080 tcp:8080 first)
flutter run -t lib/main_development.dart

# Android emulator
flutter run -t lib/main_emulator.dart

# Flutter Web
flutter run -t lib/main_web.dart -d chrome

# Default (same as main_development.dart)
flutter run

# Run unit tests
flutter test

# Run with coverage
flutter test --coverage

# Build release APK (Android)
flutter build apk --release

# Build release IPA (iOS, macOS only)
flutter build ipa --release

# Regenerate code (after modifying freezed/json models or @riverpod notifiers)
dart run build_runner build --delete-conflicting-outputs
```

---

## CI

Continuous integration runs on GitHub Actions and triggers on **pull requests targeting `master` from `develop`** only.

| Step | Command |
|---|---|
| Install dependencies | `flutter pub get` |
| Generate code | `dart run build_runner build --delete-conflicting-outputs` |
| Static analysis | `flutter analyze` |
| Unit tests | `flutter test` |

Workflow file: [`.github/workflows/ci.yml`](.github/workflows/ci.yml)

---

## Conventions

### Commits

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): short imperative summary

Body explains why this change was made, written for a developer following
the tutorial. Explain the concept or decision demonstrated here, not just
what changed. Assume established codebase conventions do not need repeating.
```

**Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`, `build`

**Scopes:** the feature or core module touched

| Scope | Used for |
|---|---|
| `core/network` | Dio client, interceptors |
| `core/storage` | SecureTokenStorage |
| `core/database` | sqflite, DAOs |
| `core/errors` | Failure hierarchy |
| `core/providers` | Riverpod infrastructure providers |
| `auth` | Everything in `features/auth/` |
| `products` | Everything in `features/products/` |
| `cart` | Everything in `features/cart/` |
| `orders` | Everything in `features/orders/` |
| `router` | go_router, navigation |
| `theme` | Material 3 theme |
| `deps` | pubspec.yaml dependency changes |
| `config` | analysis_options, env files |
| `ci` | GitHub Actions workflow |

**Example:**

```
feat(auth): add SignInUseCase returning Either<Failure, User>

Use case calls AuthRepository.signIn and maps the result to domain types.
Credentials are never stored; only the tokens returned by the backend are
forwarded to SecureTokenStorage via saveTokens().
```

A body is required whenever the commit demonstrates a concept or non-trivial
decision. It can be omitted only for genuinely trivial, self-explanatory changes.

---

### Test naming

Tests are structured with `group()` and `test()`. The group names the subject under
test (class or method); the test string describes the scenario and expected outcome.

**Pattern:** `'returns <result> when <condition>'` or `'<action> <outcome>'`

```dart
group('SignInUseCase', () {
  test('returns Right(User) when credentials are valid', () async {
    // given
    when(() => mockRepository.signIn(any(), any()))
        .thenAnswer((_) async => right(user));
    // when
    final result = await useCase(email: 'a@b.com', password: 'secret');
    // then
    expect(result, right(user));
  });

  test('returns Left(UnauthorizedFailure) when password is wrong', () async {
    when(() => mockRepository.signIn(any(), any()))
        .thenAnswer((_) async => left(const UnauthorizedFailure()));
    final result = await useCase(email: 'a@b.com', password: 'wrong');
    expect(result, isA<Left<Failure, User>>());
  });

  test('returns Left(NetworkFailure) on network error', () async {
    when(() => mockRepository.signIn(any(), any()))
        .thenAnswer((_) async => left(const NetworkFailure()));
    final result = await useCase(email: 'a@b.com', password: 'secret');
    expect(result, isA<Left<Failure, User>>());
  });
});
```

For notifier tests, the group names the notifier and each test names the action and
the resulting state:

```dart
group('AuthNotifier', () {
  test('state is AuthStateAuthenticated after successful sign in', () async { ... });
  test('state is AuthStateError when use case returns UnauthorizedFailure', () async { ... });
  test('state is AuthStateUnauthenticated after logout', () async { ... });
});
```

---

## Branching strategy

| Branch | Scope |
|---|---|
| `master` | Stable and production-ready. No direct commits. |
| `develop` | Integration branch for all feature work. |
| `feature/core-architecture` | Project scaffold, pubspec.yaml, Dio + AuthInterceptor, SecureTokenStorage, sqflite schema, go_router setup, Riverpod code-gen, Material 3 theme, ProviderScope bootstrap. The app must build and show an empty scaffold before this branch closes. |
| `feature/auth` | Sign in, register, account activation (OTP), session restoration, token refresh, logout, 3-step mobile password reset, profile. |
| `feature/product-catalog` | Product list with search and category filter, product detail with add-to-cart, sqflite cache, bottom navigation shell. |
| `feature/shopping-cart` | Cart read and mutations, server-calculated totals, checkout flow, order confirmation. |
| `feature/orders` | Order history and order detail. |

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/) with a descriptive body explaining the **why**.

---

## feature/core-architecture

Technical foundation shared by every subsequent branch. The branch closes only when `flutter run` succeeds and the app launches on a device showing an empty scaffold.

### Tasks

- [x] `pubspec.yaml`: all dependencies pinned (Riverpod 3.5, go_router 18, Dio 5, freezed 4, build_runner 2.17)
- [x] `analysis_options.yaml`: strict lints with platform directory exclusions
- [x] `lib/main.dart` and `lib/bootstrap.dart`: startup sequence (dotenv → ProviderScope → runApp)
- [x] `lib/core/errors/failure.dart`: sealed Failure hierarchy
- [x] `lib/core/network/dio_client.dart`: Dio factory with `.env` base URL
- [x] `lib/core/network/auth_interceptor.dart`: attach Bearer + silent refresh + onSessionExpired callback
- [x] `lib/core/storage/secure_token_storage.dart`: read/write/clear tokens
- [x] `lib/core/database/app_database.dart`: sqflite open, schema version 1 (empty tables placeholder)
- [x] `lib/core/pagination/paginated_result.dart`: generic `PaginatedResult<T>`
- [x] `lib/core/providers/`: Riverpod providers for Dio, Database, SecureTokenStorage
- [x] `lib/app/theme/app_theme.dart`: Material 3 light + dark themes
- [x] `lib/app/router/app_router.dart`: `@Riverpod(keepAlive: true) GoRouter` with placeholder sign-in route
- [x] `.env`, `.env.development`, `.env.production` placeholder files
- [x] `flutter pub get` succeeds
- [x] `dart run build_runner build` succeeds
- [ ] `flutter run` launches empty scaffold

---

## feature/auth

All authentication screens, session management and the mobile OTP password reset flow.

### Screens

| Screen | Description |
|---|---|
| Sign in | Email + password, form validation, error display |
| Register | First name, last name, username, email, password + confirmation |
| Activate account | 6-digit OTP entry after registration |
| Forgot password | Email entry to request a reset OTP |
| Verify OTP | 6-digit OTP entry before showing the new-password screen |
| Reset password | New password + confirmation |
| Profile | User information from `/auth/me`, sign-out button |

### API operations

| Operation | Endpoint |
|---|---|
| Sign in | `POST /api/v1/auth/login` |
| Register | `POST /api/v1/auth/register` |
| Activate account | `POST /api/v1/auth/activate-account` |
| Logout | `POST /api/v1/auth/logout` |
| Refresh token | `POST /api/v1/auth/refresh-token` |
| Get profile | `GET /api/v1/auth/me` |
| Request OTP | `POST /api/v1/password-reset/mobile` |
| Verify OTP | `POST /api/v1/password-reset/verify-otp` |
| Reset password | `POST /api/v1/password-reset/confirm` |

### Tasks

- [x] Domain: `User` entity
- [x] Domain: `AuthRepository` interface
- [x] Domain: `PasswordResetRepository` interface
- [x] Domain: `SignInUseCase`, `RegisterUseCase`, `ActivateAccountUseCase`, `LogoutUseCase`
- [x] Domain: `RequestPasswordResetOtpUseCase`, `VerifyPasswordResetOtpUseCase`, `ResetPasswordUseCase`
- [x] Domain: `GetProfileUseCase`
- [x] Data: `@freezed` models (`AuthResponseModel`, `UserModel`, etc.)
- [x] Data: `AuthRemoteDatasource` (Dio)
- [x] Data: `AuthRepositoryImpl`
- [x] Data: `PasswordResetRepositoryImpl`
- [x] `SignInPage` + `AuthNotifier`
- [x] `RegisterPage`
- [x] `ActivateAccountPage`
- [x] `ForgotPasswordPage` + use case providers
- [x] `VerifyOtpPage`
- [x] `ResetPasswordPage`
- [x] `ProfilePage` driven by `AuthNotifier`
- [x] Session restoration on app launch
- [x] Wired via Riverpod providers
- [ ] Tests: use cases, `AuthNotifier`, `AuthRepositoryImpl`

---

## feature/product-catalog

Browsing experience: product listing with search and filtering, and product detail.

### Screens

| Screen | Description |
|---|---|
| Product list | Paginated grid, filterable by category, name, min/max price |
| Product detail | Images, description, price, quantity picker, add-to-cart button |

### API operations

| Operation | Endpoint |
|---|---|
| List categories | `GET /api/v1/categories` |
| List products | `GET /api/v1/products` |
| Product detail | `GET /api/v1/products/{id}` |

### Tasks

- [x] Domain: `Product`, `Category`, `ProductImage` entities
- [x] Domain: `ProductRepository`, `CategoryRepository` interfaces
- [x] Domain: `GetProductsUseCase`, `GetProductByIdUseCase`, `GetCategoriesUseCase`
- [x] Data: `@freezed` models + json_serializable
- [x] Data: `ProductRemoteDatasource`, `CategoryRemoteDatasource` (Dio)
- [x] Data: `ProductRepositoryImpl`, `CategoryRepositoryImpl` (cache-first with sqflite)
- [x] sqflite: `products_cache`, `product_images_cache`, `categories_cache` tables
- [x] `ProductListPage` + `ProductsNotifier`
- [x] `ProductDetailPage` + `ProductDetailNotifier`
- [x] Category filter chips + search bar
- [x] Pull-to-refresh
- [x] Bottom navigation shell (Products, Cart, Orders, Profile)
- [x] Wired via Riverpod providers
- [x] Alignement UI catalogue 390 x 844 avec grille, cartes, chips et bottom bar
- [x] Alignement UI détail produit avec image 300dp, pinned appbar et quantity selector
- [x] Tests: use cases, `ProductsNotifier`, `ProductRepositoryImpl`

---

## feature/shopping-cart

Cart management and checkout.

### Screens

| Screen | Description |
|---|---|
| Cart | Line items with quantities, subtotals, server-calculated total, checkout button |
| Checkout confirmation | Order number, status and summary after a successful checkout |

### API operations

| Operation | Endpoint |
|---|---|
| Get cart | `GET /api/v1/cart` |
| Add item | `POST /api/v1/cart/items` |
| Update quantity | `PATCH /api/v1/cart/items/{itemId}` |
| Remove item | `DELETE /api/v1/cart/items/{itemId}` |
| Clear cart | `DELETE /api/v1/cart/items` |
| Checkout | `POST /api/v1/orders` |

### Tasks

- [x] Domain: `Cart`, `CartItem` entities
- [x] Domain: `CartRepository` interface
- [x] Domain: `GetCartUseCase`, `AddCartItemUseCase`, `UpdateCartItemUseCase`, `RemoveCartItemUseCase`, `CheckoutUseCase`
- [x] Data: `@freezed` models + json_serializable
- [x] Data: `CartRemoteDatasource` (Dio)
- [x] Data: `CartRepositoryImpl`
- [x] `CartPage` + `CartNotifier`
- [x] `CheckoutConfirmationPage`
- [x] Add-to-cart action wired from `ProductDetailPage`
- [x] Cart badge on bottom nav
- [x] Duplicate-submit protection on checkout
- [x] Wired via Riverpod providers
- [ ] Tests: use cases, `CartNotifier`, `CartRepositoryImpl`

---

## feature/orders

Order history and order detail.

### Screens

| Screen | Description |
|---|---|
| Order list | Paginated history with order number, total and status badge |
| Order detail | Full item breakdown, quantities, unit prices and order total |

### API operations

| Operation | Endpoint |
|---|---|
| List orders | `GET /api/v1/orders` |
| Order detail | `GET /api/v1/orders/{id}` |

### Tasks

- [x] Domain: `Order`, `OrderItem` entities, `OrderStatus` enum (`PENDING`, `CONFIRMED`, `CANCELLED`)
- [x] Domain: `OrderRepository` interface
- [x] Domain: `GetOrdersUseCase`, `GetOrderByIdUseCase`
- [x] Data: `@freezed` models + json_serializable
- [x] Data: `OrderRemoteDatasource` (Dio)
- [x] Data: `OrderRepositoryImpl` (cache-first with sqflite)
- [x] sqflite: `orders_cache`, `order_items_cache` tables
- [x] `OrderListPage` + `OrdersNotifier`
- [x] `OrderDetailPage` + `OrderDetailNotifier`
- [x] `OrderStatusBadge` widget
- [x] Pull-to-refresh on order list
- [x] Wired via Riverpod providers
- [ ] Tests: use cases, `OrdersNotifier`, `OrderRepositoryImpl`

---

## Implementation status

| Phase | Branch | Status |
|---|---|---|
| 1 | `feature/core-architecture` | - |
| 2 | `feature/auth` | - |
| 3 | `feature/product-catalog` | - |
| 4 | `feature/shopping-cart` | - |
| 5 | `feature/orders` | - |

---

## Concepts covered

| Concept | Context |
|---|---|
| Dart idioms | Null safety, extension methods, sealed classes, async/await, Streams |
| Flutter widgets | Stateless/Stateful, CustomScrollView, SliverList, bottom nav shell |
| Material 3 | Color schemes, typography scale, component library, light/dark mode |
| go_router | Named routes, nested navigation, StatefulShellRoute, auth guard |
| Clean Architecture | Layered separation, dependency inversion, use cases |
| Riverpod | AsyncNotifier, Notifier, ProviderContainer, overrides, keepAlive |
| flutter_hooks | useTextEditingController, useEffect, useState — stateful logic without StatefulWidget |
| Dio | Interceptors, JWT attach, silent token refresh, error mapping |
| freezed | Immutable models, copyWith, pattern matching, union types |
| fpdart | `Either<Failure, T>`, error handling without exceptions |
| sqflite | Manual schema, raw queries, in-memory testing |
| flutter_secure_storage | Platform Keychain/Keystore token persistence |
| flutter_dotenv | Multi-environment configuration |
| Offline strategy | Cache-first with background refresh |
| Unit testing | Use cases, notifiers with mocktail |
| Integration testing | Repository tests with http_mock_adapter and sqflite_common_ffi |
| Golden testing | Widget visual regression with golden_toolkit |
| GitFlow | Feature branches, Conventional Commits, merge discipline |
