import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../../core/utils/csv_export.dart';
import '../providers/admin_providers.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/presentation/providers/order_providers.dart';

class AdminOrdersPage extends ConsumerWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.manageOrders, style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (v) async {
              if (v == 'export') {
                final orders = ref.read(adminOrdersProvider).valueOrNull ?? [];
                final csv = CsvExport.generateCsv(
                  ['ID', 'Klient', 'Email', 'Status', 'Totali (\u20AC)', 'Metoda e Pages\u00ebs', 'Data'],
                  orders.map((o) => [
                    '#${o.id.substring(0, 8).toUpperCase()}',
                    o.userName ?? '',
                    o.userEmail ?? '',
                    o.statusLabel,
                    o.total.toStringAsFixed(2),
                    o.paymentMethod,
                    CsvExport.formatDate(o.createdAt),
                  ]).toList(),
                );
                await CsvExport.exportAndNotify(
                  context, csv, 'pharmacity_porosite.csv', 'Porosit\u00eb',
                );
              }
            },
            itemBuilder: (_) => [
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
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: AppStrings.noOrders,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: orders.length,
            itemBuilder: (ctx, i) => _AdminOrderCard(order: orders[i]),
          );
        },
        loading: () => const ListShimmer(),
        error: (e, _) => AppErrorWidget(message: '${AppStrings.failedToLoadOrders}: $e'),
      ),
    );
  }
}

class _AdminOrderCard extends ConsumerWidget {
  final OrderModel order;

  const _AdminOrderCard({required this.order});

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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ExpansionTile(
        initiallyExpanded: order.status == OrderStatus.pending,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _statusColor(order.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_statusIcon(order.status), color: _statusColor(order.status), size: 22),
        ),
        title: Row(
          children: [
            Text('#${order.id.substring(0, 8).toUpperCase()}', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('\$${order.total.toStringAsFixed(2)}', style: AppTextStyles.priceText.copyWith(fontSize: 14)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(order.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.statusLabel,
                style: TextStyle(color: _statusColor(order.status), fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 4),
            Text(order.userName ?? order.userEmail ?? AppStrings.unknown, style: AppTextStyles.bodySmall),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(child: Text('${item.productName} x${item.quantity}', style: AppTextStyles.bodyMedium)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('\$${item.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
                if (order.deliveryAddress != null)
                  _InfoRow(icon: Icons.location_on_outlined, text: '${AppStrings.deliverTo}: ${order.deliveryAddress}'),
                if (order.phone != null)
                  _InfoRow(icon: Icons.phone_outlined, text: '${AppStrings.phonePrefix} ${order.phone}'),
                if (order.paymentMethod.isNotEmpty)
                  _InfoRow(icon: Icons.credit_card_outlined, text: '${AppStrings.paymentPrefix} ${order.paymentMethod}'),
                const SizedBox(height: 4),
                Text(order.createdAt.toString().substring(0, 16), style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
                const SizedBox(height: 16),

                // Action buttons based on status
                if (order.status == OrderStatus.pending)
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => ref.read(orderRepositoryProvider).updateOrderStatus(order.id, OrderStatus.confirmed),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.info,
                          side: const BorderSide(color: AppColors.info),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(AppStrings.confirm, style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => ref.read(orderRepositoryProvider).updateOrderStatus(order.id, OrderStatus.cancelled),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(AppStrings.cancel, style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ]),
                if (order.status == OrderStatus.confirmed)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => ref.read(orderRepositoryProvider).updateOrderStatus(order.id, OrderStatus.preparing),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(AppStrings.startPreparing, style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                if (order.status == OrderStatus.preparing)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => ref.read(orderRepositoryProvider).updateOrderStatus(order.id, OrderStatus.outForDelivery),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(AppStrings.markOutForDelivery, style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                if (order.status == OrderStatus.outForDelivery)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => ref.read(orderRepositoryProvider).updateOrderStatus(order.id, OrderStatus.delivered),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(AppStrings.markDelivered, style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textHint),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary))),
        ],
      ),
    );
  }
}
