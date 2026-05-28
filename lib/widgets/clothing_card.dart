import 'package:flutter/material.dart';

class ClothingCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double price;
  final VoidCallback onTap;

  const ClothingCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160, // 💡 Horizontal ListView မှာ ပုံသေ အကျယ်ရှိနေအောင် သတ်မှတ်ခြင်း
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ ၁။ ပစ္စည်းပုံရိပ် Section (အနားကွေးလေးနဲ့ ညှပ်ပေးထားမယ်)
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover, // ပုံမပျက်ဘဲ ကတ်ထဲ အပြည့်ဝင်စေဖို့
                  // 💡 Network ကနေ ပုံဆွဲရတာ ကြာရင် Loading လေး ပြပေးထားမယ်
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1A1A)),
                        ),
                      ),
                    );
                  },
                  // 💡 URL မှားတာမျိုး ဖြစ်ခဲ့ရင် Error တက်မပြဘဲ Placeholder ပုံလေး ပြထားမယ်
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),

            // 📝 ၂။ စာသားနဲ့ ဈေးနှုန်း ပြသမည့် နေရာ
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Title (စာတန်းအရှည်ကြီးဖြစ်ရင် ... နဲ့ ဖြတ်ပစ်မယ်)
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Price Tag
                  Text(
                    "\$${price.toStringAsFixed(2)}", // 💡 ဒသမ ၂ နေရာအထိ အမြဲဖြတ်ပြမယ်
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}