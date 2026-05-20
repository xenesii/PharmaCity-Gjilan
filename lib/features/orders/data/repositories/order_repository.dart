import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../../../notifications/data/models/notification_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Use untyped CollectionReference and handle conversion manually
  CollectionReference get _orders => _firestore.collection('orders');
  CollectionReference get _notifications => _firestore.collection('notifications');

  Future<void> createOrder(OrderModel order) async {
    await _orders.doc(order.id).set(order.toFirestore());

    // Notify admin about new order
    final adminNotif = AppNotification(
      id: const Uuid().v4(),
      userId: 'admin',
      orderId: order.id,
      type: NotificationType.newOrderForAdmin,
      title: 'Porosi e re #${order.id.substring(0, 8).toUpperCase()}',
      body: '${order.userName ?? 'Klient'} porositi ${order.items.length} artikuj — Totali: \$${order.total.toStringAsFixed(2)}',
      createdAt: DateTime.now(),
    );
    await _notifications.doc(adminNotif.id).set(adminNotif.toFirestore());

    // Notify user their order was placed
    final userNotif = AppNotification(
      id: const Uuid().v4(),
      userId: order.userId,
      orderId: order.id,
      type: NotificationType.orderPlaced,
      title: 'Porosia u regjistrua',
      body: 'Porosia juaj #${order.id.substring(0, 8).toUpperCase()} u regjistrua me sukses. Totali: \$${order.total.toStringAsFixed(2)}',
      createdAt: DateTime.now(),
    );
    await _notifications.doc(userNotif.id).set(userNotif.toFirestore());
  }

  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _orders
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final orders = snap.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  Stream<List<OrderModel>> getAllOrders() {
    return _orders
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  Future<OrderModel?> getOrderById(String id) async {
    try {
      final doc = await _orders.doc(id).get();
      if (!doc.exists) return null;
      return OrderModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    // Get the order first to know the userId
    final doc = await _orders.doc(orderId).get();
    if (!doc.exists) return;
    final order = OrderModel.fromFirestore(doc);

    await _orders.doc(orderId).update({
      'status': status.name,
      'updatedAt': Timestamp.now(),
    });

    // Create notification for the user about status change
    final (title, body, type) = _notificationForStatus(status, order);
    final userNotif = AppNotification(
      id: const Uuid().v4(),
      userId: order.userId,
      orderId: orderId,
      type: type,
      title: title,
      body: body,
      createdAt: DateTime.now(),
    );
    await _notifications.doc(userNotif.id).set(userNotif.toFirestore());
  }

  (String, String, NotificationType) _notificationForStatus(OrderStatus status, OrderModel order) {
    switch (status) {
      case OrderStatus.confirmed:
        return (
          'Porosia u konfirmua',
          'Porosia juaj #${order.id.substring(0, 8).toUpperCase()} është konfirmuar. Po përgatitet për dërgesë.',
          NotificationType.orderConfirmed,
        );
      case OrderStatus.preparing:
        return (
          'Porosia në përgatitje',
          'Porosia juaj #${order.id.substring(0, 8).toUpperCase()} është duke u përgatitur.',
          NotificationType.orderPreparing,
        );
      case OrderStatus.outForDelivery:
        return (
          'Porosia në transport',
          'Porosia juaj #${order.id.substring(0, 8).toUpperCase()} është në rrugë për tek ju!',
          NotificationType.orderOutForDelivery,
        );
      case OrderStatus.delivered:
        return (
          'Porosia u dorëzua',
          'Porosia juaj #${order.id.substring(0, 8).toUpperCase()} u dorëzua me sukses. Faleminderit!',
          NotificationType.orderDelivered,
        );
      case OrderStatus.cancelled:
        return (
          'Porosia u anulua',
          'Porosia juaj #${order.id.substring(0, 8).toUpperCase()} është anuluar.',
          NotificationType.orderCancelled,
        );
      default:
        return (
          'Statusi i porosisë u përditësua',
          'Porosia juaj #${order.id.substring(0, 8).toUpperCase()} ka ndryshuar status.',
          NotificationType.orderPlaced,
        );
    }
  }

  Stream<int> getPendingOrdersCount() {
    return _orders
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Stream<int> getAllOrdersCount() {
    return _orders.snapshots().map((snap) => snap.docs.length);
  }
}
