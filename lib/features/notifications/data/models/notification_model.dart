import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  orderPlaced,
  orderConfirmed,
  orderPreparing,
  orderOutForDelivery,
  orderDelivered,
  orderCancelled,
  lowStockAlert,
  newOrderForAdmin,
}

class AppNotification {
  final String id;
  final String userId;
  final String? orderId;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    this.orderId,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = false,
    required this.createdAt,
  });

  String get typeName {
    switch (type) {
      case NotificationType.orderPlaced: return 'order_placed';
      case NotificationType.orderConfirmed: return 'order_confirmed';
      case NotificationType.orderPreparing: return 'order_preparing';
      case NotificationType.orderOutForDelivery: return 'order_out_for_delivery';
      case NotificationType.orderDelivered: return 'order_delivered';
      case NotificationType.orderCancelled: return 'order_cancelled';
      case NotificationType.lowStockAlert: return 'low_stock_alert';
      case NotificationType.newOrderForAdmin: return 'new_order_admin';
    }
  }

  IconType get iconType {
    switch (type) {
      case NotificationType.orderPlaced: return IconType.shoppingBag;
      case NotificationType.orderConfirmed: return IconType.checkCircle;
      case NotificationType.orderPreparing: return IconType.inventory;
      case NotificationType.orderOutForDelivery: return IconType.delivery;
      case NotificationType.orderDelivered: return IconType.checkDouble;
      case NotificationType.orderCancelled: return IconType.cancel;
      case NotificationType.lowStockAlert: return IconType.warning;
      case NotificationType.newOrderForAdmin: return IconType.notification;
    }
  }

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      orderId: data['orderId'],
      type: _parseType(data['type'] ?? 'order_placed'),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    if (orderId != null) 'orderId': orderId,
    'type': typeName,
    'title': title,
    'body': body,
    'isRead': isRead,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    userId: userId,
    orderId: orderId,
    type: type,
    title: title,
    body: body,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );

  static NotificationType _parseType(String value) {
    return NotificationType.values.firstWhere(
      (t) => t.name == _typeFromString(value),
      orElse: () => NotificationType.orderPlaced,
    );
  }

  static String _typeFromString(String value) {
    switch (value) {
      case 'order_placed': return 'orderPlaced';
      case 'order_confirmed': return 'orderConfirmed';
      case 'order_preparing': return 'orderPreparing';
      case 'order_out_for_delivery': return 'orderOutForDelivery';
      case 'order_delivered': return 'orderDelivered';
      case 'order_cancelled': return 'orderCancelled';
      case 'low_stock_alert': return 'lowStockAlert';
      case 'new_order_admin': return 'newOrderForAdmin';
      default: return 'orderPlaced';
    }
  }
}

enum IconType {
  shoppingBag,
  checkCircle,
  inventory,
  delivery,
  checkDouble,
  cancel,
  warning,
  notification,
}
