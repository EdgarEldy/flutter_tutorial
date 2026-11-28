import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tutorial/features/orders/domain/entities/order.dart';
import 'package:flutter_tutorial/features/orders/presentation/widgets/order_status_badge.dart';

void main() {
  testWidgets(
    'displays exact labels and semantic colors for every status',
    (tester) async {
      const cases = [
        (
          OrderStatus.pending,
          'Processing',
          Color(0xFFEDE7FF),
          Color(0xFF6750A4),
        ),
        (
          OrderStatus.confirmed,
          'Confirmed',
          Color(0xFFDCFCE7),
          Color(0xFF16A34A),
        ),
        (
          OrderStatus.cancelled,
          'Cancelled',
          Color(0xFFFEE2E2),
          Color(0xFFEF4444),
        ),
        (
          OrderStatus.unknown,
          'Unknown',
          Color(0xFFF4EFF4),
          Color(0xFF79747E),
        ),
      ];

      for (final status in cases) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderStatusBadge(status: status.$1),
            ),
          ),
        );
        await tester.pump();

        expect(find.text(status.$2), findsOneWidget);

        final text = tester.widget<Text>(find.text(status.$2));
        expect(text.style?.color, status.$4);

        final badgeContainer = tester.widget<Container>(
          find
              .ancestor(
                of: find.text(status.$2),
                matching: find.byType(Container),
              )
              .first,
        );
        final decoration = badgeContainer.decoration! as BoxDecoration;
        expect(decoration.color, status.$3);
      }
    },
  );
}
