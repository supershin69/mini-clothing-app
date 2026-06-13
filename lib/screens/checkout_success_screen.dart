import 'package:clothing_shop/state/navigation_provider.dart';
import 'package:clothing_shop/models/order_model.dart'; // 💡 သေချာ import လုပ်ထားပါ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckoutSuccessScreen extends StatelessWidget {
  final OrderModel orderData; // 💡 OrderModel ကို တိုက်ရိုက် လက်ခံထားပါတယ်

  const CheckoutSuccessScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final List<OrderLineModel> lines =
        orderData.orderLines; // 💡 ကွက်တိ Type မိသွားပါပြီ

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // --- 🎉 SUCCESS ICON ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 72,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Order Placed Successfully!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Order ID: ${orderData.id}",
                style: TextStyle(
                  color: Theme.of(context).disabledColor,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 32),
              const Divider(),

              // --- 📦 ORDER SUMMARY DETAIL CARDS ---
              Expanded(
                flex: 3,
                child: ListView.builder(
                  itemCount: lines.length,
                  itemBuilder: (context, index) {
                    final line =
                        lines[index]; // 💡 line သည် OrderLineModel ဖြစ်သွားပါပြီ

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line.productName, // 💡 Model ထဲကနေ တိုက်ရိုက်ဆွဲထုတ်ခေါ်ယူခြင်း
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Size: ${line.selectedSize}  x${line.quantity}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "\$${(line.price * line.quantity).toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Paid",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "\$${orderData.totalAmount.toStringAsFixed(2)}", // 💡 .totalAmount ကို တိုက်ရိုက်ခေါ်ခြင်း
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // --- 🏠 RETURN TO HOME BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Provider.of<NavigationProvider>(
                      context,
                      listen: false,
                    ).changeTab(0);
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text(
                    "RETURN TO HOME",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
