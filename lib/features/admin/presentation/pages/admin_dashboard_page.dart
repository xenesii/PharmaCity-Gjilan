import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../../core/utils/csv_export.dart';
import '../providers/admin_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);
    final lowStockAsync = ref.watch(adminLowStockProductsProvider);
    final monthlyRevenue = ref.watch(adminMonthlyRevenueProvider);
    final topSelling = ref.watch(adminTopSellingProvider);
    final adminUnread = ref.watch(adminUnreadCountProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productsProvider);
          ref.invalidate(adminOrdersProvider);
        },
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Admin Premium Header
            SliverAppBar(
              pinned: true,
              expandedHeight: 160,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        top: -30,
                        right: -30,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        left: -20,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, kToolbarHeight + 16, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      AppStrings.adminDashboard,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Menaxho produktet, porositë & më shumë',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                _DateBadge(),
                                const Spacer(),
                                // Notification bell
                                Stack(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                                      onPressed: () => context.push('/admin/notifications'),
                                    ),
                                    if (adminUnread > 0)
                                      Positioned(
                                        right: 4,
                                        top: 4,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: AppColors.accent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            adminUnread > 99 ? '99+' : '$adminUnread',
                                            style: const TextStyle(
                                              color: AppColors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              onSelected: (v) async {
                                if (v == 'refresh') {
                                  ref.invalidate(productsProvider);
                                  ref.invalidate(adminOrdersProvider);
                                } else if (v == 'export') {
                                  final mr = ref.read(adminMonthlyRevenueProvider);
                                  final csv = CsvExport.generateCsv(
                                    ['Muaji', 'Shuma (€)', 'Porosi'],
                                    mr.map((m) => [m.month, m.amount.toStringAsFixed(2), '${m.orderCount}']).toList(),
                                  );
                                  await CsvExport.exportAndNotify(
                                    context, csv, 'pharmacity_te_hyrat.csv', 'Raporti i të hyrave',
                                  );
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'refresh',
                                  child: Row(children: [
                                    Icon(Icons.refresh_rounded, size: 18, color: AppColors.primary),
                                    SizedBox(width: 8),
                                    Text('Rifresko'),
                                  ]),
                                ),
                                const PopupMenuItem(
                                  value: 'export',
                                  child: Row(children: [
                                    Icon(Icons.file_download_rounded, size: 18, color: AppColors.primary),
                                    SizedBox(width: 8),
                                    Text('Eksporto CSV'),
                                  ]),
                                ),
                              ],
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
              ),
            ),

            // Stats Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildListDelegate([
                  _PremiumStatCard(
                    title: AppStrings.totalOrders,
                    value: '${stats.totalOrders}',
                    icon: Icons.receipt_long_rounded,
                    gradientColors: const [Color(0xFF1D9E75), Color(0xFF0F6E56)],
                  ),
                  _PremiumStatCard(
                    title: AppStrings.pendingOrders,
                    value: '${stats.pendingOrders}',
                    icon: Icons.schedule_rounded,
                    gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  _PremiumStatCard(
                    title: AppStrings.totalProducts,
                    value: '${stats.totalProducts}',
                    icon: Icons.inventory_2_rounded,
                    gradientColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  ),
                  _PremiumStatCard(
                    title: AppStrings.lowStockCount,
                    value: '${stats.lowStockCount}',
                    icon: Icons.warning_amber_rounded,
                    gradientColors: const [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                ]),
              ),
            ),

            // Revenue Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF1A2E4A), const Color(0xFF2D4A6E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A2E4A).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.trending_up_rounded, color: AppColors.success, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.totalRevenue,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Nga porositë e dorëzuara',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '\€${stats.totalRevenue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Mini progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: stats.totalOrders > 0
                              ? stats.pendingOrders / stats.totalOrders
                              : 0,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${stats.totalOrders} porosi gjithsej',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${stats.pendingOrders} në pritje',
                            style: TextStyle(
                              color: AppColors.warning.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Monthly Revenue Chart Section
            if (monthlyRevenue.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.info,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'T\u00eb Hyrat Mujore',
                            style: AppTextStyles.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow.withValues(alpha: 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _MonthlyBarChart(data: monthlyRevenue),
                      ),
                    ],
                  ),
                ),
              ),

            // Top Selling Products
            if (topSelling.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Produktet m\u00eb t\u00eb Shitura',
                            style: AppTextStyles.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow.withValues(alpha: 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ...topSelling.asMap().entries.map((entry) => _TopSellingRow(
                              rank: entry.key + 1,
                              name: entry.value.name,
                              imageUrl: entry.value.imageUrl,
                              totalSold: entry.value.totalSold,
                              totalRevenue: entry.value.totalRevenue,
                              maxSold: topSelling.first.totalSold,
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Quick Actions Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      AppStrings.quickActions,
                      style: AppTextStyles.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildListDelegate([
                  _QuickActionTile(
                    icon: Icons.add_circle_outline_rounded,
                    label: 'Shto\nProdukt',
                    onTap: () => context.push('/admin/products'),
                  ),
                  _QuickActionTile(
                    icon: Icons.receipt_long_rounded,
                    label: 'Porosit\u00eb',
                    onTap: () => context.push('/admin/orders'),
                  ),
                  _QuickActionTile(
                    icon: Icons.payments_rounded,
                    label: 'Pagesat',
                    onTap: () => context.push('/admin/payments'),
                  ),
                ]),
              ),
            ),

            // Low Stock Alerts Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      AppStrings.lowStockAlerts,
                      style: AppTextStyles.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: lowStockAsync.when(
                  data: (products) => products.isEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.allWellStocked,
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Të gjitha produktet kanë gjendje të mjaftueshme',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.verified_rounded, color: AppColors.success, size: 24),
                            ],
                          ),
                        )
                      : Column(
                          children: products.map((p) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: p.stock == 0
                                        ? AppColors.error.withValues(alpha: 0.1)
                                        : AppColors.warning.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    p.stock == 0 ? Icons.inventory_rounded : Icons.warning_amber_rounded,
                                    color: p.stock == 0 ? AppColors.error : AppColors.warning,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: AppTextStyles.labelMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: p.stock == 0
                                                  ? AppColors.error.withValues(alpha: 0.1)
                                                  : AppColors.warning.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              p.stock == 0 ? 'PA GJENDJE' : 'Vetëm ${p.stock} copë',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: p.stock == 0 ? AppColors.error : AppColors.warning,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '\€${p.price.toStringAsFixed(2)}',
                                            style: AppTextStyles.priceText.copyWith(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 20),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                  loading: () => const ListShimmer(itemCount: 2),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  final List<MonthlyRevenue> data;

  const _MonthlyBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxAmount = data.fold<double>(0, (max, m) => m.amount > max ? m.amount : max);
    final effectiveMax = maxAmount > 0 ? maxAmount : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\u20AC${data.fold<double>(0, (s, m) => s + m.amount).toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${data.length} muaj',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((m) {
              final fraction = m.amount / effectiveMax;
              final barHeight = math.max(fraction * 100, m.amount > 0 ? 4.0 : 2.0);
              final isCurrent = m == data.last;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (m.amount > 0)
                        Text(
                          '\u20AC${m.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 8,
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Container(
                        width: double.infinity,
                        height: barHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCurrent
                                ? [AppColors.primary, AppColors.primaryDark]
                                : [AppColors.primary.withValues(alpha: 0.4), AppColors.primary.withValues(alpha: 0.2)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.month,
                        style: TextStyle(
                          fontSize: 9,
                          color: isCurrent ? AppColors.primary : AppColors.textHint,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _TopSellingRow extends StatelessWidget {
  final int rank;
  final String name;
  final String? imageUrl;
  final int totalSold;
  final double totalRevenue;
  final int maxSold;

  const _TopSellingRow({
    required this.rank,
    required this.name,
    this.imageUrl,
    required this.totalSold,
    required this.totalRevenue,
    required this.maxSold,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = maxSold > 0 ? totalSold / maxSold : 0.0;
    final rankColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rank <= 3
                  ? rankColors[rank - 1].withValues(alpha: 0.15)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: rank <= 3
                      ? rankColors[rank - 1]
                      : AppColors.textHint,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.textHint),
                    )
                  : const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.textHint),
            ),
          ),
          const SizedBox(width: 10),
          // Name and info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      rank == 1 ? const Color(0xFFFFD700) : rank == 2 ? const Color(0xFFC0C0C0) : rank == 3 ? const Color(0xFFCD7F32) : AppColors.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\u20AC${totalRevenue.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$totalSold cop\u00eb',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      'Jan', 'Shk', 'Mar', 'Pri', 'Maj', 'Qer',
      'Kor', 'Gus', 'Sht', 'Tet', 'Nën', 'Dhj'
    ];
    final days = [
      'Hën', 'Mar', 'Mër', 'Enj', 'Pre', 'Sht', 'Die'
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;

  const _PremiumStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
