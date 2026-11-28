// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_tutorial/features/products/domain/entities/category.dart';
import 'package:flutter_tutorial/features/products/domain/entities/product.dart';
import 'package:flutter_tutorial/features/products/presentation/pages/product_list_page.dart';
import 'package:flutter_tutorial/features/products/presentation/providers/products_notifier.dart';
import 'package:flutter_tutorial/features/products/presentation/providers/products_state.dart';

class SpyProductsNotifier extends ProductsNotifier {
  SpyProductsNotifier(this.initial);

  final ProductsState initial;

  @override
  ProductsState build() => initial;
}

void main() {
  const categories = [
    Category(id: 1, name: 'Electronics'),
    Category(id: 2, name: 'Clothing'),
  ];

  const products = [
    Product(
      id: 1,
      name: 'Phone',
      unitPrice: 499.99,
      description: 'A smartphone',
      active: true,
      categoryId: 1,
      categoryName: 'Electronics',
    ),
    Product(
      id: 2,
      name: 'Laptop',
      unitPrice: 899.99,
      description: 'A laptop',
      active: true,
      categoryId: 1,
      categoryName: 'Electronics',
    ),
  ];

  Widget buildUnderTest(ProductsState state) {
    final spyNotifier = SpyProductsNotifier(state);
    final container = ProviderContainer(
      overrides: [productsProvider.overrideWith(() => spyNotifier)],
    );
    addTearDown(container.dispose);
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ProductListPage()),
    );
  }

  testWidgets(
    '_01_ShouldRenderCategoriesSearchAndTwoColumnGrid_WhenProductsLoad',
    (tester) async {
      await tester.pumpWidget(
        buildUnderTest(
          const ProductsState(
            products: products,
            categories: categories,
            isLoading: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Products'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search products...'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Electronics'), findsOneWidget);
      expect(find.text('Clothing'), findsOneWidget);

      final sliverGrid = tester.widget<SliverGrid>(find.byType(SliverGrid));
      final delegate =
          sliverGrid.gridDelegate as SliverGridDelegateWithMaxCrossAxisExtent;
      expect(delegate.maxCrossAxisExtent, 220);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Laptop'), findsOneWidget);
    },
  );

  testWidgets('_02_ShouldShowLoadingIndicator_WhenProductsAreLoading', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildUnderTest(const ProductsState(isLoading: true)),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('_03_ShouldShowErrorMessage_WhenProductLoadFails', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildUnderTest(
        const ProductsState(
          isLoading: false,
          errorMessage: 'Unable to load products',
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Unable to load products'), findsOneWidget);
  });

  testWidgets('_04_ShouldShowEmptyState_WhenNoProductsMatch', (tester) async {
    await tester.pumpWidget(
      buildUnderTest(
        const ProductsState(
          products: [],
          categories: categories,
          isLoading: false,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('No products found.'), findsOneWidget);
    expect(find.byType(SliverGrid), findsNothing);
  });
}
