import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../orders/data/models/order_model.dart';

class OrderHistoryPage extends ConsumerWidget {
  const OrderHistoryPage({super.key});

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.preparing:
        return AppColors.primary;
      case OrderStatus.outForDelivery:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _statusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule_rounded;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.preparing:
        return Icons.inventory_2_rounded;
      case OrderStatus.outForDelivery:
        return Icons.local_shipping_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(userOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.orderHistory, style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: AppStrings.noOrders,
              subtitle: AppStrings.noOrdersSubtitle,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: orders.length,
            itemBuilder: (ctx, i) => GestureDetector(
              onTap: () => context.push('/orders/${orders[i].id}/confirmation'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _statusColor(orders[i].status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _statusIcon(orders[i].status),
                            size: 20,
                            color: _statusColor(orders[i].status),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(orders[i].status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            orders[i].statusLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _statusColor(orders[i].status),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${orders[i].total.toStringAsFixed(2)}',
                          style: AppTextStyles.priceText.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '#${orders[i].id.substring(0, 8).toUpperCase()}',
                          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${orders[i].items.length} ${AppStrings.itemsCount}',
                          style: AppTextStyles.bodySmall,
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textHint),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      orders[i].createdAt.toString().substring(0, 16),
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const ListShimmer(),
        error: (e, _) =>        AppErrorWidget(message: '${AppStrings.failedToLoadOrders}: $e'),
      ),
    );
  }
}
