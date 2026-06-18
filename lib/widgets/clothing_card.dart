import 'package:clothing_shop/l10n/app_localizations.dart';
import 'package:clothing_shop/state/cart_provider.dart';
import 'package:clothing_shop/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';

class ClothingCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ClothingCard({super.key, required this.product, required this.onTap});

  // 🔥 Quick Add to Cart Bottom Sheet ကို ခေါ်ယူမည့် Function
  void _openQuickAddToCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Keyboard တက်လာရင် ကန်မတက်အောင် ကာကွယ်ရန်
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickAddToCartBottomSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = product.variants.every(
      (v) => v.stock == 0 || v.status == ProductStatus.OUT_OF_STOCK,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
            // Image Stack Area (မူလအတိုင်း)
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        product.primaryImageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[100],
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (isOutOfStock)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "SOLD OUT",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content Area
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.brand != null) ...[
                    Text(
                      product.brand!.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).disabledColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 🔥 ပြင်ဆင်လိုက်သည့် နေရာ - Price နှင့် Cart Button ကို Row ဖြင့် ညှပ်ထားပါတယ်
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "\$${product.price.toStringAsFixed(2)}"
                              .toLocalizedNum(context),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      if (!isOutOfStock) // ပစ္စည်းရှိမှသာ ဝယ်လို့ရမည့် Button ကို ပြပါမည်
                        GestureDetector(
                          onTap: () => _openQuickAddToCart(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.shopping_cart,
                              size: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                    ],
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

// ==========================================
// 🔥 အောက်ကနေ ပွင့်လာမည့် Quick Add to Cart Sheet (Stateful Component)
// ==========================================
class _QuickAddToCartBottomSheet extends StatefulWidget {
  final ProductModel product;
  const _QuickAddToCartBottomSheet({required this.product});

  @override
  State<_QuickAddToCartBottomSheet> createState() =>
      _QuickAddToCartBottomSheetState();
}

class _QuickAddToCartBottomSheetState
    extends State<_QuickAddToCartBottomSheet> {
  String? _selectedSize;
  int _quantity = 1;
  late final TextEditingController _quantityController;
  late final List<ProductVariantModel> _instockVariants;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: _quantity.toString());

    _instockVariants = widget.product.variants.where((variant) {
      return variant.stock > 0 && variant.status == ProductStatus.IN_STOCK;
    }).toList();

    if (_instockVariants.isNotEmpty) {
      _selectedSize = _instockVariants.first.size;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _updateQuantity(int newQuantity) {
    if (newQuantity < 1) return;
    setState(() {
      _quantity = newQuantity;
      _quantityController.text = _quantity.toString().toLocalizedNum(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _quantityController.text = _quantity.toString().toLocalizedNum(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Content ရှိသလောက်ပဲ အမြင့်ယူရန်
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle Area
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Mini Product Info Header
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.product.primaryImageUrl,
                  width: 55,
                  height: 55,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${widget.product.price.toStringAsFixed(2)}"
                          .toLocalizedNum(context),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Size Selector
          Text(
            l10n.selectSize,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          _buildSizeSection(),
          const SizedBox(height: 24),

          // Quantity and Add to Cart Action Row
          Row(
            children: [
              // Quantity Counter (မင်းဆောက်ထားတဲ့ UX အတိုင်း)
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: () => _updateQuantity(_quantity - 1),
                    ),
                    SizedBox(
                      width: 35,
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onChanged: (val) {
                          String cleanVal = val;
                          const myanmarDigits = [
                            '၀',
                            '၁',
                            '၂',
                            '၃',
                            '၄',
                            '၅',
                            '၆',
                            '၇',
                            '၈',
                            '၉',
                          ];
                          const englishDigits = [
                            '0',
                            '1',
                            '2',
                            '3',
                            '4',
                            '5',
                            '6',
                            '7',
                            '8',
                            '9',
                          ];
                          for (int i = 0; i < 10; i++) {
                            cleanVal = cleanVal.replaceAll(
                              myanmarDigits[i],
                              englishDigits[i],
                            );
                          }
                          final int? parsed = int.tryParse(cleanVal);
                          if (parsed != null) _quantity = parsed;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () => _updateQuantity(_quantity + 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Button Area
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _instockVariants.isEmpty
                        ? null
                        : () {
                            Provider.of<CartProvider>(
                              context,
                              listen: false,
                            ).addItem(
                              widget.product,
                              _selectedSize!,
                              _quantity,
                            );

                            Navigator.pop(context); // Bottom Sheet ပိတ်လိုက်မယ်

                            final isMyanmar =
                                Localizations.localeOf(context).languageCode ==
                                'my';
                            final successMessage = isMyanmar
                                ? "${widget.product.name} (${_selectedSize!.toLocalizedNum(context)}) အရေအတွက် (${_quantity.toString().toLocalizedNum(context)}) ခုကို ခြင်းတောင်းထဲ ထည့်ပြီးပါပြီ။"
                                : "Added $_quantity x ${widget.product.name} ($_selectedSize) to cart!";

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Theme.of(context).primaryColor,
                                content: Text(successMessage),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                    child: Text(
                      _instockVariants.isEmpty
                          ? l10n.outOfStock
                          : l10n.addToCart,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSection() {
    final l10n = AppLocalizations.of(context)!;
    if (_instockVariants.isEmpty) {
      return Text(
        l10n.outOfStock,
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      );
    }

    final uniqueSizes = _instockVariants.map((v) => v.size).toSet().toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: uniqueSizes.map((size) {
        final bool isSelected = _selectedSize == size;
        return GestureDetector(
          onTap: () => setState(() => _selectedSize = size),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor,
              ),
            ),
            child: Text(
              size.toLocalizedNum(context),
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
