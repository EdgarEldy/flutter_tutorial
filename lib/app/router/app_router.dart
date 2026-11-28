// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// ConsumerWidget is from hooks_riverpod; riverpod_annotation provides @riverpod
import '../../features/auth/domain/entities/auth_state.dart';
import '../../features/auth/presentation/pages/activate_account_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/verify_otp_page.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/cart/presentation/pages/checkout_confirmation_page.dart';
import '../../features/cart/presentation/providers/cart_notifier.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/products/presentation/pages/product_list_page.dart';

part 'app_router.g.dart';

// Routes that do NOT require authentication
const _publicRoutes = [
  '/sign-in',
  '/register',
  '/activate-account',
  '/forgot-password',
  '/verify-otp',
  '/reset-password',
];

/// App router with an auth guard driven by [AuthNotifier].
/// Public routes bypass the guard; all others redirect to /sign-in when
/// the user is unauthenticated. Authenticated shell uses StatefulShellRoute
/// for persistent bottom navigation with 4 tabs.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/sign-in',
    redirect: (context, state) {
      final path = state.uri.path;
      final isPublic = _publicRoutes.any((r) => path.startsWith(r));

      final isAuthenticated = switch (authState) {
        AuthStateAuthenticated() => true,
        _ => false,
      };

      final isInitialOrLoading = switch (authState) {
        AuthStateInitial() || AuthStateLoading() => true,
        _ => false,
      };

      // During initial session check do not redirect yet
      if (isInitialOrLoading) return null;

      // Not authenticated and trying to access a protected route
      if (!isAuthenticated && !isPublic) return '/sign-in';

      // Authenticated and on a public (auth) route
      if (isAuthenticated && isPublic) return '/products';

      return null;
    },
    routes: [
      // Public auth routes
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/activate-account',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return ActivateAccountPage(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyOtpPage(email: email);
        },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final otp = state.uri.queryParameters['otp'] ?? '';
          return ResetPasswordPage(otp: otp);
        },
      ),

      // Protected non-shell route for checkout confirmation
      GoRoute(
        path: '/checkout-confirmation',
        builder: (context, state) => const CheckoutConfirmationPage(),
      ),

      // Protected shell with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (context, state) => const ProductListPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id =
                          int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                      return ProductDetailPage(productId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) => const OrdersPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id =
                          int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                      return OrderDetailPage(orderId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Shell scaffold with a Material 3 NavigationBar at the bottom.
/// Displays a badge on the Cart tab when the cart is non-empty.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class _AppShell extends ConsumerWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final cartItemCount = ref.watch(cartProvider).cart?.itemCount ?? 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: navigationShell.goBranch,
          height: 80,
          backgroundColor: colorScheme.surface,
          indicatorColor: colorScheme.primaryContainer,
          indicatorShape: const StadiumBorder(),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: 'Products',
            ),
            NavigationDestination(
              icon: cartItemCount > 0
                  ? Badge(
                      label: Text('$cartItemCount'),
                      child: const Icon(Icons.shopping_cart_outlined),
                    )
                  : const Icon(Icons.shopping_cart_outlined),
              selectedIcon: cartItemCount > 0
                  ? Badge(
                      label: Text('$cartItemCount'),
                      child: const Icon(Icons.shopping_cart),
                    )
                  : const Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
