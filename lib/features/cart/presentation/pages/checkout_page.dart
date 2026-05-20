import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../../core/utils/validators.dart';
import '../providers/cart_providers.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/data/repositories/order_repository.dart';
import '../../../notifications/data/models/notification_model.dart';
import 'package:uuid/uuid.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final phoneController = TextEditingController();
  final noteController = TextEditingController();
  // Card payment fields
  final cardNumberController = TextEditingController();
  final cardHolderController = TextEditingController();
  final expiryDateController = TextEditingController();
  final cvvController = TextEditingController();
  final cardFormKey = GlobalKey<FormState>();
  
  String paymentMethod = 'Cash on Delivery';
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    addressController.dispose();
    cityController.dispose();
    phoneController.dispose();
    noteController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!formKey.currentState!.validate()) return;

    // If card payment is selected, show card details dialog
    if (paymentMethod == AppStrings.cardPayment) {
      final cardData = await _showCardPaymentDialog();
      if (cardData == null) return; // User cancelled
    }

    final cartNotifier = ref.read(cartProvider.notifier);
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      context.go('/auth/login');
      return;
    }

    final orderCreator = ref.read(orderCreationProvider.notifier);
    final items = cart
        .map((item) => OrderItem(
              productId: item.productId,
              productName: item.name,
              imageUrl: item.imageUrl,
              price: item.effectivePrice,
              quantity: item.quantity,
              unit: item.unit,
            ))
        .toList();

    if (!mounted) return;
    final orderId = await orderCreator.createOrder(
      userId: user.uid,
      userEmail: user.email ?? '',
      userName: user.displayName ?? '',
      items: items,
      subtotal: cartNotifier.subtotal,
      deliveryFee: cartNotifier.deliveryFee,
      deliveryAddress: addressController.text.trim(),
      city: cityController.text.trim(),
      phone: phoneController.text.trim(),
      deliveryNote: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
      paymentMethod: paymentMethod,
    );

    if (orderId != null) {
      // If card payment, create payment record for admin
      if (paymentMethod == AppStrings.cardPayment) {
        await _createPaymentRecord(orderId, cartNotifier.total);
      }
      cartNotifier.clear();
      if (context.mounted) {
        context.go('/orders/$orderId/confirmation');
      }
    }
  }

  Future<Map<String, dynamic>?> _showCardPaymentDialog() async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.credit_card, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Pagesa me Kartë', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: cardFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Card number field
                  AppTextField(
                    controller: cardNumberController,
                    label: 'Numri i Kartës',
                    hintText: '1234 5678 9012 3456',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Numri i kartës është i detyrueshëm';
                      if (v.replaceAll(' ', '').length != 16) return 'Numri i kartës duhet të jetë 16 shifra';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // Card holder name
                  AppTextField(
                    controller: cardHolderController,
                    label: 'Emri i Mbajtësit',
                    hintText: 'EMRI MBIEMRI',
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Emri i mbajtësit është i detyrueshëm';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Expiry date
                      Expanded(
                        child: AppTextField(
                          controller: expiryDateController,
                          label: 'Data e Skadimit',
                          hintText: 'MM/YY',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Data e skadimit është e detyrueshme';
                            if (!RegExp(r'^(0[1-9]|1[0-2])\/[0-9]{2}$').hasMatch(v)) {
                              return 'Formati: MM/YY';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // CVV
                      Expanded(
                        child: AppTextField(
                          controller: cvvController,
                          label: 'CVV',
                          hintText: '123',
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'CVV është i detyrueshëm';
                            if (v.length != 3) return 'CVV duhet të jetë 3 shifra';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Secure payment info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline, color: AppColors.success, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pagesa është e sigurt dhe e enkriptuar',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Anulo', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (cardFormKey.currentState!.validate()) {
                  Navigator.of(context).pop({
                    'cardNumber': cardNumberController.text,
                    'cardHolder': cardHolderController.text,
                    'expiryDate': expiryDateController.text,
                    'cvv': cvvController.text,
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Konfirmo Pagesën', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createPaymentRecord(String orderId, double amount) async {
    try {
      final paymentRef = FirebaseFirestore.instance.collection('payments').doc();
      await paymentRef.set({
        'id': paymentRef.id,
        'orderId': orderId,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'amount': amount,
        'status': 'completed',
        'paymentMethod': 'card',
        'cardLast4': cardNumberController.text.length >= 4 
            ? cardNumberController.text.substring(cardNumberController.text.length - 4)
            : '****',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create notification for admin about payment
      final notificationRef = FirebaseFirestore.instance.collection('notifications').doc();
      await notificationRef.set({
        'id': notificationRef.id,
        'userId': 'admin',
        'orderId': orderId,
        'type': 'payment_received',
        'title': 'Pagesë e re me kartë',
        'body': 'U pranua pagesë me kartë prej \$${amount.toStringAsFixed(2)} për porosinë #${orderId.substring(0, 8).toUpperCase()}',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log error but don't fail the order
      debugPrint('Error creating payment record: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final orderCreationState = ref.watch(orderCreationProvider);
    final isLoading = orderCreationState.isLoading;

    if (cart.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(AppStrings.checkout),
          backgroundColor: AppColors.white,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
        ),
        body: const EmptyStateWidget(
          icon: Icons.shopping_cart_outlined,
          title: AppStrings.emptyCart,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(AppStrings.checkout, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery section header
                _SectionHeader(title: AppStrings.deliveryAddress, icon: Icons.location_on_rounded),
                const SizedBox(height: 12),
                Container(
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
                    children: [
                      AppTextField(
                        controller: addressController,
                        label: AppStrings.streetAddress,
                        validator: Validators.address,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: cityController,
                        label: AppStrings.city,
                        validator: (v) => Validators.required(v, 'City'),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: phoneController,
                        label: AppStrings.phone,
                        keyboardType: TextInputType.phone,
                        validator: Validators.phone,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: noteController,
                        label: AppStrings.deliveryNote,
                        hintText: AppStrings.deliveryNoteHint,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Payment section
                _SectionHeader(title: AppStrings.paymentMethod, icon: Icons.credit_card_rounded),
                const SizedBox(height: 12),
                _PaymentOption(
                  title: AppStrings.cashOnDelivery,
                  subtitle: AppStrings.codSubtitle,
                  icon: Icons.money_rounded,
                  isSelected: paymentMethod == AppStrings.cashOnDelivery,
                  onTap: () => setState(() => paymentMethod = 'Cash on Delivery'),
                ),
                const SizedBox(height: 8),
                _PaymentOption(
                  title: AppStrings.cardPayment,
                  subtitle: AppStrings.cardSubtitle,
                  icon: Icons.credit_card_rounded,
                  isSelected: paymentMethod == AppStrings.cardPayment,
                  onTap: () async {
                    // Show card payment dialog immediately when selecting card payment
                    final cardData = await _showCardPaymentDialog();
                    if (cardData != null) {
                      // User confirmed card details
                      setState(() => paymentMethod = 'Card Payment');
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Order summary
                _SectionHeader(title: AppStrings.orderSummary, icon: Icons.receipt_long_rounded),
                const SizedBox(height: 12),
                Container(
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
                    children: [
                      ...cart.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.name} x${item.quantity}',
                                    style: AppTextStyles.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '\$${item.totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const Divider(height: 20),
                      _SummaryRow(label: AppStrings.subtotal, value: '\$${cartNotifier.subtotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 4),
                      _SummaryRow(
                        label: AppStrings.deliveryFee,
                        value: cartNotifier.deliveryFee == 0 ? AppStrings.free : '\$${cartNotifier.deliveryFee.toStringAsFixed(2)}',
                        color: cartNotifier.deliveryFee == 0 ? AppColors.success : null,
                      ),
                      const Divider(height: 12),
                      _SummaryRow(
                        label: AppStrings.total,
                        value: '\$${cartNotifier.total.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Error
                if (orderCreationState.error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${orderCreationState.error}',
                            style: const TextStyle(color: AppColors.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                AppButton(
                  label: '${AppStrings.placeOrder} — \$${cartNotifier.total.toStringAsFixed(2)}',
                  isLoading: isLoading,
                  onPressed: _placeOrder,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))]
              : [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primarySurface : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textHint, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: AppColors.white, size: 14)
                  : null,
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
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
