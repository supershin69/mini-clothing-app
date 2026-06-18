import 'package:clothing_shop/l10n/app_localizations.dart';
import 'package:clothing_shop/state/cart_provider.dart';
import 'package:clothing_shop/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _currentImageIndex = 0;
  String? _selectedSize;
  int _quantity = 1;

  late final TextEditingController _quantityController;
  late final List<ProductVariantModel> _instockVariants;
  late final List<ProductImageModel> _sortedImages;

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

    _sortedImages = List.from(widget.product.images);
    _sortedImages.sort(
      (a, b) => (b.isPrimary ? 1 : 0).compareTo(a.isPrimary ? 1 : 0),
    );
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite_border,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {},
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(context),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.product.brand != null) ...[
                          Text(
                            widget.product.brand!.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.name,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "\$${widget.product.price.toStringAsFixed(2)}"
                                  .toLocalizedNum(context),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.selectSize,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSizeSection(),
                        const SizedBox(height: 28),
                        Text(
                          l10n.description,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description.isEmpty
                              ? l10n.noDescription
                              : widget.product.description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Theme.of(
                              context,
                            ).disabledColor.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildAddToCartSection(),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (_sortedImages.isEmpty) {
      return Container(
        height: screenHeight * 0.45,
        color: Theme.of(context).inputDecorationTheme.fillColor,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 48),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: screenHeight * 0.45,
          child: PageView.builder(
            itemCount: _sortedImages.length,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemBuilder: (context, index) {
              return Image.network(
                _sortedImages[index].imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (_sortedImages.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_sortedImages.length, (index) {
                final bool isActive = _currentImageIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  height: 6,
                  width: isActive ? 18 : 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Theme.of(context).primaryColor
                        : Theme.of(
                            context,
                          ).scaffoldBackgroundColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildSizeSection() {
    final l10n = AppLocalizations.of(context)!;
    if (_instockVariants.isEmpty) {
      return Text(
        l10n.outOfStock,
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      );
    }

    final uniqueSizes = _instockVariants.map((v) => v.size).toSet().toList();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: uniqueSizes.map((size) {
        final bool isSelected = _selectedSize == size;

        return GestureDetector(
          onTap: () {
            setState(() => _selectedSize = size);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor,
                width: 1.5,
              ),
            ),
            child: Text(
              size,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddToCartSection() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () => _updateQuantity(_quantity - 1),
                ),
                SizedBox(
                  width: 40,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                      if (parsed != null) {
                        _quantity = parsed;
                      } else if (val.isEmpty) {
                        _quantity = 1;
                      }
                    },
                    onSubmitted: (val) {
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
                      _updateQuantity(parsed ?? 1);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () => _updateQuantity(_quantity + 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _instockVariants.isEmpty
                    ? null
                    : () {
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).addItem(widget.product, _selectedSize!, _quantity);

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
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Theme.of(
                    context,
                  ).disabledColor.withOpacity(0.3),
                ),
                child: Text(
                  _instockVariants.isEmpty ? l10n.outOfStock : l10n.addToCart,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
