import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) => OrderRepository());

final userOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);
  return ref.read(orderRepositoryProvider).getUserOrders(userId);
});

final allOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.read(orderRepositoryProvider).getAllOrders();
});

final pendingOrdersCountProvider = StreamProvider<int>((ref) {
  return ref.read(orderRepositoryProvider).getPendingOrdersCount();
});

final allOrdersCountProvider = StreamProvider<int>((ref) {
  return ref.read(orderRepositoryProvider).getAllOrdersCount();
});

final orderByIdProvider = FutureProvider.family<OrderModel?, String>((ref, id) async {
  return ref.read(orderRepositoryProvider).getOrderById(id);
});

final orderCreationLoadingProvider = StateProvider<bool>((ref) => false);
final orderCreationErrorProvider = StateProvider<String?>((ref) => null);

class OrderCreationNotifier extends StateNotifier<AsyncValue<void>> {
  final OrderRepository _repository;

  OrderCreationNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<String?> createOrder({
    required String userId,
    required String userEmail,
    required String userName,
    required List<OrderItem> items,
    required double subtotal,
    double deliveryFee = 2.50,
    String? deliveryAddress,
    String? city,
    String? phone,
    String? deliveryNote,
    String paymentMethod = 'Cash on Delivery',
  }) async {
    state = const AsyncValue.loading();
    try {
      final orderId = const Uuid().v4();
      final order = OrderModel(
        id: orderId,
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        items: items,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: subtotal + deliveryFee,
        deliveryAddress: deliveryAddress,
        city: city,
        phone: phone,
        deliveryNote: deliveryNote,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.createOrder(order);
      state = const AsyncValue.data(null);
      return orderId;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }
}

final orderCreationProvider = StateNotifierProvider<OrderCreationNotifier, AsyncValue<void>>((ref) {
  return OrderCreationNotifier(ref.read(orderRepositoryProvider));
});
