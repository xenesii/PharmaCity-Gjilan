import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../providers/product_providers.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/providers/cart_providers.dart';

class ProductDetailPage extends ConsumerWidget {
  final String productId;

  const ProductDetailPage({required this.productId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(selectedProductProvider(productId));

    return productAsync.when(
      data: (product) {
        if (product == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(backgroundColor: AppColors.white, foregroundColor: AppColors.textPrimary, elevation: 0),
            body: const EmptyStateWidget(
              icon: Icons.inventory_2_outlined,
              title: AppStrings.productNotFound,
            ),
          );
        }

        final isFavorite = ref.watch(favoriteIdsProvider).contains(product.id);

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'product_img_${product.id}',
                    child: product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: AppColors.surfaceVariant),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.surfaceVariant,
                              child: const Icon(Icons.image, size: 48, color: AppColors.textHint),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceVariant,
                            child: const Icon(Icons.image, size: 48, color: AppColors.textHint),
                          ),
                  ),
                ),
                actions: [
                  if (product.hasDiscount)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '-${product.discountPercent.toStringAsFixed(0)}%',
                          style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppColors.error : AppColors.textPrimary,
                        size: 22,
                      ),
                      onPressed: () => ref.read(favoriteIdsProvider.notifier).toggle(product.id),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(product.name, style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),

                      // Price and rating row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          PriceDisplay(
                            price: product.price,
                            discountPrice: product.discountPrice,
                            priceStyle: AppTextStyles.displayMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                            oldPriceStyle: AppTextStyles.titleLarge.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textHint,
                            ),
                          ),
                          const Spacer(),
                          if (product.rating != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 18, color: AppColors.warning),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${product.rating} (${product.reviewCount ?? 0})',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stock status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: product.inStock
                              ? (product.isLowStock
                                  ? AppColors.warning.withValues(alpha: 0.08)
                                  : AppColors.success.withValues(alpha: 0.08))
                              : AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: product.inStock
                                ? (product.isLowStock ? AppColors.warning : AppColors.success)
                                : AppColors.error,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              product.inStock
                                  ? (product.isLowStock ? Icons.warning_amber_rounded : Icons.check_circle_rounded)
                                  : Icons.cancel_rounded,
                              size: 18,
                              color: product.inStock
                                  ? (product.isLowStock ? AppColors.warning : AppColors.success)
                                  : AppColors.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              product.inStock
                                  ? (product.isLowStock ? AppStrings.lowStockCount.replaceAll('{count}', product.stock.toString()) : AppStrings.inStock)
                                  : AppStrings.outOfStock,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: product.inStock
                                    ? (product.isLowStock ? AppColors.warning : AppColors.success)
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Premium description section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Text(AppStrings.description, style: AppTextStyles.titleMedium),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              product.description,
                              style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                            ),
                            if (product.category.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Text(AppStrings.categoryLabel, style: AppTextStyles.labelMedium),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySurface,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      product.category,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Prescription warning
                      if (product.isPrescription)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      AppStrings.prescriptionRequired,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppStrings.prescriptionNote,
                                      style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
            decoration: const BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: product.inStock
                ? AppButton(
                    label: '${AppStrings.addToCart} — \$${product.effectivePrice.toStringAsFixed(2)}',
                    onPressed: () {
                      ref.read(cartProvider.notifier).addItem(
                        CartItemModel(
                          productId: product.id,
                          name: product.name,
                          imageUrl: product.imageUrl,
                          price: product.price,
                          discountPrice: product.discountPrice,
                          unit: product.unit,
                          maxStock: product.stock,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.addedToCart),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          backgroundColor: AppColors.primary,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  )
                : Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                    ),                      child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel_rounded, color: AppColors.error, size: 18),
                        SizedBox(width: 8),
                        Text(
                          AppStrings.outOfStock,
                          style: TextStyle(color: AppColors.error, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(backgroundColor: AppColors.white, elevation: 0),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(backgroundColor: AppColors.white, elevation: 0, foregroundColor: AppColors.textPrimary),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.textHint),
                const SizedBox(height: 16),
                Text(AppStrings.failedToLoadProduct, style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                Text('$e', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
