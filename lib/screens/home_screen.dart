import 'package:clothing_shop/models/product_model.dart';
import 'package:clothing_shop/widgets/product_section.dart'; // 🎯 ဒီကောင်လေး သွင်းလိုက်မယ်
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final trendingProducts = mockProducts.reversed.toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏷️ 1. Promo Banner Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Streetwear Collection",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Get Up to 30% OFF",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1A1A1A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Explore"),
                  ),
                ],
              ),
            ),
          ),


          ProductSection(
            title: "New Arrivals",
            products: mockProducts,
            onSeeAllTap: () {
              print("Navigate to Shop Page from New Arrivals");
            },
          ),


          ProductSection(
            title: "Trending Now",
            products: trendingProducts,
            onSeeAllTap: () {
              print("Navigate to Shop Page from Trending Now");
            },
          ),
          
          const SizedBox(height: 40),
        ]
      ),
    );
  }
}