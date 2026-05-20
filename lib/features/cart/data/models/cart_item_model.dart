class CartItemModel {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final double? discountPrice;
  final String? unit;
  int quantity;
  final int maxStock;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.discountPrice,
    this.unit,
    this.quantity = 1,
    this.maxStock = 99,
  });

  double get effectivePrice => discountPrice ?? price;
  double get totalPrice => effectivePrice * quantity;
  double get originalTotal => price * quantity;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'imageUrl': imageUrl,
    'price': price,
    'discountPrice': discountPrice,
    'unit': unit,
    'quantity': quantity,
    'maxStock': maxStock,
  };

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    productId: json['productId'] ?? '',
    name: json['name'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    discountPrice: (json['discountPrice'] as num?)?.toDouble(),
    unit: json['unit'],
    quantity: json['quantity'] ?? 1,
    maxStock: json['maxStock'] ?? 99,
  );

  CartItemModel copyWith({int? quantity}) => CartItemModel(
    productId: productId, name: name, imageUrl: imageUrl,
    price: price, discountPrice: discountPrice, unit: unit,
    quantity: quantity ?? this.quantity, maxStock: maxStock,
  );
}
