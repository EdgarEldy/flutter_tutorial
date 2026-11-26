// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/products_notifier.dart';
import '../widgets/product_card.dart';
import '../../domain/entities/category.dart';

/// Product catalog page. Displays a searchable, filterable grid of products.
/// Search and category filters trigger a network call; pull-to-refresh reloads.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class ProductListPage extends HookConsumerWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productsProvider);
    final notifier = ref.read(productsProvider.notifier);
    final searchController = useTextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    // Debounce search input
    useEffect(() {
      void listener() => notifier.setSearchQuery(searchController.text);
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: CustomScrollView(
          slivers: [
            _AppBar(
              colorScheme: colorScheme,
              searchController: searchController,
            ),
            SliverToBoxAdapter(
              child: _CategoryChips(
                categories: state.categories,
                selectedCategoryId: state.selectedCategoryId,
                onSelected: notifier.setCategory,
                colorScheme: colorScheme,
              ),
            ),
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ),
              )
            else if (state.products.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No products found.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverGrid.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: state.products.length,
                  itemBuilder: (context, index) {
                    final product = state.products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => context.push('/products/${product.id}'),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.colorScheme,
    required this.searchController,
  });

  final ColorScheme colorScheme;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: colorScheme.surface,
      title: const Text('Products'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: colorScheme.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
    required this.colorScheme,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final void Function(int?) onSelected;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedCategoryId == null;
            return _Chip(
              label: 'All',
              isSelected: isSelected,
              onTap: () => onSelected(null),
              colorScheme: colorScheme,
            );
          }
          final category = categories[index - 1];
          final isSelected = selectedCategoryId == category.id;
          return _Chip(
            label: category.name,
            isSelected: isSelected,
            onTap: () => onSelected(isSelected ? null : category.id),
            colorScheme: colorScheme,
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEDE7FF)
              : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
