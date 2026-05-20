import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../providers/cart_providers.dart';
import '../../data/models/cart_item_model.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(AppStrings.yourCart, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () => _showClearCartDialog(context, cartNotifier),
              child: Text(AppStrings.clearCart, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w500)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.shopping_cart_outlined,
              title: AppStrings.emptyCart,
              subtitle: AppStrings.browseProducts,
            )
          : Column(
              children: [
                // Free delivery progress banner
                if (cartNotifier.subtotal < 20)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientGreen,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping_rounded, color: AppColors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Shtoni \$${(20 - cartNotifier.subtotal).toStringAsFixed(0)} m\u00eb shum\u00eb p\u00ebr transport falas',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Progress bar
                if (cartNotifier.subtotal < 20)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (cartNotifier.subtotal / 20).clamp(0.0, 1.0),
                        backgroundColor: AppColors.borderLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                        minHeight: 6,
                      ),
                    ),
                  ),

                // Cart items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: cart.length,
                    itemBuilder: (ctx, i) => _CartItemCard(
                      item: cart[i],
                      onIncrement: () => cartNotifier.updateQuantity(cart[i].productId, cart[i].quantity + 1),
                      onDecrement: () {
                        if (cart[i].quantity <= 1) {
                          cartNotifier.removeItem(cart[i].productId);
                        } else {
                          cartNotifier.updateQuantity(cart[i].productId, cart[i].quantity - 1);
                        }
                      },
                      onRemove: () => cartNotifier.removeItem(cart[i].productId),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : Container(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SummaryRow(label: AppStrings.subtotal, value: '\$${cartNotifier.subtotal.toStringAsFixed(2)}'),
                  if (cartNotifier.savings > 0)
                    _SummaryRow(
                      label: AppStrings.youSave,
                      value: '-\$${cartNotifier.savings.toStringAsFixed(2)}',
                      color: AppColors.success,
                    ),
                  _SummaryRow(
                    label: AppStrings.deliveryFee,
                    value: cartNotifier.deliveryFee == 0 ? AppStrings.free : '\$${cartNotifier.deliveryFee.toStringAsFixed(2)}',
                    color: cartNotifier.deliveryFee == 0 ? AppColors.success : null,
                  ),
                  const Divider(height: 16),
                  _SummaryRow(
                    label: AppStrings.total,
                    value: '\$${cartNotifier.total.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: '${AppStrings.proceedToCheckout} — \$${cartNotifier.total.toStringAsFixed(2)}',
                    onPressed: () => context.push('/checkout'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _showClearCartDialog(BuildContext context, dynamic cartNotifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.clearCart),
        content: Text(AppStrings.clearCartConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.delete, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      cartNotifier.clear();
    }
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              tag: 'product_img_${item.productId}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 76,
                  height: 76,
                  color: AppColors.surfaceVariant,
                  child: item.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl,
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
                    item.name,
                    style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  PriceDisplay(
                    price: item.price,
                    discountPrice: item.discountPrice,
                    priceStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                    oldPriceStyle: const TextStyle(fontSize: 11, decoration: TextDecoration.lineThrough, color: AppColors.textHint),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _QuantityButton(icon: Icons.remove_rounded, onTap: onDecrement),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      _QuantityButton(icon: Icons.add_rounded, onTap: onIncrement),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.priceText.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? color;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
