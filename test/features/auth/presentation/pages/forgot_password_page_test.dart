// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/auth/data/providers/auth_providers.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/send_password_reset_otp_use_case.dart';
import 'package:flutter_tutorial/features/auth/presentation/pages/forgot_password_page.dart';

class MockSendPasswordResetOtpUseCase extends Mock
    implements SendPasswordResetOtpUseCase {}

void main() {
  late MockSendPasswordResetOtpUseCase mockUseCase;
  late ProviderContainer container;

  setUp(() {
    mockUseCase = MockSendPasswordResetOtpUseCase();
    container = ProviderContainer(
      overrides: [
        sendPasswordResetOtpUseCaseProvider.overrideWithValue(mockUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Widget buildUnderTest() {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ForgotPasswordPage()),
    );
  }

  testWidgets('_01_ShouldRenderWithoutCrashing_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.byType(ForgotPasswordPage), findsOneWidget);
  });

  testWidgets('_02_ShouldShowForgotPasswordHeading_WhenPageLoads',
      (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('Forgot Password'), findsOneWidget);
  });

  testWidgets('_03_ShouldShowEmailTextField_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('_04_ShouldShowSendCodeButton_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('Send Code'), findsOneWidget);
  });

  testWidgets('_05_ShouldShowError_WhenEmailIsNotRegistered', (tester) async {
    when(() => mockUseCase.call(any())).thenAnswer(
      (_) async =>
          const Left(ServerFailure('Email not found', statusCode: 404)),
    );

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'unknown@test.com');
    await tester.tap(find.text('Send Code'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Email not found'), findsOneWidget);
  });

  testWidgets('_06_ShouldCallSendOtpWithEnteredEmail_WhenSendCodeIsTapped',
      (tester) async {
    // Use a failure response to prevent navigation that requires GoRouter
    when(() => mockUseCase.call(any())).thenAnswer(
      (_) async =>
          const Left(ServerFailure('some error', statusCode: 400)),
    );

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'user@test.com');
    await tester.tap(find.text('Send Code'));
    await tester.pump();
    await tester.pump();

    verify(() => mockUseCase.call('user@test.com')).called(1);
  });

  testWidgets('_07_ShouldShowStepIndicator_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    // The page shows "Reset in 3 steps" text in hero
    expect(find.text('Reset in 3 steps'), findsOneWidget);
  });

  testWidgets('_08_ShouldShowBackToSignInLink_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('Back to sign in'), findsOneWidget);
  });
}
