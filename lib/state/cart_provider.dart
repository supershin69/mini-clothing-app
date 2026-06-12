import 'package:clothing_shop/models/order_model.dart';
import 'package:clothing_shop/services/api_service.dart'; // ✅ Make sure this import path matches your project structure
import 'package:clothing_shop/models/product_model.dart';
import 'package:flutter/material.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  final String selectedSize;
  int quantity;

  CartItemModel({
    required this.id,
    required this.product,
    required this.selectedSize,
    required this.quantity,
  });
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItemModel> _cartItems = {};
  final ApiService _apiService = ApiService(); // ✅ Initialize API Service

  // 📦 Map အစား OrderModel သို့ ပြောင်းလဲသတ်မှတ်ခြင်း
  OrderModel? _lastPlacedOrder;
  OrderModel? get lastPlacedOrder => _lastPlacedOrder;

  List<CartItemModel> get cartItems => _cartItems.values.toList();
  int get itemCount => _cartItems.length;

  double get subtotalAmount {
    double total = 0.0;
    _cartItems.forEach((key, item) {
      total += item.product.price * item.quantity;
    });
    return total;
  }

  double get shippingFee =>
      (subtotalAmount > 50.0 || subtotalAmount == 0) ? 0.0 : 5.00;

  double get totalAmount => subtotalAmount + shippingFee;

  Future<bool> processCheckout() async {
    if (_cartItems.isEmpty) return false;

    try {
      final List<Map<String, dynamic>> targetItems = _cartItems.values.map((
        item,
      ) {
        final matchedVariant = item.product.variants.firstWhere(
          (v) => v.size == item.selectedSize,
          orElse: () => item.product.variants.first,
        );
        return {'variant_id': matchedVariant.id, 'quantity': item.quantity};
      }).toList();

      // ApiService က createOrder သို့မဟုတ် getMyOrders ကနေ OrderModel ပြန်ပေးတာမို့လို့
      // တိုက်ရိုက် assign လုပ်ပေးလို့ ရသွားပါပြီ
      final responseData = await _apiService.createOrder(items: targetItems);
      print("📦 API RESPONSE DATA: $responseData");
      _lastPlacedOrder = OrderModel.fromJson(responseData['order']);

      clearCart();
      return true;
    } catch (e) {
      print("❌ Error processing checkout pipeline inside Provider: $e");
      return false;
    }
  }

  void addItem(ProductModel product, String size, int quantity) {
    final String cartItemId = "${product.id}_$size";

    if (_cartItems.containsKey(cartItemId)) {
      _cartItems.update(
        cartItemId,
        (existingItem) => CartItemModel(
          id: existingItem.id,
          product: existingItem.product,
          selectedSize: existingItem.selectedSize,
          quantity: existingItem.quantity + quantity,
        ),
      );
    } else {
      _cartItems.putIfAbsent(
        cartItemId,
        () => CartItemModel(
          id: cartItemId,
          product: product,
          selectedSize: size,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(cartItemId);
      return;
    }
    if (_cartItems.containsKey(cartItemId)) {
      _cartItems[cartItemId]!.quantity = newQuantity;
      notifyListeners();
    }
  }

  void removeItem(String cartItemId) {
    _cartItems.remove(cartItemId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
