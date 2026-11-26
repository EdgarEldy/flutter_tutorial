// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../domain/entities/order.dart';

/// Colored pill badge that displays the human-readable label for an [OrderStatus].
/// Uses semantic status colors as hardcoded exceptions to the no-hardcoded-colors rule.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-26
/// Project: flutter_tutorial
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      OrderStatus.pending => (
          const Color(0xFFEDE7FF),
          const Color(0xFF6750A4),
          'Processing',
        ),
      OrderStatus.confirmed => (
          const Color(0xFFDCFCE7),
          const Color(0xFF16A34A),
          'Confirmed',
        ),
      OrderStatus.cancelled => (
          const Color(0xFFFEE2E2),
          const Color(0xFFEF4444),
          'Cancelled',
        ),
      OrderStatus.unknown => (
          const Color(0xFFF4EFF4),
          const Color(0xFF79747E),
          'Unknown',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
