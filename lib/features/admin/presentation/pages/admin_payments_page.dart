import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../orders/data/models/order_model.dart';
import '../providers/admin_providers.dart';

class AdminPaymentsPage extends ConsumerWidget {
  const AdminPaymentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Pagesat', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ordersAsync.when(
        data: (orders) {
          final deliveredOrders = orders.where((o) => o.status == OrderStatus.delivered).toList();
          final pendingPayments = orders.where((o) => o.status == OrderStatus.pending).toList();
          final totalCollected = deliveredOrders.fold<double>(0, (sum, o) => sum + o.total);
          final pendingAmount = pendingPayments.fold<double>(0, (sum, o) => sum + o.total);

          // Group by payment method
          final paymentMethods = <String, double>{};
          for (final order in deliveredOrders) {
            final method = order.paymentMethod.isEmpty ? 'Cash on Delivery' : order.paymentMethod;
            paymentMethods.update(method, (v) => v + order.total, ifAbsent: () => order.total);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats cards
                Row(
                  children: [
                    Expanded(
                      child: _PaymentStatCard(
                        title: 'Te Mbledhura',
                        value: '\$${totalCollected.toStringAsFixed(2)}',
                        icon: Icons.account_balance_wallet_rounded,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PaymentStatCard(
                        title: 'Ne Pritje',
                        value: '\$${pendingAmount.toStringAsFixed(2)}',
                        icon: Icons.schedule_rounded,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _PaymentStatCard(
                        title: 'Transaksione',
                        value: '${deliveredOrders.length}',
                        icon: Icons.receipt_long_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PaymentStatCard(
                        title: 'Ne Pritje',
                        value: '${pendingPayments.length}',
                        icon: Icons.pending_actions_rounded,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Payment methods breakdown
                const Text('Metodat e Pageses', style: AppTextStyles.titleLarge),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: paymentMethods.entries.map((entry) {
                      final total = deliveredOrders.fold<double>(0, (sum, o) => sum + o.total);
                      final percent = total > 0 ? (entry.value / total) * 100 : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _paymentMethodIcon(entry.key),
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _paymentMethodLabel(entry.key),
                                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                Text(
                                  '\$${entry.value.toStringAsFixed(2)}',
                                  style: AppTextStyles.priceText.copyWith(fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percent / 100,
                                backgroundColor: AppColors.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _paymentMethodColor(entry.key),
                                ),
                                minHeight: 6,
                              ),
                            ),
                            Text(
                              '${percent.toStringAsFixed(1)}%',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Recent transactions
                Text('Transaksionet e Fundit', style: AppTextStyles.titleLarge),
                const SizedBox(height: 12),
                ...deliveredOrders.take(10).map((order) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
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
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                        ),
                        title: Text(
                          '#${order.id.substring(0, 8).toUpperCase()}',
                          style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          order.userName ?? order.userEmail ?? AppStrings.unknown,
                          style: AppTextStyles.bodySmall,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${order.total.toStringAsFixed(2)}',
                              style: AppTextStyles.priceText.copyWith(fontSize: 14),
                            ),
                            Text(
                              _paymentMethodLabel(order.paymentMethod),
                              style: AppTextStyles.caption.copyWith(color: AppColors.textHint, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    )),
                if (deliveredOrders.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.payments_outlined, size: 48, color: AppColors.textHint),
                        SizedBox(height: 12),
                        Text('Nuk ka transaksione ende', style: AppTextStyles.titleMedium),
                      ],
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => AppErrorWidget(message: 'Nuk u ngarkuan pagesat: $e'),
      ),
    );
  }

  IconData _paymentMethodIcon(String method) {
    final lower = method.toLowerCase();
    if (lower.contains('cash') || lower.contains('cod')) return Icons.money_rounded;
    if (lower.contains('card')) return Icons.credit_card_rounded;
    return Icons.payments_rounded;
  }

  Color _paymentMethodColor(String method) {
    final lower = method.toLowerCase();
    if (lower.contains('cash') || lower.contains('cod')) return AppColors.success;
    if (lower.contains('card')) return AppColors.info;
    return AppColors.primary;
  }

  String _paymentMethodLabel(String method) {
    if (method.isEmpty || method == 'Cash on Delivery') return 'Cash on Delivery';
    return method;
  }
}

class _PaymentStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _PaymentStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
