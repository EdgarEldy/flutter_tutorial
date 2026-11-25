// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/auth/data/providers/auth_providers.dart';
import 'package:flutter_tutorial/features/auth/domain/entities/user.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/activate_account_use_case.dart';
import 'package:flutter_tutorial/features/auth/presentation/pages/activate_account_page.dart';

class MockActivateAccountUseCase extends Mock implements ActivateAccountUseCase {}

const fakeUser = User(
  id: 1,
  firstName: 'Alice',
  lastName: 'Martin',
  username: 'alicemartin',
  email: 'alice@test.com',
  enabled: true,
);

void main() {
  late MockActivateAccountUseCase mockUseCase;
  late ProviderContainer container;

  const testEmail = 'alice@test.com';

  setUp(() {
    mockUseCase = MockActivateAccountUseCase();
    container = ProviderContainer(
      overrides: [
        activateAccountUseCaseProvider.overrideWithValue(mockUseCase),
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
        home: ActivateAccountPage(email: testEmail),
      ),
    );
  }

  testWidgets('_01_ShouldRenderWithoutCrashing_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.byType(ActivateAccountPage), findsOneWidget);
  });

  testWidgets('_02_ShouldShowActivateAccountHeading_WhenPageLoads',
      (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('Activate Account'), findsAtLeastNWidgets(1));
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

  testWidgets('_04_ShouldShowActivateAccountSubmitButton_WhenPageLoads',
      (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('_05_ShouldShowSixOtpInputFields_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    // OtpInputField creates 6 TextField widgets (one per digit)
    expect(find.byType(TextField), findsAtLeastNWidgets(6));
  });

  testWidgets(
      '_06_ShouldShowErrorMessage_WhenActivationCodeIsInvalid',
      (tester) async {
    when(() => mockUseCase.call(any(), any())).thenAnswer(
      (_) async => const Left(
        ServerFailure('Activation code expired', statusCode: 400),
      ),
    );

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    // Enter a 6-digit code into each OTP box
    final textFields = find.byType(TextField);
    for (var i = 0; i < 6; i++) {
      await tester.enterText(textFields.at(i), '${i + 1}');
      await tester.pump();
    }

    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump();

    expect(find.text('Activation code expired'), findsOneWidget);
  });

  testWidgets(
      '_07_ShouldCallUseCaseWithEmailAndOtpCode_WhenActivateButtonIsTapped',
      (tester) async {
    // Use a failure response to prevent navigation that requires GoRouter
    when(() => mockUseCase.call(any(), any())).thenAnswer(
      (_) async =>
          const Left(ServerFailure('code invalid', statusCode: 400)),
    );

    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    // Enter '1','2','3','4','5','6' into the 6 OTP fields
    final textFields = find.byType(TextField);
    for (var i = 0; i < 6; i++) {
      await tester.enterText(textFields.at(i), '${i + 1}');
      await tester.pump();
    }

    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump();

    verify(() => mockUseCase.call(testEmail, '123456')).called(1);
  });
}
