import 'package:clothing_shop/state/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckoutSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const CheckoutSuccessScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> lines = orderData['order_lines'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
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
                  color: const Color(0xFFE5D3B3).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 72,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Order Placed Successfully!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Order ID: ${orderData['id']}",
                style: const TextStyle(
                  color: Colors.grey,
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
                    final line = lines[index];
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
                                  line['product_name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Size: ${line['selected_size']}  x${line['quantity']}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "\$${(line['price'] * line['quantity']).toStringAsFixed(2)}",
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
                      "\$${orderData['total_amount'].toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF1A1A1A),
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
                    // 1. Tab state ကို Home Screen (Index 0) သို့ ပြောင်းမယ်
                    Provider.of<NavigationProvider>(
                      context,
                      listen: false,
                    ).changeTab(0);
                    // 2. Stack တစ်ခုလုံးကို MainWrapper (First Route) ဆီ ပြန်ဆွဲချမယ်
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
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
