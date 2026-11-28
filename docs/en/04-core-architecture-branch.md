# Branch: feature/core-architecture

This branch builds the foundation shared by every later feature.

---

## Deliverables

- ProviderScope bootstrap
- Environment-specific dotenv loading
- Light and dark Material 3 themes
- GoRouter auth guard
- Dio HTTP client
- JWT interceptor and refresh flow
- Secure token storage
- sqflite database
- Generic pagination
- Core Riverpod providers

## dotenv

Each entry point loads an environment file:

```text
.env
.env.development
.env.emulator
.env.production
.env.web
```

Every `BASE_URL` must end with `/`.

## Network

`DioClient` centralizes HTTP configuration. `AuthInterceptor` attaches the Bearer token, attempts refresh and publishes session expiry when needed.

Pages never read or persist tokens directly.

## Secure storage

`SecureTokenStorage` reads, writes and clears access/refresh tokens through `flutter_secure_storage`. Passwords and OTP values are never cached.

## Local database

`AppDatabase` opens sqflite. Product, category, order and order-item tables grow with the feature branches. Web providers may use memory fallbacks where sqflite is unavailable.
