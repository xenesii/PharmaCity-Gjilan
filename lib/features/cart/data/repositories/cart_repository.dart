import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

class CartRepository {
  static const String _cartKey = 'pharmacity_cart';

  Future<List<CartItemModel>> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_cartKey);
      if (data == null || data.isEmpty) return [];
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((j) => CartItemModel.fromJson(j)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveCart(List<CartItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(items.map((i) => i.toJson()).toList());
    await prefs.setString(_cartKey, data);
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
