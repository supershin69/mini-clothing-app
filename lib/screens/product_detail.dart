import 'package:clothing_shop/state/cart_provider.dart';
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
    _sortedImages.sort((a, b) => (b.isPrimary ? 1 : 0).compareTo(a.isPrimary ? 1 : 0));
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
      _quantityController.text = _quantity.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Color(0xFF1A1A1A)),
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
                  
                  
                  
                  _buildImageSection(),

                  
                  
                  
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
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "\$${widget.product.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        
                        const Text(
                          "Select Size",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSizeSection(),
                        const SizedBox(height: 28),

                        
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description.isEmpty 
                              ? "No description available for this option." 
                              : widget.product.description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.grey[700],
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

  
  Widget _buildImageSection() {
    final double screenHeight = MediaQuery.of(context).size.height;
    
    if (_sortedImages.isEmpty) {
      return Container(
        height: screenHeight * 0.45,
        color: const Color(0xFFF5F5F5),
        child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 48)),
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
                    color: const Color(0xFFF5F5F5),
                    child: const Center(child: Icon(Icons.broken_image_outlined)),
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
                    color: isActive ? const Color(0xFF1A1A1A) : Colors.white.withOpacity(0.6),
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
    if (_instockVariants.isEmpty) {
      return const Text(
        "OUT OF STOCK",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
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
              
              color: isSelected ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? const Color(0xFF1A1A1A) : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Text(
              size,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
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
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18, color: Color(0xFF1A1A1A)),
                  onPressed: () => _updateQuantity(_quantity - 1),
                ),
                SizedBox(
                  width: 40,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, 
                    ],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: (val) {
                      final int? parsed = int.tryParse(val);
                      if (parsed != null) {
                        _quantity = parsed;
                      } else if (val.isEmpty) {
                        _quantity = 1; 
                      }
                    },
                    onSubmitted: (val) {
                      final int? parsed = int.tryParse(val);
                      _updateQuantity(parsed ?? 1);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18, color: Color(0xFF1A1A1A)),
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
                    Provider.of<CartProvider>(context, listen: false).addItem(
                      widget.product, 
                      _selectedSize!, 
                      _quantity,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF1A1A1A),
                        content: Text("Added $_quantity x ${widget.product.name} ($_selectedSize) to cart!"),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Text(
                  _instockVariants.isEmpty ? "OUT OF STOCK" : "ADD TO CART",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}