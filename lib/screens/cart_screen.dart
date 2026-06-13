import 'package:clothing_shop/screens/checkout_success_screen.dart';
import 'package:clothing_shop/state/cart_provider.dart';
import 'package:clothing_shop/models/order_model.dart'; // 💡 OrderModel Type ကို သေချာသိအောင် တစ်ခါတည်း import ထည့်ထားပေးပါတယ်
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.cartItems.isEmpty) {
            return _buildEmptyCart(context); // Passed context here
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
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // --- 🖼️ IMAGE WITH ERROR & LOADING BUILDER ---
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.product.primaryImageUrl,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            width: 70,
                                            height: 70,
                                            color: Theme.of(
                                              context,
                                            ).inputDecorationTheme.fillColor,
                                            child: Center(
                                              child: SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                    ),
                                              ),
                                            ),
                                          );
                                        },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 70,
                                        height: 70,
                                        color: Theme.of(
                                          context,
                                        ).inputDecorationTheme.fillColor,
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                          color: Theme.of(
                                            context,
                                          ).disabledColor,
                                          size: 24,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // --- 📝 PRODUCT DETAILS ---
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Size: ${item.selectedSize}",
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).disabledColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "\$${(item.product.price * item.quantity).toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // --- 🗑️ DELETE & QUANTITY CONTROLLER ---
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          cartProvider.removeItem(item.id),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () =>
                                                cartProvider.updateQuantity(
                                                  item.id,
                                                  item.quantity - 1,
                                                ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              child: Icon(
                                                Icons.remove,
                                                size: 14,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "${item.quantity}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () =>
                                                cartProvider.updateQuantity(
                                                  item.id,
                                                  item.quantity + 1,
                                                ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              child: Icon(Icons.add, size: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Passed context to helper methods
                            _buildPriceRow(
                              context,
                              "Subtotal",
                              "\$${cartProvider.subtotalAmount.toStringAsFixed(2)}",
                            ),
                            const SizedBox(height: 10),
                            _buildPriceRow(
                              context,
                              "Shipping Fee",
                              cartProvider.shippingFee == 0
                                  ? "Free"
                                  : "\$${cartProvider.shippingFee.toStringAsFixed(2)}",
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              child: Divider(
                                height: 1,
                                thickness: 1,
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            _buildPriceRow(
                              context,
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

              // --- 🛒 CHECKOUT BUTTON SECTION ---
              Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  MediaQuery.of(context).padding.bottom + 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      );

                      final provider = Provider.of<CartProvider>(
                        context,
                        listen: false,
                      );
                      bool success = await provider.processCheckout();

                      if (context.mounted) {
                        Navigator.pop(context); // Dismiss loading spinner
                      }

                      if (success && context.mounted) {
                        // 💡 liveOrderData ရဲ့ Type ကို OrderModel ဖြစ်ကြောင်း သေချာအောင် သတ်မှတ်ပေးလိုက်ပါတယ်
                        final OrderModel? liveOrderData =
                            provider.lastPlacedOrder;

                        if (liveOrderData != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutSuccessScreen(
                                orderData:
                                    liveOrderData, // 🚀 အောင်မြင်စွာ ပါးလိုက်ပါပြီ
                              ),
                            ),
                          );
                        }
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Failed to process order. Please try again.",
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      "PROCEED TO CHECKOUT",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
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

  // Required 'BuildContext context' parameter added here
  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // Required 'BuildContext context' parameter added here
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            "Your cart is empty!",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Add some items to get started.",
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
        ],
      ),
    );
  }
}
