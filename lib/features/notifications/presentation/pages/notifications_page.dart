import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../providers/notification_providers.dart';
import '../../data/models/notification_model.dart';

class NotificationsPage extends ConsumerWidget {
  final bool isAdmin;

  const NotificationsPage({super.key, this.isAdmin = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(isAdmin ? adminNotificationsProvider : userNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Njoftimet',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          notificationsAsync.when(
            data: (notifs) {
              if (notifs.isEmpty) return const SizedBox.shrink();
              final hasUnread = notifs.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.done_all_rounded, size: 20),
                tooltip: 'Shëno të gjitha si të lexuara',
                onPressed: () {
                  final userId = isAdmin ? 'admin' : (FirebaseAuth.instance.currentUser?.uid ?? '');
                  if (userId.isNotEmpty) {
                    ref.read(markAllNotificationsReadProvider)(userId);
                  }
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyState(context);
          }
          return NotificationListView(notifications: notifications);
        },
        loading: () => const Center(child: CircularProgressIndicator()),          error: (e, _) => AppErrorWidget(
          message: 'Nuk mund të ngarkohen njoftimet',
          onRetry: () => ref.invalidate(isAdmin ? adminNotificationsProvider : userNotificationsProvider),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nuk keni njoftime',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Njoftimet për porositë tuaja do të shfaqen këtu',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => context.push('/orders'),
            icon: const Icon(Icons.receipt_long_outlined, size: 18),
            label: const Text('Shiko porositë'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationListView extends ConsumerWidget {
  final List<AppNotification> notifications;

  const NotificationListView({super.key, required this.notifications});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: notifications.length,
      itemBuilder: (ctx, i) => _NotificationCard(
        notification: notifications[i],
        onTap: () {
          // Mark as read
          if (!notifications[i].isRead) {
            ref.read(markNotificationReadProvider)(notifications[i].id);
          }
          // Navigate to order if applicable
          if (notifications[i].orderId != null) {
            context.push('/orders');
          }
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.white : AppColors.primarySurface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: !notification.isRead
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconBgColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconData,
                color: _iconBgColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary.withValues(alpha: 0.85),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _iconBgColor {
    switch (notification.iconType) {
      case IconType.shoppingBag:
        return AppColors.primary;
      case IconType.checkCircle:
        return AppColors.success;
      case IconType.inventory:
        return const Color(0xFF7C3AED);
      case IconType.delivery:
        return AppColors.info;
      case IconType.checkDouble:
        return AppColors.success;
      case IconType.cancel:
        return AppColors.error;
      case IconType.warning:
        return AppColors.warning;
      case IconType.notification:
        return AppColors.primary;
    }
  }

  IconData get _iconData {
    switch (notification.iconType) {
      case IconType.shoppingBag:
        return Icons.shopping_bag_rounded;
      case IconType.checkCircle:
        return Icons.check_circle_outline_rounded;
      case IconType.inventory:
        return Icons.inventory_2_rounded;
      case IconType.delivery:
        return Icons.local_shipping_rounded;
      case IconType.checkDouble:
        return Icons.checklist_rounded;
      case IconType.cancel:
        return Icons.cancel_outlined;
      case IconType.warning:
        return Icons.warning_amber_rounded;
      case IconType.notification:
        return Icons.notifications_active_rounded;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Tani';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m më parë';
    if (diff.inHours < 24) return '${diff.inHours}h më parë';
    if (diff.inDays < 7) return '${diff.inDays}d më parë';
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}
