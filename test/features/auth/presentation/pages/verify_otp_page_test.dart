// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/auth/data/providers/auth_providers.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/verify_password_reset_otp_use_case.dart';
import 'package:flutter_tutorial/features/auth/presentation/pages/verify_otp_page.dart';

class MockVerifyPasswordResetOtpUseCase extends Mock
    implements VerifyPasswordResetOtpUseCase {}

void main() {
  late MockVerifyPasswordResetOtpUseCase mockUseCase;
  late ProviderContainer container;

  const testEmail = 'user@test.com';

  setUp(() {
    mockUseCase = MockVerifyPasswordResetOtpUseCase();
    container = ProviderContainer(
      overrides: [
        verifyPasswordResetOtpUseCaseProvider.overrideWithValue(mockUseCase),
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
        home: VerifyOtpPage(email: testEmail),
      ),
    );
  }

  testWidgets('_01_ShouldRenderWithoutCrashing_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.byType(VerifyOtpPage), findsOneWidget);
  });

  testWidgets('_02_ShouldShowVerificationCodeHeading_WhenPageLoads',
      (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('Verification Code'), findsOneWidget);
  });

  testWidgets('_03_ShouldShowEmailAddress_WhenEmailIsPassedAsParameter',
      (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    // Email is inside a RichText TextSpan; use predicate to check plain text
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains(testEmail),
      ),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('_04_ShouldShowVerifyCodeButton_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('Verify Code'), findsOneWidget);
  });

  testWidgets('_05_ShouldShowSixOtpInputFields_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.byType(TextField), findsAtLeastNWidgets(6));
  });

  testWidgets('_06_ShouldShowErrorMessage_WhenOtpIsIncorrect', (tester) async {
    when(() => mockUseCase.call(any(), any())).thenAnswer(
      (_) async =>
          const Left(ServerFailure('Invalid OTP', statusCode: 400)),
    );

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    // Enter a 6-digit code
    final textFields = find.byType(TextField);
    for (var i = 0; i < 6; i++) {
      await tester.enterText(textFields.at(i), '0');
      await tester.pump();
    }

    await tester.tap(find.text('Verify Code'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Invalid OTP'), findsOneWidget);
  });

  testWidgets('_07_ShouldCallVerifyOtpWithEmailAndCode_WhenVerifyButtonIsTapped',
      (tester) async {
    // Use a failure response to prevent navigation that requires GoRouter
    when(() => mockUseCase.call(any(), any())).thenAnswer(
      (_) async =>
          const Left(ServerFailure('code invalid', statusCode: 400)),
    );

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    final textFields = find.byType(TextField);
    for (var i = 0; i < 6; i++) {
      await tester.enterText(textFields.at(i), '${i + 1}');
      await tester.pump();
    }

    await tester.tap(find.text('Verify Code'));
    await tester.pump();
    await tester.pump();

    verify(() => mockUseCase.call(testEmail, '123456')).called(1);
  });
}
