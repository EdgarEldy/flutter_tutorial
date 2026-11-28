# Conventions

This document summarizes the conventions used throughout the project.

---

## Dart and Flutter

- Run `dart format` on changed Dart files.
- Respect `analysis_options.yaml`.
- Never expose Freezed models outside the data layer.
- Use `Either<Failure, T>` in use cases.
- Do not instantiate Dio or sqflite directly from a page.

## Reusable widgets

Extract repeated UI into `presentation/widgets/`.

Cross-feature widgets belong in `lib/core/widgets/`. Each widget should receive data through constructor parameters instead of reading providers directly.

Examples:

- authentication text fields
- authentication page shell
- product cards
- order cards
- status badges
- loading and error states

## Commits

Use Conventional Commits:

```text
feat(scope): short imperative subject
fix(scope): short imperative subject
docs(scope): short imperative subject
test(scope): short imperative subject
chore(scope): short imperative subject
```

The body explains the decision or reason for the change.

Do not mention mockup/design in commit subjects or bodies. Never commit directly to `master` or `develop`.

## Tests

Use:

```dart
test('_01_ShouldReturnRight_WhenCredentialsAreValid', () async {});
testWidgets('_02_ShouldShowForm_WhenPageLoads', (tester) async {});
```

Groups should name the tested class or behavior.
