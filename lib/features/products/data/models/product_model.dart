import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String category;
  final String? categoryId;
  final String imageUrl;
  final List<String> imageUrls;
  final int stock;
  final String? unit;
  final double? rating;
  final int? reviewCount;
  final bool isFeatured;
  final bool isPrescription;
  final bool isActive;
  final String? pharmacyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.category,
    this.categoryId,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.stock,
    this.unit,
    this.rating,
    this.reviewCount,
    this.isFeatured = false,
    this.isPrescription = false,
    this.isActive = true,
    this.pharmacyId,
    required this.createdAt,
    required this.updatedAt,
  });

  double get effectivePrice => discountPrice ?? price;
  double get discountPercent =>
      discountPrice != null ? ((price - discountPrice!) / price * 100).roundToDouble() : 0;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  bool get inStock => stock > 0;
  bool get isLowStock => stock > 0 && stock <= 5;

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      discountPrice: (data['discountPrice'] as num?)?.toDouble(),
      category: data['category'] ?? '',
      categoryId: data['categoryId'],
      imageUrl: data['imageUrl'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      stock: (data['stock'] ?? 0).toInt(),
      unit: data['unit'],
      rating: (data['rating'] as num?)?.toDouble(),
      reviewCount: (data['reviewCount'] as num?)?.toInt(),
      isFeatured: data['isFeatured'] ?? false,
      isPrescription: data['isPrescription'] ?? false,
      isActive: data['isActive'] ?? true,
      pharmacyId: data['pharmacyId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
    'price': price,
    if (discountPrice != null) 'discountPrice': discountPrice,
    'category': category,
    'categoryId': categoryId,
    'imageUrl': imageUrl,
    'imageUrls': imageUrls,
    'stock': stock,
    'unit': unit,
    'rating': rating,
    'reviewCount': reviewCount,
    'isFeatured': isFeatured,
    'isPrescription': isPrescription,
    'isActive': isActive,
    'pharmacyId': pharmacyId,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? category,
    String? categoryId,
    String? imageUrl,
    List<String>? imageUrls,
    int? stock,
    String? unit,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    bool? isPrescription,
    bool? isActive,
    String? pharmacyId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ProductModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        price: price ?? this.price,
        discountPrice: discountPrice ?? this.discountPrice,
        category: category ?? this.category,
        categoryId: categoryId ?? this.categoryId,
        imageUrl: imageUrl ?? this.imageUrl,
        imageUrls: imageUrls ?? this.imageUrls,
        stock: stock ?? this.stock,
        unit: unit ?? this.unit,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        isFeatured: isFeatured ?? this.isFeatured,
        isPrescription: isPrescription ?? this.isPrescription,
        isActive: isActive ?? this.isActive,
        pharmacyId: pharmacyId ?? this.pharmacyId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
