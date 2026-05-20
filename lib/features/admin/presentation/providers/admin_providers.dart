import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/presentation/providers/order_providers.dart';

// Monthly revenue data point
class MonthlyRevenue {
  final String month;
  final double amount;
  final int orderCount;

  const MonthlyRevenue({
    required this.month,
    required this.amount,
    required this.orderCount,
  });
}

// Top selling product data
class TopSellingProductData {
  final String name;
  final String? imageUrl;
  final int totalSold;
  final double totalRevenue;

  const TopSellingProductData({
    required this.name,
    this.imageUrl,
    required this.totalSold,
    required this.totalRevenue,
  });
}

final adminRepositoryProvider = Provider<ProductRepository>((ref) => ProductRepository());

final adminOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.read(orderRepositoryProvider).getAllOrders();
});

final adminLowStockProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  final productRepo = ref.read(productRepositoryProvider);
  return productRepo.getProducts().map((products) =>
    products.where((p) => p.isLowStock).toList()
  );
});

final adminStatsProvider = Provider<AdminStats>((ref) {
  final orders = ref.watch(adminOrdersProvider).valueOrNull ?? [];
  final products = ref.watch(productsProvider).valueOrNull ?? [];
  final lowStock = products.where((p) => p.isLowStock).length;
  final pendingOrders = orders.where((o) => o.status == OrderStatus.pending).length;
  final totalRevenue = orders
    .where((o) => o.status == OrderStatus.delivered)
    .fold<double>(0, (sum, o) => sum + o.total);
  return AdminStats(
    totalOrders: orders.length,
    pendingOrders: pendingOrders,
    totalProducts: products.length,
    lowStockCount: lowStock,
    totalRevenue: totalRevenue,
  );
});

class AdminStats {
  final int totalOrders;
  final int pendingOrders;
  final int totalProducts;
  final int lowStockCount;
  final double totalRevenue;

  const AdminStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.totalProducts,
    required this.lowStockCount,
    required this.totalRevenue,
  });
}

// Monthly revenue analytics
final adminMonthlyRevenueProvider = Provider<List<MonthlyRevenue>>((ref) {
  final orders = ref.watch(adminOrdersProvider).valueOrNull ?? [];
  final delivered = orders.where((o) => o.status == OrderStatus.delivered).toList();

  // Group by month
  final monthNames = [
    'Jan', 'Shk', 'Mar', 'Pri', 'Maj', 'Qer',
    'Kor', 'Gus', 'Sht', 'Tet', 'Nën', 'Dhj'
  ];
  final monthlyMap = <int, MonthlyRevenue>{};

  for (final order in delivered) {
    final monthIndex = order.createdAt.month - 1;
    final current = monthlyMap[monthIndex];
    monthlyMap[monthIndex] = MonthlyRevenue(
      month: monthNames[monthIndex],
      amount: (current?.amount ?? 0) + order.total,
      orderCount: (current?.orderCount ?? 0) + 1,
    );
  }

  // Fill in missing months with zero
  final now = DateTime.now();
  final result = <MonthlyRevenue>[];
  for (int i = 0; i < 12; i++) {
    if (i > now.month - 1) break; // Only show up to current month
    result.add(monthlyMap[i] ?? MonthlyRevenue(month: monthNames[i], amount: 0, orderCount: 0));
  }

  return result;
});

// Top selling products from order data
final adminTopSellingProvider = Provider<List<TopSellingProductData>>((ref) {
  final orders = ref.watch(adminOrdersProvider).valueOrNull ?? [];
  final delivered = orders.where((o) => o.status == OrderStatus.delivered).toList();

  final productSales = <String, TopSellingProductData>{};

  for (final order in delivered) {
    for (final item in order.items) {
      final existing = productSales[item.productId];
      productSales[item.productId] = TopSellingProductData(
        name: item.productName,
        imageUrl: item.imageUrl.isNotEmpty ? item.imageUrl : null,
        totalSold: (existing?.totalSold ?? 0) + item.quantity,
        totalRevenue: (existing?.totalRevenue ?? 0) + item.total,
      );
    }
  }

  final sorted = productSales.values.toList()
    ..sort((a, b) => b.totalSold.compareTo(a.totalSold));

  return sorted.take(5).toList();
});

// Admin product management
final adminProductFormProvider = StateNotifierProvider<AdminProductFormNotifier, AdminProductFormState>((ref) {
  return AdminProductFormNotifier(ref.read(productRepositoryProvider));
});

class AdminProductFormState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final ProductModel? editingProduct;

  const AdminProductFormState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.editingProduct,
  });

  AdminProductFormState copyWith({bool? isLoading, String? error, bool? isSuccess, ProductModel? editingProduct}) =>
    AdminProductFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
      editingProduct: editingProduct ?? this.editingProduct,
    );
}

class AdminProductFormNotifier extends StateNotifier<AdminProductFormState> {
  final ProductRepository _repository;

  AdminProductFormNotifier(this._repository) : super(const AdminProductFormState());

  Future<String?> saveProduct({
    required String name,
    required String description,
    required double price,
    double? discountPrice,
    required String category,
    required String imageUrl,
    required int stock,
    bool isFeatured = false,
    bool isPrescription = false,
    ProductModel? existing,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      if (existing != null) {
        await _repository.updateProduct(existing.id, {
          'name': name, 'description': description, 'price': price,
          if (discountPrice != null) 'discountPrice': discountPrice,
          'category': category, 'imageUrl': imageUrl, 'stock': stock,
          'isFeatured': isFeatured, 'isPrescription': isPrescription,
          'updatedAt': DateTime.now(),
        });
      } else {
        final product = ProductModel(
          id: '',
          name: name,
          description: description,
          price: price,
          discountPrice: discountPrice,
          category: category,
          imageUrl: imageUrl,
          stock: stock,
          isFeatured: isFeatured,
          isPrescription: isPrescription,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _repository.addProduct(product);
      }
      state = state.copyWith(isLoading: false, isSuccess: true);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return e.toString();
    }
  }

  Future<String?> uploadImage(String productId, String filePath) async {
    try {
      final repo = _repository; // Already stored
      final url = await repo.uploadImage(productId, filePath);
      return url;
    } catch (e) {
      state = state.copyWith(error: 'Failed to upload image: $e');
      return null;
    }
  }

  void reset() {
    state = const AdminProductFormState();
  }
}
