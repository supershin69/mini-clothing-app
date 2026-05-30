import 'package:clothing_shop/state/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          
          
          if (cartProvider.cartItems.isEmpty) {
            return _buildEmptyCart();
          }

          return Column(
            children: [
              
              
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartProvider.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartProvider.cartItems[index];
                          
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.product.primaryImageUrl,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Size: ${item.selectedSize}",
                                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "\$${(item.product.price * item.quantity).toStringAsFixed(2)}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                                      ),
                                    ],
                                  ),
                                ),

                                
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () => cartProvider.removeItem(item.id),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () => cartProvider.updateQuantity(item.id, item.quantity - 1),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              child: Icon(Icons.remove, size: 14),
                                            ),
                                          ),
                                          Text(
                                            "${item.quantity}",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          GestureDetector(
                                            onTap: () => cartProvider.updateQuantity(item.id, item.quantity + 1),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              child: Icon(Icons.add, size: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      const Divider(indent: 16, endIndent: 16),

                      
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Order Summary",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            _buildPriceRow("Subtotal", "\$${cartProvider.subtotalAmount.toStringAsFixed(2)}"),
                            const SizedBox(height: 10),
                            _buildPriceRow("Shipping Fee", cartProvider.shippingFee == 0 ? "Free" : "\$${cartProvider.shippingFee.toStringAsFixed(2)}"),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
                            ),
                            _buildPriceRow(
                              "Total Price", 
                              "\$${cartProvider.totalAmount.toStringAsFixed(2)}", 
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              
              
              
              Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Order Placed!"),
                          content: const Text("Thank you for shopping with Vibe Clothing Shop."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                cartProvider.clearCart(); 
                                Navigator.pop(context);
                              },
                              child: const Text("OK", style: TextStyle(color: Color(0xFF1A1A1A))),
                            )
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A), 
                    ),
                    child: const Text(
                      "PROCEED TO CHECKOUT",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  
  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? const Color(0xFF1A1A1A) : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFF1A1A1A) : Colors.black,
          ),
        ),
      ],
    );
  }

  
  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Your cart is empty!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 6),
          Text(
            "Add some items to get started.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}