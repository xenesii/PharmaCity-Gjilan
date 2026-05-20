import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../products/data/models/category_model.dart';

final categoryProductCountsProvider = Provider<Map<String, int>>((ref) {
  final products = ref.watch(productsProvider).valueOrNull ?? [];
  final counts = <String, int>{};
  for (final p in products) {
    counts.update(p.category, (v) => v + 1, ifAbsent: () => 1);
  }
  return counts;
});

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  final searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final productCounts = ref.watch(categoryProductCountsProvider);

    final filtered = _searchQuery.isEmpty
        ? categories
        : categories.where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header with search
          SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: AppColors.white,
            elevation: 0,
            toolbarHeight: 120,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.categories,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${filtered.length} nga ${categories.length} kategori',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 24),
                      onPressed: () => Navigator.pop(context),
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search field
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Kërko kategori...',
                      hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded, color: AppColors.textHint, size: 22),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
              ],
            ),
          ),

          // Categories Grid
          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: EmptyStateWidget(
                  icon: _searchQuery.isEmpty ? Icons.category_rounded : Icons.search_off_rounded,
                  title: _searchQuery.isEmpty ? 'Nuk ka kategori' : 'Nuk u gjetën kategori',
                  subtitle: _searchQuery.isEmpty
                      ? 'Asnjë kategori nuk u gjet'
                      : 'Provo me një term tjetër kërkimi',
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _CategoryGridCard(
                    category: filtered[i],
                    productCount: productCounts[filtered[i].name] ?? 0,
                    index: categories.indexOf(filtered[i]),
                    onTap: () {
                      ref.read(selectedCategoryProvider.notifier).state = filtered[i].name;
                      context.push('/products');
                    },
                  ),
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final List<LinearGradient> _categoryGridGradients = [
  LinearGradient(
    colors: [const Color(0xFF00A36C), const Color(0xFF008F5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [const Color(0xFF7C3AED), const Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [const Color(0xFFFF6B35), const Color(0xFFFF8F65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [const Color(0xFF1E40AF), const Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [const Color(0xFFEC4899), const Color(0xFFF472B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [const Color(0xFF059669), const Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [const Color(0xFFD97706), const Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [const Color(0xFFDC2626), const Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
];

IconData _categoryGridIcon(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('medicines') || lower.contains('medikament')) return Icons.medication_rounded;
  if (lower.contains('vitamins') || lower.contains('supplements') || lower.contains('vitamina')) return Icons.bolt_rounded;
  if (lower.contains('personal') || lower.contains('kujdes')) return Icons.favorite_rounded;
  if (lower.contains('beauty') || lower.contains('skin') || lower.contains('bukur')) return Icons.spa_rounded;
  if (lower.contains('baby') || lower.contains('foshnj')) return Icons.child_care_rounded;
  if (lower.contains('medical') || lower.contains('device') || lower.contains('pajisje')) return Icons.biotech_rounded;
  if (lower.contains('wellness') || lower.contains('mirëqenie')) return Icons.self_improvement_rounded;
  if (lower.contains('first') || lower.contains('aid') || lower.contains('ndihm')) return Icons.healing_rounded;
  if (lower.contains('fitness') || lower.contains('nutrition') || lower.contains('sport')) return Icons.fitness_center_rounded;
  if (lower.contains('offers') || lower.contains('oferta')) return Icons.local_offer_rounded;
  return Icons.category_rounded;
}

class _CategoryGridCard extends StatelessWidget {
  final CategoryModel category;
  final int productCount;
  final int index;
  final VoidCallback onTap;

  const _CategoryGridCard({
    required this.category,
    required this.productCount,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = _categoryGridGradients[index % _categoryGridGradients.length];
    final icon = _categoryGridIcon(category.name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors[0].withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background image
            if (category.imageUrl != null && category.imageUrl!.isNotEmpty)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: category.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    decoration: BoxDecoration(gradient: gradient),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    decoration: BoxDecoration(gradient: gradient),
                  ),
                ),
              ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradient.colors[0].withValues(alpha: 0.7),
                      gradient.colors[1].withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -20,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 26),
                  ),
                  const Spacer(),
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_rounded, size: 13, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        '$productCount produkte',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
