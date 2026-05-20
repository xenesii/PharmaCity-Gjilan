import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/order_providers.dart';
import '../../data/models/order_model.dart';

class OrderConfirmationPage extends ConsumerWidget {
  final String orderId;

  const OrderConfirmationPage({required this.orderId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderByIdProvider(orderId));

    return orderAsync.when(
      data: (order) => _buildContent(context, order),
      loading: () => const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, size: 44, color: AppColors.success),
                  ),
                  const SizedBox(height: 20),
                  const Text(AppStrings.orderPlaced, style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.orderPlacedSubtitle,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: AppStrings.viewMyOrders,
                      onPressed: () => context.go('/orders'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go('/home'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(AppStrings.continueShopping, style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, OrderModel? order) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      gradient: AppColors.gradientGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary,
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check_rounded, size: 50, color: AppColors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    AppStrings.orderPlaced,
                    style: AppTextStyles.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.orderPlacedSubtitle,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Order details card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Order #${orderId.substring(0, 8).toUpperCase()}',
                              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.orderNotify,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                          textAlign: TextAlign.center,
                        ),
                        if (order != null) ...[
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppStrings.totalPaid, style: AppTextStyles.bodyMedium),
                              Text(
                                '\$${order.total.toStringAsFixed(2)}',
                                style: AppTextStyles.displayMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppStrings.paymentMethodLabel, style: AppTextStyles.bodySmall),
                              Text(order.paymentMethod, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500)),
                            ],
                          ),
                          if (order.deliveryAddress != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(AppStrings.deliveringTo, style: AppTextStyles.bodySmall),
                                  Flexible(
                                    child: Text(
                                      order.deliveryAddress!,
                                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: AppStrings.viewMyOrders,
                      onPressed: () => context.go('/orders'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go('/home'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(AppStrings.continueShopping, style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
