import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, confirmed, preparing, outForDelivery, delivered, cancelled }

class OrderItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final int quantity;
  final String? unit;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.unit,
  });

  double get total => price * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> data) => OrderItem(
    productId: data['productId'] ?? '',
    productName: data['productName'] ?? '',
    imageUrl: data['imageUrl'] ?? '',
    price: (data['price'] ?? 0).toDouble(),
    quantity: (data['quantity'] ?? 1).toInt(),
    unit: data['unit'],
  );

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'imageUrl': imageUrl,
    'price': price,
    'quantity': quantity,
    'unit': unit,
  };
}

class OrderModel {
  final String id;
  final String userId;
  final String? userEmail;
  final String? userName;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final String? deliveryAddress;
  final String? city;
  final String? phone;
  final String? deliveryNote;
  final String paymentMethod;
  final String? pharmacyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    this.userEmail,
    this.userName,
    required this.items,
    required this.subtotal,
    this.deliveryFee = 2.50,
    required this.total,
    this.status = OrderStatus.pending,
    this.deliveryAddress,
    this.city,
    this.phone,
    this.deliveryNote,
    this.paymentMethod = 'Cash on Delivery',
    this.pharmacyId,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }

  bool get isActive => status != OrderStatus.cancelled && status != OrderStatus.delivered;

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'],
      userName: data['userName'],
      items: (data['items'] as List<dynamic>?)?.map((i) => OrderItem.fromMap(i)).toList() ?? [],
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 2.50).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: data['deliveryAddress'],
      city: data['city'],
      phone: data['phone'],
      deliveryNote: data['deliveryNote'],
      paymentMethod: data['paymentMethod'] ?? 'Cash on Delivery',
      pharmacyId: data['pharmacyId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'userEmail': userEmail,
    'userName': userName,
    'items': items.map((i) => i.toMap()).toList(),
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'total': total,
    'status': status.name,
    'deliveryAddress': deliveryAddress,
    'city': city,
    'phone': phone,
    'deliveryNote': deliveryNote,
    'paymentMethod': paymentMethod,
    'pharmacyId': pharmacyId,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  OrderModel copyWith({OrderStatus? status, DateTime? updatedAt}) => OrderModel(
    id: id, userId: userId, userEmail: userEmail, userName: userName,
    items: items, subtotal: subtotal, deliveryFee: deliveryFee, total: total,
    status: status ?? this.status,
    deliveryAddress: deliveryAddress, city: city, phone: phone,
    deliveryNote: deliveryNote, paymentMethod: paymentMethod,
    pharmacyId: pharmacyId, createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );
}
