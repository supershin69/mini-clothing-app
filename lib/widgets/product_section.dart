import 'dart:math'; 
import 'package:clothing_shop/screens/product_detail.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'clothing_card.dart';

class ProductSection extends StatelessWidget {
  final String title;
  final List<ProductModel> products;
  final VoidCallback onSeeAllTap;

  const ProductSection({
    super.key,
    required this.title,
    required this.products,
    required this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final int displayCount = min(products.length, 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),

        
        SizedBox(
          height: 250,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            scrollDirection: Axis.horizontal,
            itemCount: displayCount + 1, 
            itemBuilder: (context, index) {
              if (index == displayCount) {
                return _buildExploreMoreCard();
              }

              final product = products[index];
              
              
              return ClothingCard(
                product: product,
                onTap: () {
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: product),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  
  Widget _buildExploreMoreCard() {
    return GestureDetector(
      onTap: onSeeAllTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFF1A1A1A),
              radius: 24,
              child: Icon(Icons.arrow_forward, color: Colors.white, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              "See All",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}