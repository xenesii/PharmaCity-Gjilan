import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/data/models/category_model.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late final PageController _carouselController;
  int _currentCarouselPage = 0;
  late final AnimationController _greetingAnimController;

  @override
  void initState() {
    super.initState();
    _carouselController = PageController(viewportFraction: 0.92);
    _greetingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _startCarouselAutoPlay();
  }

  void _startCarouselAutoPlay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _carouselController.hasClients) {
        final nextPage = _currentCarouselPage + 1;
        _carouselController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
        _startCarouselAutoPlay();
      }
    });
  }

  @override
  void dispose() {
    _carouselController.dispose();
    _greetingAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featuredAsync = ref.watch(featuredProductsProvider);
    final categories = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(productsProvider);
    final cartItemCount = ref.watch(cartProvider.notifier).itemCount;
    final unreadCount = ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productsProvider);
          ref.invalidate(featuredProductsProvider);
          // ref.invalidate(categoriesProvider);  // Categories are now hardcoded
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Premium SliverAppBar
            SliverAppBar(
              floating: true,
              pinned: false,
              backgroundColor: AppColors.white,
              elevation: 0,
              toolbarHeight: 72,
              title: FadeTransition(
                opacity: _greetingAnimController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.goodMorning,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      ).createShader(bounds),
                      child: Text(
                        AppStrings.appName,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 24),
                      onPressed: () => context.push('/notifications'),
                      color: AppColors.textPrimary,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined, size: 24),
                      onPressed: () => context.push('/cart'),
                      color: AppColors.textPrimary,
                    ),
                    if (cartItemCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            cartItemCount > 99 ? '99+' : '$cartItemCount',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: GestureDetector(
                  onTap: () => context.push('/search'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: AppColors.textHint.withValues(alpha: 0.7), size: 22),
                        const SizedBox(width: 12),
                        Text(
                          AppStrings.searchHint,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textHint.withValues(alpha: 0.7),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppStrings.search,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Banner Carousel
            SliverToBoxAdapter(
              child: SizedBox(
                height: 170,
                child: PageView.builder(
                  controller: _carouselController,
                  onPageChanged: (page) {
                    setState(() => _currentCarouselPage = page % _banners(context).length);
                  },
                  itemCount: _banners(context).length,
                  itemBuilder: (ctx, i) {
                    final bannersList = _banners(context);
                    final banner = bannersList[i % bannersList.length];
                    return GestureDetector(
                      onTap: banner.onTap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.only(
                          left: i == 0 ? 16 : 6,
                          right: i == bannersList.length - 1 ? 16 : 6,
                          top: 4,
                          bottom: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: banner.shadowColor,
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            // Background image
                            Positioned.fill(
                              child: CachedNetworkImage(
                                imageUrl: banner.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  decoration: BoxDecoration(gradient: banner.gradient),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  decoration: BoxDecoration(gradient: banner.gradient),
                                ),
                              ),
                            ),
                            // Gradient overlay for readability
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      banner.gradient.colors[0].withValues(alpha: 0.85),
                                      banner.gradient.colors[1].withValues(alpha: 0.75),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            ),
                            // Decorative icon
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Opacity(
                                opacity: 0.15,
                                child: Icon(banner.icon, size: 120, color: AppColors.white),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    banner.title,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    banner.subtitle,
                                    style: TextStyle(
                                      color: AppColors.white.withValues(alpha: 0.9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        color: AppColors.white.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      banner.action,
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Carousel Dots
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _banners(context).length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _currentCarouselPage % _banners(context).length ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: i == _currentCarouselPage % _banners(context).length
                            ? AppColors.primary
                            : AppColors.borderLight,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppStrings.categories, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                        GestureDetector(
                          onTap: () => context.push('/categories'),
                          child: Text(
                            AppStrings.seeAll,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (ctx, i) => _CategoryCard(
                        category: categories[i],
                        index: i,
                        onTap: () {
                          ref.read(selectedCategoryProvider.notifier).state = categories[i].name;
                          context.push('/products');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Flash Deals Section
            SliverToBoxAdapter(
              child: featuredAsync.when(
                data: (products) => products.isEmpty
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.flash_on, color: AppColors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        AppStrings.flashDeals,
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    ref.read(selectedCategoryProvider.notifier).state = '';
                                    context.push('/products');
                                  },
                                  child: Text(AppStrings.viewAll, style: const TextStyle(color: AppColors.primary)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 240,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: products.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (ctx, i) => _PremiumProductCard(
                                product: products[i],
                                onTap: () => context.push('/products/${products[i].id}'),
                                onFavorite: () => ref.read(favoriteIdsProvider.notifier).toggle(products[i].id),
                                isFavorite: ref.watch(favoriteIdsProvider).contains(products[i].id),
                              ),
                            ),
                          ),
                        ],
                      ),
                loading: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: ShimmerWidget(height: 28, width: 140, borderRadius: 8),
                    ),
                    SizedBox(
                      height: 240,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 4,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, __) => const ProductCardShimmer(),
                      ),
                    ),
                  ],
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // All Products Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [                      Text(
                      AppStrings.allProducts,
                      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/products'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppStrings.viewAll,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Products Grid
            productsAsync.when(
              data: (products) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _PremiumProductCard(
                      product: products[i],
                      onTap: () => context.push('/products/${products[i].id}'),
                      onFavorite: () => ref.read(favoriteIdsProvider.notifier).toggle(products[i].id),
                      isFavorite: ref.watch(favoriteIdsProvider).contains(products[i].id),
                    ),
                    childCount: products.length > 6 ? 6 : products.length,
                  ),
                ),
              ),
              loading: () => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => const ProductCardShimmer(),
                    childCount: 4,
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: AppErrorWidget(
                    message: AppStrings.failedToLoadProducts,
                    onRetry: () => ref.invalidate(productsProvider),
                  ),
                ),
              ),
            ),


            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

// Banner data for carousel
class _BannerData {
  final String title;
  final String subtitle;
  final String action;
  final String imageUrl;
  final IconData icon;
  final LinearGradient gradient;
  final Color shadowColor;
  final VoidCallback onTap;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.imageUrl,
    required this.icon,
    required this.gradient,
    required this.shadowColor,
    required this.onTap,
  });
}

List<_BannerData> _banners(BuildContext context) => [
  _BannerData(
    title: AppStrings.freeDeliveryTitle,
    subtitle: AppStrings.freeDeliverySub,
    action: AppStrings.orderNow,
    imageUrl: 'https://images.unsplash.com/photo-1580674285054-bed31e145f59?w=800&q=80',
    icon: Icons.local_shipping,
    gradient: LinearGradient(
      colors: [Color(0xFF00875A), Color(0xFF006644)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    shadowColor: Color(0x3300875A),
    onTap: () => GoRouter.of(context).push('/products'),
  ),
  _BannerData(
    title: AppStrings.healthTipsTitle,
    subtitle: AppStrings.healthTipsSub,
    action: AppStrings.learnMore,
    imageUrl: 'https://images.unsplash.com/photo-1559757175-5700dde675bc?w=800&q=80',
    icon: Icons.health_and_safety,
    gradient: LinearGradient(
      colors: [Color(0xFF1E40AF), Color(0xFF1D4ED8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    shadowColor: Color(0x331E40AF),
    onTap: () => GoRouter.of(context).push('/products'),
  ),
  _BannerData(
    title: AppStrings.newArrivalsTitle,
    subtitle: AppStrings.newArrivalsSub,
    action: AppStrings.browseNow,
    imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=800&q=80',
    icon: Icons.new_releases,
    gradient: LinearGradient(
      colors: [Color(0xFF6D28D9), Color(0xFF5B21B6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    shadowColor: Color(0x336D28D9),
    onTap: () => GoRouter.of(context).push('/products'),
  ),
];

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final int index;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = category.name;
    final imageUrl = category.imageUrl ?? '';
    final gradient = _categoryGradients[index % _categoryGradients.length];
    final icon = _categoryIcon(name);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors[0].withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Background image
                if (imageUrl.isNotEmpty)
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        decoration: BoxDecoration(gradient: gradient),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        decoration: BoxDecoration(gradient: gradient),
                      ),
                    ),
                  ),
                // Gradient overlay for readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          gradient.colors[0].withValues(alpha: 0.6),
                          gradient.colors[1].withValues(alpha: 0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                // Decorative circle
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: -8,
                  top: -8,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Icon on top
                Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 26),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 100,
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static IconData _categoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('medicines') || lower.contains('medikament')) return Icons.medication_rounded;
    if (lower.contains('vitamins') || lower.contains('supplements')) return Icons.bolt_rounded;
    if (lower.contains('personal') || lower.contains('kujdes')) return Icons.favorite_rounded;
    if (lower.contains('beauty') || lower.contains('skin') || lower.contains('bukur')) return Icons.spa_rounded;
    if (lower.contains('baby') || lower.contains('foshnj')) return Icons.child_care_rounded;
    if (lower.contains('medical') || lower.contains('device')) return Icons.biotech_rounded;
    if (lower.contains('wellness') || lower.contains('mirëqenie')) return Icons.self_improvement_rounded;
    if (lower.contains('first') || lower.contains('aid') || lower.contains('ndihm')) return Icons.healing_rounded;
    if (lower.contains('fitness') || lower.contains('nutrition') || lower.contains('sport')) return Icons.fitness_center_rounded;
    if (lower.contains('offers') || lower.contains('oferta')) return Icons.local_offer_rounded;
    if (lower.contains('care')) return Icons.favorite_rounded;
    return Icons.medication_rounded;
  }
}

// Category gradient palette
const List<LinearGradient> _categoryGradients = [
  LinearGradient(
    colors: [Color(0xFF00A36C), Color(0xFF008F5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8F65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
];

class _PremiumProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final bool isFavorite;

  const _PremiumProductCard({
    required this.product,
    required this.onTap,
    required this.onFavorite,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'product_${product.id}',
                      child: product.imageUrl.isNotEmpty
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
                    ),
                    // Discount badge
                    if (product.hasDiscount)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.gradientStart, AppColors.gradientEnd],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 4,
                              ),
                            ],
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
                    // Out of stock overlay
                    if (!product.inStock)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                AppStrings.outOfStock,
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 4,
                              ),
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
                  ],
                ),
              ),
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.unit ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (product.hasDiscount)
                    Row(
                      children: [
                        Text(
                          '\$${product.discountPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textHint.withValues(alpha: 0.7),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        fontFamily: 'Poppins',
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
