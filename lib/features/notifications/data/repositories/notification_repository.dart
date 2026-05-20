import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Use untyped CollectionReference and handle conversion manually
  CollectionReference get _notifications => _firestore.collection('notifications');

  /// Get notifications for a specific user (or admin)
  Stream<List<AppNotification>> getUserNotifications(String userId) {
    return _notifications
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => AppNotification.fromFirestore(doc)).toList());
  }

  /// Get unread notification count for a user
  Stream<int> getUnreadCount(String userId) {
    return _notifications
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Create a notification
  Future<void> createNotification(AppNotification notification) async {
    await _notifications.doc(notification.id).set(notification.toFirestore());
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    await _notifications.doc(notificationId).update({'isRead': true});
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    final unread = await _notifications
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _notifications.doc(notificationId).delete();
  }

  /// Delete all notifications for a user
  Future<void> clearAll(String userId) async {
    final all = await _notifications
        .where('userId', isEqualTo: userId)
        .get();

    final batch = _firestore.batch();
    for (final doc in all.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
