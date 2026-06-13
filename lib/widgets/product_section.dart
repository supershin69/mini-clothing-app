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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
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
                // Passed context here
                return _buildExploreMoreCard(context);
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

  // Added BuildContext as a parameter
  Widget _buildExploreMoreCard(BuildContext context) {
    return GestureDetector(
      onTap: onSeeAllTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 24,
              child: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "See All",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
