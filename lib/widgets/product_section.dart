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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
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

        // Horizontal ListView
        SizedBox(
          height: 250,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            scrollDirection: Axis.horizontal,
            // ပစ္စည်း ၄ ခု ပြသပြီး အဆုံးမှာ See All Card ပြမှာမို့လို့ ၅ ခုလို့ သတ်မှတ်ထားခြင်း
            itemCount: 5, 
            itemBuilder: (context, index) {
              if (index == 4) {
                return _buildExploreMoreCard();
              }

              // ပေးလိုက်တဲ့ Products List ထဲက ဒေတာကို ယူသုံးမယ်
              final product = products[index];
              return ClothingCard(
                imageUrl: product.imageUrl,
                title: product.name,
                price: product.price,
                onTap: () {
                  print("Tapped ${product.name} from $title");
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // အဆုံးမှာပြသမည့် See All Card
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