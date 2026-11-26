// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/auth/data/providers/auth_providers.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/confirm_password_reset_use_case.dart';
import 'package:flutter_tutorial/features/auth/presentation/pages/reset_password_page.dart';

class MockConfirmPasswordResetUseCase extends Mock
    implements ConfirmPasswordResetUseCase {}

void main() {
  late MockConfirmPasswordResetUseCase mockUseCase;
  late ProviderContainer container;

  const testOtp = 'otp-123456';

  setUp(() {
    mockUseCase = MockConfirmPasswordResetUseCase();
    container = ProviderContainer(
      overrides: [
        confirmPasswordResetUseCaseProvider.overrideWithValue(mockUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Widget buildUnderTest() {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: ResetPasswordPage(otp: testOtp),
      ),
    );
  }

  testWidgets('_01_ShouldRenderWithoutCrashing_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.byType(ResetPasswordPage), findsOneWidget);
  });

  testWidgets('_02_ShouldShowNewPasswordHeading_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('New Password'), findsAtLeastNWidgets(1));
  });

  testWidgets('_03_ShouldShowTwoPasswordFields_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.byType(TextField), findsAtLeastNWidgets(2));
  });

  testWidgets('_04_ShouldShowResetPasswordButton_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('Reset Password'), findsOneWidget);
  });

  testWidgets('_05_ShouldShowErrorMessage_WhenResetTokenIsExpired',
      (tester) async {
    when(() => mockUseCase.call(any(), any(), any())).thenAnswer(
      (_) async =>
          const Left(ServerFailure('Token expired', statusCode: 400)),
    );

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.first, 'NewPass123!');
    await tester.enterText(textFields.last, 'NewPass123!');

    await tester.tap(find.text('Reset Password'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Token expired'), findsOneWidget);
  });

  testWidgets(
      '_06_ShouldCallConfirmResetWithOtpAndPasswords_WhenResetButtonIsTapped',
      (tester) async {
    // Use a failure response to prevent navigation that requires GoRouter
    when(() => mockUseCase.call(any(), any(), any())).thenAnswer(
      (_) async =>
          const Left(ServerFailure('some error', statusCode: 400)),
    );

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.first, 'NewPass123!');
    await tester.enterText(textFields.last, 'NewPass123!');

    await tester.tap(find.text('Reset Password'));
    await tester.pump();
    await tester.pump();

    verify(
      () => mockUseCase.call(testOtp, 'NewPass123!', 'NewPass123!'),
    ).called(1);
  });

  testWidgets('_07_ShouldShowStep3IndicatorText_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('Step 3 of 3 - Last step!'), findsOneWidget);
  });
}
