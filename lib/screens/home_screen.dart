import 'package:clothing_shop/l10n/app_localizations.dart';
import 'package:clothing_shop/models/product_model.dart';
import 'package:clothing_shop/widgets/product_section.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trendingProducts = mockProducts.reversed.toList();
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Streetwear Collection",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withOpacity(0.85),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.discountAds,
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
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(l10n.explore),
                  ),
                ],
              ),
            ),
          ),

          ProductSection(
            title: l10n.newArrivals,
            products: mockProducts,
            onSeeAllTap: () {
              print("Navigate to Shop Page from New Arrivals");
            },
          ),

          ProductSection(
            title: l10n.trendingNow,
            products: trendingProducts,
            onSeeAllTap: () {
              print("Navigate to Shop Page from Trending Now");
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
