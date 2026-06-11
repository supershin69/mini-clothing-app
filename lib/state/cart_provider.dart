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

  // 📦 Cache the last successful order payload returned from PostgreSQL/Prisma
  Map<String, dynamic>? _lastPlacedOrder;
  Map<String, dynamic>? get lastPlacedOrder => _lastPlacedOrder;

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

  // 🚀 Live Checkout Backend Integration Method
  Future<bool> processCheckout() async {
    if (_cartItems.isEmpty) return false;

    try {
      // 1. Map your internal frontend cart map structure to the backend OrderLine schema format
      final List<Map<String, dynamic>> targetLines = _cartItems.values.map((
        item,
      ) {
        // Find the variant UUID/CUID matching the user's chosen size
        final matchedVariant = item.product.variants.firstWhere(
          (v) => v.size == item.selectedSize,
          orElse: () => item.product.variants.first,
        );

        return {
          'variant_id': matchedVariant
              .id, // Maps directly to backend foreign key relation
          'quantity': item.quantity,
          'price': item.product.price,
        };
      }).toList();

      // 2. Post the structured payload via your Dio ApiService instance
      final responseData = await _apiService.createOrder(
        totalAmount: totalAmount,
        orderLines: targetLines,
      );

      // 3. Keep a backup of the backend's response object structure for the Success Page layout
      _lastPlacedOrder = responseData;

      // 4. Wipe the local cart state out on database write success
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
