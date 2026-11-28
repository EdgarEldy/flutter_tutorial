# Branch: feature/auth

This branch implements the complete authentication experience.

---

## Screens

- Sign in
- Register
- Activate account
- Forgot password
- Verify OTP
- Reset password
- Profile

## Sign-in flow

1. The user submits email and password.
2. `SignInUseCase` delegates to `AuthRepository`.
3. Tokens are saved in secure storage.
4. `AuthNotifier` becomes authenticated.
5. GoRouter redirects to `/products`.

## Authentication shell

Auth screens share `AuthShellWidget`, built with `Stack` and `ClipRRect`. The hero uses the violet gradient, 28dp overlap and rounded white card.

The sign-in hero is 300dp. Secondary auth screens use a 200dp hero.

## Password reset

The reset flow contains three steps:

1. Email
2. OTP verification
3. New password

OTP values stay in transient state. They are never persisted or logged.
