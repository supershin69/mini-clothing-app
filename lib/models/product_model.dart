enum Gender { MALE, FEMALE, UNISEX }

enum ProductStatus { 
  IN_STOCK,
  OUT_OF_STOCK,
  DISCONTINUED 
}

Gender parseGender (String? gender) {
  return Gender.values.firstWhere((e) => e.name == gender, orElse: () => Gender.UNISEX);
}

ProductStatus parseProductStatus (String? status) {
  switch (status) {
    case 'IN_STOCK':
      return ProductStatus.IN_STOCK;
    case 'OUT_OF_STOCK':
      return ProductStatus.OUT_OF_STOCK;
    case 'DISCONTINUED':
      return ProductStatus.DISCONTINUED;
    default:
      return ProductStatus.IN_STOCK;
  }
}

class ProductImageModel {
  final String id;
  final String imageUrl;
  final bool isPrimary;

  ProductImageModel({
    required this.id,
    required this.imageUrl,
    required this.isPrimary,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }
}

class ProductVariantModel {
  final String id;
  final String size;
  final String? color;
  final int stock;
  final ProductStatus status;

  ProductVariantModel({
    required this.id,
    required this.size,
    this.color,
    required this.stock,
    required this.status,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'] as String? ?? '',
      size: json['size'] as String? ?? '',
      color: json['color'] as String?,
      stock: json['stock'] as int? ?? 0,
      status: parseProductStatus(json['status'] as String?),
    );
  }
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? brand;
  final Gender gender;
  final double price;
  final List<ProductVariantModel> variants;
  final List<ProductImageModel> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.brand,
    required this.gender,
    required this.price,
    required this.variants,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  String get primaryImageUrl {
    if (images.isEmpty) return '';
    final primaryImage = images.firstWhere((img) => img.isPrimary, orElse: () => images.first);
    return primaryImage.imageUrl;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    var variantsFromJson = json['variants'] as List<dynamic>? ?? [];
    List<ProductVariantModel> variantsList = variantsFromJson
      .map((variantJson) => ProductVariantModel.fromJson(variantJson as Map<String, dynamic>))
      .toList();

    var imagesFromJson = json['images'] as List<dynamic>? ?? [];
    List<ProductImageModel> imagesList = imagesFromJson
      .map((imageJson) => ProductImageModel.fromJson(imageJson as Map<String, dynamic>))
      .toList();

      return ProductModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        category: json['category'] as String? ?? 'Uncategorized',
        brand: json['brand'] as String?,
        gender: parseGender(json['gender'] as String?),
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        variants: variantsList,
        images: imagesList,
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
        updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),

      );
  }
}

final List<ProductModel> mockProducts = [
  
  ProductModel(
    id: "p1",
    name: "Oversized Vintage Hoodie",
    description: "Premium heavy cotton hoodie with drop shoulders. Perfect for minimalist streetwear vibe.",
    category: "Streetwear",
    brand: "AestheticLab",
    gender: Gender.UNISEX,
    price: 35.00,
    images: [
      ProductImageModel(id: '101', imageUrl: "https://images.unsplash.com/photo-1556905055-8f358a7a47b2?q=80&w=500&auto=format&fit=crop", isPrimary: true),
      ProductImageModel(id: '102', imageUrl: "https://images.unsplash.com/photo-1543163521-1bf539c55dd2?q=80&w=500&auto=format&fit=crop", isPrimary: false),
    ],
    variants: [
      ProductVariantModel(id: "v1_1", size: "S", color: "Vintage Black", stock: 15, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v1_2", size: "M", color: "Vintage Black", stock: 22, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v1_3", size: "L", color: "Vintage Black", stock: 0, status: ProductStatus.OUT_OF_STOCK),
      ProductVariantModel(id: "v1_4", size: "XL", color: "Vintage Black", stock: 5, status: ProductStatus.IN_STOCK),
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now(),
  ),

  
  ProductModel(
    id: "p2",
    name: "Classic Denim Jacket",
    description: "Timeless blue denim jacket with a relaxed fit, silver hardware, and durable double-stitching.",
    category: "Outerwear",
    brand: "DenimCo",
    gender: Gender.UNISEX,
    price: 48.50,
    images: [
      ProductImageModel(id: '201', imageUrl: "https://images.unsplash.com/photo-1576995853123-5a10305d93c0?q=80&w=500&auto=format&fit=crop", isPrimary: true),
    ],
    variants: [
      ProductVariantModel(id: "v2_1", size: "M", color: "Classic Blue", stock: 8, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v2_2", size: "L", color: "Classic Blue", stock: 12, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v2_3", size: "XL", color: "Classic Blue", stock: 3, status: ProductStatus.IN_STOCK),
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now(),
  ),

  
  ProductModel(
    id: "p3",
    name: "Minimalist Graphic Tee",
    description: "100% breathable organic cotton tee featuring a subtle abstract chest print.",
    category: "Essentials",
    brand: null, 
    gender: Gender.MALE,
    price: 18.00,
    images: [
      ProductImageModel(id: '301', imageUrl: "https://images.unsplash.com/photo-1521572267360-ee0c2909d518?q=80&w=500&auto=format&fit=crop", isPrimary: true),
    ],
    variants: [
      ProductVariantModel(id: "v3_1", size: "S", color: "White", stock: 40, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v3_2", size: "M", color: "White", stock: 55, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v3_3", size: "L", color: "White", stock: 18, status: ProductStatus.IN_STOCK),
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    updatedAt: DateTime.now(),
  ),

  
  ProductModel(
    id: "p4",
    name: "Cropped Knit Cardigan",
    description: "Soft, ribbed knit cardigan with tortoiseshell buttons. Cozy yet stylish option for daily wear.",
    category: "Knitwear",
    brand: "VogueThreads",
    gender: Gender.FEMALE,
    price: 26.99,
    images: [
      ProductImageModel(id: '401', imageUrl: "https://images.unsplash.com/photo-1614975058789-41316d0e2e9c?q=80&w=500&auto=format&fit=crop", isPrimary: true),
    ],
    variants: [
      ProductVariantModel(id: "v4_1", size: "XS", color: "Cream", stock: 4, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v4_2", size: "S", color: "Cream", stock: 0, status: ProductStatus.OUT_OF_STOCK),
      ProductVariantModel(id: "v4_3", size: "M", color: "Cream", stock: 9, status: ProductStatus.IN_STOCK),
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    updatedAt: DateTime.now(),
  ),

  
  ProductModel(
    id: "p5",
    name: "Urban Cargo Pants",
    description: "Multi-pocket durable cargo pants featuring adjustable ankle straps and flexible waistband.",
    category: "Streetwear",
    brand: "UtilityGear",
    gender: Gender.UNISEX,
    price: 42.00,
    images: [
      ProductImageModel(id: '501', imageUrl: "https://images.unsplash.com/photo-1517423738875-5ce310acd3da?q=80&w=500&auto=format&fit=crop", isPrimary: true),
    ],
    variants: [
      ProductVariantModel(id: "v5_1", size: "S", color: "Olive Green", stock: 14, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v5_2", size: "M", color: "Olive Green", stock: 20, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v5_3", size: "L", color: "Olive Green", stock: 11, status: ProductStatus.IN_STOCK),
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    updatedAt: DateTime.now(),
  ),

  
  ProductModel(
    id: "p6",
    name: "Athletic Running Shorts",
    description: "Lightweight moisture-wicking fabric with an inner compression lining and zipper key-pocket.",
    category: "Activewear",
    brand: "ApexPerformance",
    gender: Gender.MALE,
    price: 24.50,
    images: [
      ProductImageModel(id: '601', imageUrl: "https://images.unsplash.com/photo-1539185441755-769473a23570?q=80&w=500&auto=format&fit=crop", isPrimary: true),
    ],
    variants: [
      ProductVariantModel(id: "v6_1", size: "M", color: "Charcoal", stock: 30, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v6_2", size: "L", color: "Charcoal", stock: 25, status: ProductStatus.IN_STOCK),
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 6)),
    updatedAt: DateTime.now(),
  ),

  
  ProductModel(
    id: "p7",
    name: "Linen Summer Dress",
    description: "Breathable pure linen dress with an A-line silhouette and elegant cross-back tie styling.",
    category: "Dresses",
    brand: "BloomBoutique",
    gender: Gender.FEMALE,
    price: 55.00,
    images: [
      ProductImageModel(id: '701', imageUrl: "https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=500&auto=format&fit=crop", isPrimary: true),
    ],
    variants: [
      ProductVariantModel(id: "v7_1", size: "S", color: "Pastel Yellow", stock: 7, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v7_2", size: "M", color: "Pastel Yellow", stock: 5, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v7_3", size: "L", color: "Pastel Yellow", stock: 0, status: ProductStatus.OUT_OF_STOCK),
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    updatedAt: DateTime.now(),
  ),

  
  ProductModel(
    id: "p8",
    name: "Heavyweight Sweatpants",
    description: "Ultra-cozy fleece-lined sweatpants featuring deep side-pockets and premium thick drawstrings.",
    category: "Streetwear",
    brand: "AestheticLab",
    gender: Gender.UNISEX,
    price: 32.99,
    images: [
      ProductImageModel(id: '801', imageUrl: "https://images.unsplash.com/photo-1551854838-212c50b4c184?q=80&w=500&auto=format&fit=crop", isPrimary: true),
    ],
    variants: [
      ProductVariantModel(id: "v8_1", size: "S", color: "Heather Grey", stock: 18, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v8_2", size: "M", color: "Heather Grey", stock: 14, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v8_3", size: "L", color: "Heather Grey", stock: 22, status: ProductStatus.IN_STOCK),
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
    updatedAt: DateTime.now(),
  ),

  
  ProductModel(
    id: "p9",
    name: "Ribbed Tank Top",
    description: "Stretchy form-fitting tank top made with premium organic cotton blend. A seasonal layering essential.",
    category: "Essentials",
    brand: null,
    gender: Gender.FEMALE,
    price: 14.00,
    images: [
      ProductImageModel(id: '901', imageUrl: "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?q=80&w=500&auto=format&fit=crop", isPrimary: true),
    ],
    variants: [
      ProductVariantModel(id: "v9_1", size: "XS", color: "Beige", stock: 50, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v9_2", size: "S", color: "Beige", stock: 45, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v9_3", size: "M", color: "Beige", stock: 60, status: ProductStatus.IN_STOCK),
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 9)),
    updatedAt: DateTime.now(),
  ),

  
  ProductModel(
    id: "p10",
    name: "Vintage Flannel Shirt",
    description: "Thick, double-brushed cotton flannel plaid shirt. Looks great worn open over basic tees.",
    category: "Shirts",
    brand: "HeritageWeave",
    gender: Gender.MALE,
    price: 29.90,
    images: [
      ProductImageModel(id: '1001', imageUrl: "https://images.unsplash.com/photo-1598033129183-c4f50c736f10?q=80&w=500&auto=format&fit=crop", isPrimary: true),
    ],
    variants: [
      ProductVariantModel(id: "v10_1", size: "M", color: "Red Plaid", stock: 12, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v10_2", size: "L", color: "Red Plaid", stock: 9, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v10_3", size: "XL", color: "Red Plaid", stock: 0, status: ProductStatus.OUT_OF_STOCK),
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    updatedAt: DateTime.now(),
  ),

  
  ProductModel(
    id: "p11",
    name: "Tech Waterproof Parka",
    description: "Fully seam-sealed windproof and waterproof outer shell featuring an adjustable storm hood.",
    category: "Outerwear",
    brand: "UtilityGear",
    gender: Gender.UNISEX,
    price: 89.99,
    images: [
      ProductImageModel(id: '1101', imageUrl: "https://images.unsplash.com/photo-1544441893-675973e31985?q=80&w=500&auto=format&fit=crop", isPrimary: true),
    ],
    variants: [
      ProductVariantModel(id: "v11_1", size: "S", color: "Matte Black", stock: 6, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v11_2", size: "M", color: "Matte Black", stock: 4, status: ProductStatus.IN_STOCK),
      ProductVariantModel(id: "v11_3", size: "L", color: "Matte Black", stock: 8, status: ProductStatus.IN_STOCK),
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 11)),
    updatedAt: DateTime.now(),
  ),

  
  ProductModel(
    id: "p12",
    name: "Retro Corduroy Cap",
    description: "6-panel vintage style unconstructed corduroy cap featuring an embossed brass buckle closure.",
    category: "Accessories",
    brand: "AestheticLab",
    gender: Gender.UNISEX,
    price: 19.50,
    images: [
      ProductImageModel(id: '1201', imageUrl: "https://images.unsplash.com/photo-1588850561407-ed78c282e89b?q=80&w=500&auto=format&fit=crop", isPrimary: true),
    ],
    variants: [
      ProductVariantModel(id: "v12_1", size: "One Size", color: "Tan Brown", stock: 0, status: ProductStatus.DISCONTINUED), 
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 12)),
    updatedAt: DateTime.now(),
  )
];