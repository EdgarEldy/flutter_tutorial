// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/auth/data/providers/auth_providers.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/register_use_case.dart';
import 'package:flutter_tutorial/features/auth/presentation/pages/register_page.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  late MockRegisterUseCase mockRegisterUseCase;
  late ProviderContainer container;

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
    container = ProviderContainer(
      overrides: [
        registerUseCaseProvider.overrideWithValue(mockRegisterUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Widget buildUnderTest() {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: RegisterPage()),
    );
  }

  testWidgets('_01_ShouldRenderWithoutCrashing_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.byType(RegisterPage), findsOneWidget);
  });

  testWidgets('_02_ShouldShowCreateAccountHeading_WhenPageLoads',
      (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('Create Account'), findsAtLeastNWidgets(1));
  });

  testWidgets('_03_ShouldShowRequiredFormFields_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    // RegisterPage has 6 TextFields: first name, last name, username, email, password, confirm
    expect(find.byType(TextField), findsAtLeastNWidgets(4));
  });

  testWidgets('_04_ShouldShowCreateAccountSubmitButton_WhenPageLoads',
      (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets(
      '_05_ShouldShowErrorMessage_WhenRegistrationFailsWithValidationError',
      (tester) async {
    when(
      () => mockRegisterUseCase.call(
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
        username: any(named: 'username'),
        email: any(named: 'email'),
        password: any(named: 'password'),
        confirmPassword: any(named: 'confirmPassword'),
      ),
    ).thenAnswer(
      (_) async => const Left(ValidationFailure('Passwords do not match')),
    );

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    // Fill required fields - find all TextFields
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'Alice');
    await tester.enterText(textFields.at(1), 'Martin');
    await tester.enterText(textFields.at(2), 'alicemartin');
    await tester.enterText(textFields.at(3), 'alice@test.com');
    await tester.enterText(textFields.at(4), 'Secret123');
    await tester.enterText(textFields.at(5), 'DifferentPass');

    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('_06_ShouldCallRegisterUseCase_WhenFormIsSubmitted',
      (tester) async {
    when(
      () => mockRegisterUseCase.call(
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
        username: any(named: 'username'),
        email: any(named: 'email'),
        password: any(named: 'password'),
        confirmPassword: any(named: 'confirmPassword'),
      ),
    ).thenAnswer(
      (_) async =>
          const Left(ServerFailure('Duplicate username', statusCode: 400)),
    );

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'Alice');
    await tester.enterText(textFields.at(1), 'Martin');
    await tester.enterText(textFields.at(2), 'alicemartin');
    await tester.enterText(textFields.at(3), 'alice@test.com');
    await tester.enterText(textFields.at(4), 'Secret123');
    await tester.enterText(textFields.at(5), 'Secret123');

    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump();

    verify(
      () => mockRegisterUseCase.call(
        firstName: 'Alice',
        lastName: 'Martin',
        username: 'alicemartin',
        email: 'alice@test.com',
        password: 'Secret123',
        confirmPassword: 'Secret123',
      ),
    ).called(1);
  });

  testWidgets('_07_ShouldShowSignInLink_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('Sign in'), findsOneWidget);
  });
}
