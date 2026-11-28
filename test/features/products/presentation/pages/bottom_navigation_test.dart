// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_tutorial/app/router/app_router.dart';
import 'package:flutter_tutorial/features/auth/domain/entities/auth_state.dart';
import 'package:flutter_tutorial/features/auth/domain/entities/user.dart';
import 'package:flutter_tutorial/features/auth/presentation/providers/auth_notifier.dart';
import 'package:flutter_tutorial/features/products/presentation/providers/products_notifier.dart';
import 'package:flutter_tutorial/features/products/presentation/providers/products_state.dart';

class SpyAuthNotifier extends AuthNotifier {
  SpyAuthNotifier(this.initial);

  final AuthState initial;

  @override
  AuthState build() => initial;
}

class SpyProductsNotifier extends ProductsNotifier {
  SpyProductsNotifier(this.initial);

  final ProductsState initial;

  @override
  ProductsState build() => initial;
}

void main() {
  const fakeUser = User(
    id: 1,
    firstName: 'Alice',
    lastName: 'Martin',
    username: 'alice',
    email: 'alice@test.com',
    enabled: true,
  );

  testWidgets('_01_ShouldExposeFourDestinations_WhenAuthenticatedShellLoads', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(
          () => SpyAuthNotifier(const AuthState.authenticated(fakeUser)),
        ),
        productsProvider.overrideWith(
          () => SpyProductsNotifier(
            const ProductsState(products: [], categories: [], isLoading: false),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, child) {
            return MaterialApp.router(routerConfig: ref.watch(routerProvider));
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Products'), findsAtLeastNWidgets(1));
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    expect(navigationBar.destinations, hasLength(4));
  });
}
