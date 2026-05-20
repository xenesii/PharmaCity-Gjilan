import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) => NotificationRepository());

/// Current user's notifications stream
final userNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);
  return ref.read(notificationRepositoryProvider).getUserNotifications(userId);
});

/// Unread notification count stream
final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value(0);
  return ref.read(notificationRepositoryProvider).getUnreadCount(userId);
});

/// Admin notifications — listen with a special admin ID prefix
final adminNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  return ref.read(notificationRepositoryProvider).getUserNotifications('admin');
});

/// Admin unread count
final adminUnreadCountProvider = StreamProvider<int>((ref) {
  return ref.read(notificationRepositoryProvider).getUnreadCount('admin');
});

/// Helper to create a notification (used by order creation/status updates)
final createNotificationProvider = Provider<CreateNotification>((ref) {
  return CreateNotification(ref.read(notificationRepositoryProvider));
});

class CreateNotification {
  final NotificationRepository _repository;

  CreateNotification(this._repository);

  Future<void> call({
    required String userId,
    String? orderId,
    required NotificationType type,
    required String title,
    required String body,
  }) async {
    final notification = AppNotification(
      id: const Uuid().v4(),
      userId: userId,
      orderId: orderId,
      type: type,
      title: title,
      body: body,
      createdAt: DateTime.now(),
    );
    await _repository.createNotification(notification);
  }
}

/// Mark a notification as read
final markNotificationReadProvider = Provider<void Function(String)>((ref) {
  final repo = ref.read(notificationRepositoryProvider);
  return (id) => repo.markAsRead(id);
});

/// Mark all notifications as read
final markAllNotificationsReadProvider = Provider<void Function(String)>((ref) {
  final repo = ref.read(notificationRepositoryProvider);
  return (userId) => repo.markAllAsRead(userId);
});
