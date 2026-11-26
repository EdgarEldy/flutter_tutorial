/// Pure domain entity for a product. No Flutter or data-layer dependencies.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.unitPrice,
    this.description,
    required this.active,
    this.categoryId,
    this.categoryName,
    this.images = const [],
  });

  final int id;
  final String name;
  final double unitPrice;
  final String? description;
  final bool active;
  final int? categoryId;
  final String? categoryName;
  final List<ProductImage> images;

  /// Returns the URL of the primary image, falling back to the first image.
  String? get primaryImageUrl =>
      images.where((i) => i.isPrimary).firstOrNull?.imageUrl ??
      images.firstOrNull?.imageUrl;
}

/// Domain entity for a product image.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class ProductImage {
  const ProductImage({
    required this.id,
    required this.imageUrl,
    this.altText,
    required this.isPrimary,
    required this.displayOrder,
  });

  final int id;
  final String imageUrl;
  final String? altText;
  final bool isPrimary;
  final int displayOrder;
}
