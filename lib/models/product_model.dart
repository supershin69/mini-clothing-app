class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String gender;
  final List<String> sizes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.gender,
    required this.sizes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    var sizesFromJson = json['sizes'] as List<dynamic>? ?? [];
    List<String> sizesList = sizesFromJson.map((size) => size as String? ?? '').where((size) => size.isNotEmpty).toList();
    
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      gender: json['gender'] as String? ?? 'unisex',
      sizes: sizesList,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
    );
  }


}

  final List<ProductModel> mockProducts = [
  ProductModel(
    id: "p1",
    name: "Oversized Vintage Hoodie",
    price: 35.00,
    description: "Premium heavy cotton hoodie with drop shoulders. Perfect for minimalist streetwear vibe.",
    imageUrl: "https://images.unsplash.com/photo-1556905055-8f358a7a47b2?q=80&w=500&auto=format&fit=crop",
    gender: "unisex",
    sizes: ["S", "M", "L", "XL"],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  ProductModel(
    id: "p2",
    name: "Classic Denim Jacket",
    price: 48.50,
    description: "Timeless blue denim jacket with a relaxed fit, silver hardware, and durable double-stitching.",
    imageUrl: "https://images.unsplash.com/photo-1576995853123-5a10305d93c0?q=80&w=500&auto=format&fit=crop",
    gender: "unisex",
    sizes: ["M", "L", "XL"],
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now(),
  ),
  ProductModel(
    id: "p3",
    name: "Minimalist Graphic Tee",
    price: 18.00,
    description: "100% breathable organic cotton tee featuring a subtle abstract chest print.",
    imageUrl: "https://images.unsplash.com/photo-1521572267360-ee0c2909d518?q=80&w=500&auto=format&fit=crop",
    gender: "men",
    sizes: ["S", "M", "L"],
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now(),
  ),
  ProductModel(
    id: "p4",
    name: "Cropped Knit Cardigan",
    price: 26.99,
    description: "Soft, ribbed knit cardigan with tortoiseshell buttons. Cozy yet stylish option for daily wear.",
    imageUrl: "https://images.unsplash.com/photo-1614975058789-41316d0e2e9c?q=80&w=500&auto=format&fit=crop",
    gender: "women",
    sizes: ["XS", "S", "M"],
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    updatedAt: DateTime.now(),
  ),
  ProductModel(
    id: "p5",
    name: "Urban Cargo Pants",
    price: 42.00,
    description: "", // 💡 မင်းရဲ့ Optional Design ကို စမ်းဖို့အတွက် တန်ဖိုးအလွတ် ထားခဲ့တာပါ bro
    imageUrl: "https://images.unsplash.com/photo-1517423738875-5ce310acd3da?q=80&w=500&auto=format&fit=crop",
    gender: "unisex",
    sizes: ["S", "M", "L", "XL"],
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    updatedAt: DateTime.now(),
  ),
];