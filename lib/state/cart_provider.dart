import 'package:flutter/material.dart';
import '../models/product_model.dart';


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

  
  List<CartItemModel> get cartItems => _cartItems.values.toList();
  int get itemCount => _cartItems.length;

  
  double get subtotalAmount {
    double total = 0.0;
    _cartItems.forEach((key, item) {
      total += item.product.price * item.quantity;
    });
    return total;
  }

  
  double get shippingFee => (subtotalAmount > 50.0 || subtotalAmount == 0) ? 0.0 : 5.00;

  
  double get totalAmount => subtotalAmount + shippingFee;

  
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