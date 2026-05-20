import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../../core/utils/validators.dart';
import '../../presentation/providers/admin_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../products/data/models/product_model.dart';

class AdminProductsPage extends ConsumerWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.adminProducts,
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.add_rounded, color: AppColors.primary),
              onPressed: () => _showProductDialog(context, ref),
            ),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.inventory_2_outlined,
              title: AppStrings.noProductsYet,
              subtitle: AppStrings.addFirstProduct,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: products.length,
            itemBuilder: (ctx, i) => Container(
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: Hero(
                  tag: 'product_img_${products[i].id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 52,
                      height: 52,
                      color: AppColors.surfaceVariant,
                      child: products[i].imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: products[i].imageUrl, fit: BoxFit.cover)
                          : const Icon(Icons.image, color: AppColors.textHint),
                    ),
                  ),
                ),
                title: Text(
                  products[i].name,
                  style: AppTextStyles.labelMedium
                      .copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Row(
                  children: [
                    Text(
                      '\$${products[i].price.toStringAsFixed(2)}',
                      style: AppTextStyles.priceText.copyWith(fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: products[i].inStock
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        AppStrings.stockCount
                            .replaceAll('{count}', '${products[i].stock}'),
                        style: TextStyle(
                          fontSize: 10,
                          color: products[i].inStock
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (v) {
                    if (v == 'edit') {
                      _showProductDialog(context, ref, product: products[i]);
                    } else if (v == 'delete') {
                      _confirmDelete(context, ref, products[i]);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        const Icon(Icons.edit_outlined,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(AppStrings.edit),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        const Icon(Icons.delete_outline,
                            size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(AppStrings.delete,
                            style: const TextStyle(color: AppColors.error)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const ListShimmer(),
        error: (e, _) =>
            AppErrorWidget(message: '${AppStrings.failedToLoadProducts}: $e'),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.deleteProduct),
        content: Text('Jeni të sigurt që doni të fshini "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel,
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(productRepositoryProvider).deleteProduct(product.id);
              Navigator.pop(ctx);
            },
            child: const Text(AppStrings.delete,
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showProductDialog(BuildContext context, WidgetRef ref,
      {ProductModel? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ProductFormSheet(product: product),
    );
  }
}

class _ProductFormSheet extends ConsumerStatefulWidget {
  final ProductModel? product;

  const _ProductFormSheet({this.product});

  @override
  ConsumerState<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends ConsumerState<_ProductFormSheet> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController discountCtrl;
  late TextEditingController stockCtrl;
  late TextEditingController imageUrlCtrl;
  String? _selectedCategory;
  bool isFeatured = false;
  bool isPrescription = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    nameCtrl = TextEditingController(text: p?.name ?? '');
    descCtrl = TextEditingController(text: p?.description ?? '');
    priceCtrl = TextEditingController(text: p?.price.toString() ?? '');
    discountCtrl =
        TextEditingController(text: p?.discountPrice?.toString() ?? '');
    _selectedCategory = p?.category;
    stockCtrl = TextEditingController(text: p?.stock.toString() ?? '');
    imageUrlCtrl = TextEditingController(text: p?.imageUrl ?? '');
    isFeatured = p?.isFeatured ?? false;
    isPrescription = p?.isPrescription ?? false;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    discountCtrl.dispose();
    stockCtrl.dispose();
    imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      imageUrlCtrl.text = file.path;
    }
  }

  Future<void> _save() async {
    if (!formKey.currentState!.validate()) return;

    final notifier = ref.read(adminProductFormProvider.notifier);
    await notifier.saveProduct(
      name: nameCtrl.text.trim(),
      description: descCtrl.text.trim(),
      price: double.parse(priceCtrl.text.trim()),
      discountPrice: discountCtrl.text.trim().isEmpty
          ? null
          : double.parse(discountCtrl.text.trim()),
      category: _selectedCategory ?? '',
      imageUrl: imageUrlCtrl.text.trim(),
      stock: int.parse(stockCtrl.text.trim()),
      isFeatured: isFeatured,
      isPrescription: isPrescription,
      existing: widget.product,
    );

    if (mounted) {
      ref.invalidate(productsProvider);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(adminProductFormProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.product != null
                    ? AppStrings.editProduct
                    : AppStrings.addProduct,
                style: AppTextStyles.headlineMedium
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              AppTextField(
                  controller: nameCtrl,
                  label: AppStrings.productName,
                  validator: (v) =>
                      Validators.required(v, AppStrings.productName)),
              const SizedBox(height: 12),
              AppTextField(
                  controller: descCtrl,
                  label: AppStrings.descriptionLabel,
                  maxLines: 3,
                  validator: (v) =>
                      Validators.required(v, AppStrings.descriptionLabel)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: AppTextField(
                        controller: priceCtrl,
                        label: AppStrings.priceLabel,
                        keyboardType: TextInputType.number,
                        validator: Validators.positiveNumber)),
                const SizedBox(width: 12),
                Expanded(
                    child: AppTextField(
                        controller: discountCtrl,
                        label: AppStrings.discountPriceLabel,
                        keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: _CategoryDropdown(
                    value: _selectedCategory,
                    onChanged: (v) => setState(() => _selectedCategory = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: AppTextField(
                        controller: stockCtrl,
                        label: AppStrings.stockLabel,
                        keyboardType: TextInputType.number,
                        validator: Validators.positiveNumber)),
              ]),
              const SizedBox(height: 12),
              AppTextField(
                controller: imageUrlCtrl,
                label: AppStrings.imageUrlLabel,
                readOnly: false,
                suffixIcon: IconButton(
                    icon: const Icon(Icons.image_rounded,
                        color: AppColors.primary),
                    onPressed: _pickImage),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text(AppStrings.featured,
                        style: TextStyle(fontSize: 13)),
                    value: isFeatured,
                    onChanged: (v) => setState(() => isFeatured = v ?? false),
                    fillColor: WidgetStateProperty.resolveWith((s) =>
                        s.contains(WidgetState.selected)
                            ? AppColors.primary
                            : null),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text(AppStrings.prescription,
                        style: TextStyle(fontSize: 13)),
                    value: isPrescription,
                    onChanged: (v) =>
                        setState(() => isPrescription = v ?? false),
                    fillColor: WidgetStateProperty.resolveWith((s) =>
                        s.contains(WidgetState.selected)
                            ? AppColors.primary
                            : null),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ]),
              if (formState.error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(formState.error!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 13)),
                ),
              const SizedBox(height: 16),
              AppButton(
                label: widget.product != null
                    ? AppStrings.updateProduct
                    : AppStrings.addProduct,
                isLoading: formState.isLoading,
                onPressed: _save,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryDropdown extends ConsumerWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return DropdownButtonFormField<String>(
      initialValue: categories.any((c) => c.name == value) ? value : null,
      decoration: InputDecoration(
        labelText: AppStrings.categoryTitle,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Poppins',
          fontSize: 13,
        ),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: const Icon(Icons.category_rounded, color: AppColors.primary, size: 20),
      ),
      dropdownColor: AppColors.white,
      icon: const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary),
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontFamily: 'Poppins',
      ),
      isExpanded: true,
      borderRadius: BorderRadius.circular(14),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Zgjidh kategorin\u00eb', style: TextStyle(color: AppColors.textHint)),
        ),
        ...categories.map((cat) => DropdownMenuItem<String>(
          value: cat.name,
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.category_rounded, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(cat.name),
            ],
          ),
        )),
      ],
      onChanged: onChanged,
      validator: (v) => v == null ? 'Zgjidhni nj\u00eb kategori' : null,
    );
  }
}

