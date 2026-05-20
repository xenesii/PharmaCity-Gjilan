import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../providers/product_providers.dart';
import '../../data/models/product_model.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final scrollController = ScrollController();
  static const int _pageSize = 8;
  int _displayCount = _pageSize;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore) return;
    final productsAsync = ref.read(productsProvider);
    final products = productsAsync.valueOrNull ?? [];
    if (_displayCount >= products.length) return;

    setState(() => _isLoadingMore = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _displayCount = (_displayCount + _pageSize).clamp(0, products.length);
          _isLoadingMore = false;
        });
      }
    });
  }

  void _resetPagination() {
    setState(() {
      _displayCount = _pageSize;
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final productsAsync = ref.watch(filteredProductsProvider);
    final categories = ref.watch(categoriesProvider);
    final favorites = ref.watch(favoriteIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          selectedCategory ?? AppStrings.allProducts,
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: AppColors.white,
            child: SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _CategoryChip(
                    label: AppStrings.all,
                    isSelected: selectedCategory == null,
                    onTap: () {
                      ref.read(selectedCategoryProvider.notifier).state = null;
                      _resetPagination();
                    },
                  ),
                  ...categories.map((cat) => _CategoryChip(
                    label: cat.name,
                    isSelected: selectedCategory == cat.name,
                    onTap: () {
                      ref.read(selectedCategoryProvider.notifier).state = cat.name;
                      _resetPagination();
                    },
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.inventory_2_outlined,
              title: AppStrings.noProducts,
              subtitle: AppStrings.noProductsSub,
            );
          }

          final displayed = products.take(_displayCount).toList();
          final hasMore = _displayCount < products.length;

          return GridView.builder(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: displayed.length + (hasMore ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i == displayed.length) {
                // Load more item
                return _LoadMoreItem(
                  isLoading: _isLoadingMore,
                  remaining: products.length - _displayCount,
                  onTap: _loadMore,
                );
              }

              return _ProductGridItem(
                product: displayed[i],
                index: i,
                onTap: () => context.push('/products/${displayed[i].id}'),
                onFavorite: () => ref.read(favoriteIdsProvider.notifier).toggle(displayed[i].id),
                isFavorite: favorites.contains(displayed[i].id),
              );
            },
          );
        },
        loading: () => const ListShimmer(isGrid: true),
        error: (e, _) => AppErrorWidget(
          message: '${AppStrings.failedToLoadProducts}: $e',
          onRetry: () => ref.invalidate(productsProvider),
        ),
      ),
    );
  }
}

class _LoadMoreItem extends StatelessWidget {
  final bool isLoading;
  final int remaining;
  final VoidCallback onTap;

  const _LoadMoreItem({
    required this.isLoading,
    required this.remaining,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight, width: 1.5),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.expand_more_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shfaq edhe $remaining',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.gradientGreen : null,
            color: isSelected ? null : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(24),
            border: isSelected ? null : Border.all(color: AppColors.borderLight),
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductGridItem extends StatelessWidget {
  final ProductModel product;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final bool isFavorite;

  const _ProductGridItem({
    required this.product,
    required this.index,
    required this.onTap,
    required this.onFavorite,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Hero(
                  tag: 'product_img_${product.id}',
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      product.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: AppColors.surfaceVariant),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.surfaceVariant,
                                child: const Icon(Icons.image, color: AppColors.textHint),
                              ),
                            )
                          : Container(
                              color: AppColors.surfaceVariant,
                              child: const Icon(Icons.image, color: AppColors.textHint),
                            ),
                      // Discount badge
                      if (product.hasDiscount)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: AppColors.gradientGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${product.discountPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      // Favorite button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: onFavorite,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                              ],
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? AppColors.error : AppColors.textHint,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      // Out of stock overlay
                      if (!product.inStock)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black38,
                            child: Center(
                              child: Text(
                                AppStrings.outOfStock,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Details section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (!product.inStock)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        AppStrings.outOfStock,
                        style: const TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    )
                  else
                    PriceDisplay(
                      price: product.price,
                      discountPrice: product.discountPrice,
                      priceStyle: AppTextStyles.priceText.copyWith(fontSize: 14),
                      oldPriceStyle: const TextStyle(
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textHint,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
