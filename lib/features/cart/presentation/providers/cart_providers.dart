import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) => CartRepository());

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>((ref) {
  return CartNotifier(ref.read(cartRepositoryProvider));
});

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  final CartRepository _repository;
  bool _loaded = false;

  CartNotifier(this._repository) : super([]);

  Future<void> loadCart() async {
    if (!_loaded) {
      state = await _repository.loadCart();
      _loaded = true;
    }
  }

  Future<void> _persist() async {
    await _repository.saveCart(state);
  }

  void addItem(CartItemModel item) {
    final index = state.indexWhere((i) => i.productId == item.productId);
    if (index >= 0) {
      final updated = [...state];
      final existing = updated[index];
      final newQty = existing.quantity + item.quantity;
      if (newQty <= existing.maxStock) {
        updated[index] = existing.copyWith(quantity: newQty);
        state = updated;
        _persist();
      }
    } else {
      state = [...state, item];
      _persist();
    }
  }

  void updateQuantity(String productId, int quantity) {
    state = state.map((item) {
      if (item.productId == productId) {
        return item.copyWith(quantity: quantity.clamp(1, item.maxStock));
      }
      return item;
    }).toList();
    _persist();
  }

  void removeItem(String productId) {
    state = state.where((item) => item.productId != productId).toList();
    _persist();
  }

  void clear() {
    state = [];
    _repository.clearCart();
  }

  int get itemCount => state.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => state.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get originalSubtotal => state.fold(0.0, (sum, item) => sum + item.originalTotal);
  double get savings => originalSubtotal - subtotal;
  double get deliveryFee => subtotal >= 20 ? 0 : 2.50;
  double get total => subtotal + deliveryFee;
}
