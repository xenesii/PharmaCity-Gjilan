import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../providers/product_providers.dart';
import '../../data/models/product_model.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final searchController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => focusNode.requestFocus());
  }

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final productsAsync = ref.watch(productsProvider);
    final favorites = ref.watch(favoriteIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Premium search bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              color: AppColors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.textPrimary,
                  ),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: searchController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: AppStrings.searchHint,
                          hintStyle: TextStyle(color: AppColors.textHint, fontSize: 15),
                          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textHint, size: 22),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                        onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                      ),
                    ),
                  ),
                  if (query.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () {
                        searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                      color: AppColors.textHint,
                    ),
                ],
              ),
            ),

            // Results
            Expanded(
              child: productsAsync.when(
                data: (products) {
                  final filtered = products.where((p) =>
                    query.isEmpty ||
                    p.name.toLowerCase().contains(query.toLowerCase()) ||
                    p.description.toLowerCase().contains(query.toLowerCase()) ||
                    p.category.toLowerCase().contains(query.toLowerCase())
                  ).toList();

                  if (query.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.search_rounded,
                      title: AppStrings.searchProductsTitle,
                      subtitle: AppStrings.searchSubtitle,
                    );
                  }

                  if (filtered.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.search_off_rounded,
                      title: AppStrings.noResults,
                      subtitle: AppStrings.noResultsSub,
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, left: 4),
                          child: Text(
                            '${filtered.length} ${AppStrings.resultsLabel}',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) => _SearchResultItem(
                              product: filtered[i],
                              isFavorite: favorites.contains(filtered[i].id),
                              onTap: () => context.push('/products/${filtered[i].id}'),
                              onFavorite: () => ref.read(favoriteIdsProvider.notifier).toggle(filtered[i].id),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const ListShimmer(),
                error: (e, _) =>                AppErrorWidget(message: '${AppStrings.error}: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final ProductModel product;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const _SearchResultItem({
    required this.product,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Hero(
                tag: 'product_img_${product.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 76,
                    height: 76,
                    color: AppColors.surfaceVariant,
                    child: product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(Icons.image, color: AppColors.textHint),
                          )
                        : const Icon(Icons.image, color: AppColors.textHint),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        PriceDisplay(
                          price: product.price,
                          discountPrice: product.discountPrice,
                          priceStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                          oldPriceStyle: const TextStyle(fontSize: 11, decoration: TextDecoration.lineThrough, color: AppColors.textHint),
                        ),
                        if (product.isLowStock) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              AppStrings.lowStock,
                              style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: isFavorite ? AppColors.error : AppColors.textHint,
                  ),
                  onPressed: onFavorite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
