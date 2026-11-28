// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_tutorial/features/products/domain/entities/product.dart';
import 'package:flutter_tutorial/features/products/presentation/pages/product_detail_page.dart';
import 'package:flutter_tutorial/features/products/presentation/providers/product_detail_notifier.dart';

void main() {
  const productWithImage = Product(
    id: 1,
    name: 'Wireless Headphones',
    unitPrice: 129.50,
    description: 'High quality wireless sound.',
    active: true,
    categoryId: 3,
    categoryName: 'Audio',
    images: [
      ProductImage(
        id: 10,
        imageUrl: 'https://example.com/headphones.jpg',
        altText: 'Headphones',
        isPrimary: true,
        displayOrder: 1,
      ),
    ],
  );

  const productWithoutImage = Product(
    id: 2,
    name: 'Simple Speaker',
    unitPrice: 79.00,
    description: 'Compact room speaker.',
    active: true,
    categoryId: 3,
    categoryName: 'Audio',
  );

  Widget buildUnderTest(AsyncValue<Product> state, {int productId = 1}) {
    final container = ProviderContainer(
      overrides: [productDetailProvider(productId).overrideWithValue(state)],
    );
    addTearDown(container.dispose);
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: ProductDetailPage(productId: productId)),
    );
  }

  testWidgets(
    '_01_ShouldRenderProductImageCategoryNamePriceAndDescription_WhenProductLoads',
    (tester) async {
      await tester.pumpWidget(
        buildUnderTest(const AsyncData(productWithImage)),
      );
      await tester.pump();

      expect(find.byType(CachedNetworkImage), findsOneWidget);
      expect(find.text('Audio'), findsOneWidget);
      expect(find.text('Wireless Headphones'), findsOneWidget);
      expect(find.text('\$129.50'), findsOneWidget);
      expect(find.text('High quality wireless sound.'), findsOneWidget);
    },
  );

  testWidgets('_02_ShouldRenderGradientFallback_WhenProductHasNoImage', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildUnderTest(const AsyncData(productWithoutImage), productId: 2),
    );
    await tester.pump();

    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).gradient is LinearGradient,
      ),
      findsWidgets,
    );
  });

  testWidgets('_03_ShouldRenderQuantitySelectorAndAddToCart_WhenProductLoads', (
    tester,
  ) async {
    await tester.pumpWidget(buildUnderTest(const AsyncData(productWithImage)));
    await tester.pump();

    expect(find.text('Quantity'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Add to Cart'), findsOneWidget);

    final addButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(addButton.onPressed, isNull);
  });

  testWidgets('_04_ShouldIncrementQuantity_WhenAddButtonIsTapped', (
    tester,
  ) async {
    await tester.pumpWidget(buildUnderTest(const AsyncData(productWithImage)));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('_05_ShouldShowLoadingIndicator_WhenProductIsLoading', (
    tester,
  ) async {
    await tester.pumpWidget(buildUnderTest(const AsyncLoading(), productId: 3));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('_06_ShouldShowErrorMessage_WhenProductLoadFails', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildUnderTest(
        AsyncError<Product>('Product not found', StackTrace.current),
        productId: 4,
      ),
    );
    await tester.pump();

    expect(find.text('Product not found'), findsOneWidget);
  });
}
