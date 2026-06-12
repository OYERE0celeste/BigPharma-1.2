import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';
import 'app_colors.dart';
import 'bp_theme.dart';

class NotificationPanel extends StatelessWidget {
  final Function(String, dynamic)? onTap;
  const NotificationPanel({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.notifications;

    return Container(
      width: 350,
      height: 450,
      decoration: BoxDecoration(
        color: BpColors.surfaceStrong,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BpColors.primaryDark.withOpacity(0.25),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    if (notificationProvider.isLoading)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            BpColors.accent,
                          ),
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 18),
                      onPressed: () =>
                          notificationProvider.fetchNotifications(),
                      tooltip: 'Rafraîchir',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                    if (notificationProvider.unreadCount > 0)
                      TextButton(
                        onPressed: () => notificationProvider.markAllAsRead(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('Lire tout'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List
          Expanded(
            child: notifications.isEmpty
                ? const Center(child: Text('Aucune notification'))
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _NotificationTile(
                        notification: notification,
                        onTap: onTap,
                      );
                    },
                  ),
          ),

          const Divider(height: 1),
          // Footer
          _buildFooter('Historique complet', () {}),
        ],
      ),
    );
  }

  Widget _buildFooter(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: kPrimaryGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final Function(String, dynamic)? onTap;

  const _NotificationTile({required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationProvider>().markAsRead(notification.id);
        }
        onTap?.call(notification.type, notification.data);
      },

      child: Container(
        padding: const EdgeInsets.all(16),
        color: notification.isRead
            ? Colors.transparent
            : kPrimaryGreen.withOpacity(0.03),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isRead
                              ? FontWeight.w500
                              : FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDate(notification.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: BpColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: BpColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8, top: 4),
                decoration: const BoxDecoration(
                  color: kPrimaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color color;

    switch (notification.type) {
      case 'order':
        iconData = Icons.shopping_bag_outlined;
        color = Colors.blue;
        break;
      case 'support':
        iconData = Icons.support_agent;
        color = Colors.orange;
        break;
      case 'stock':
        iconData = Icons.inventory_2_outlined;
        color = Colors.red;
        break;
      case 'review':
        iconData = Icons.star_outline_rounded;
        color = Colors.amber.shade700;
        break;
      case 'complaint':
        iconData = Icons.report_problem_outlined;
        color = Colors.deepOrange;
        break;
      case 'invoice':
        iconData = Icons.receipt_long_outlined;
        color = Colors.green;
        break;
      default:
        iconData = Icons.notifications_none;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }

  void _handleNavigation(BuildContext context) {
    // Close the notification panel first
    Navigator.of(context).pop();

    // Navigate based on notification type and data
    switch (notification.type) {
      case 'order':
        if (notification.data.containsKey('orderId')) {
          // Navigate to order details
          Navigator.of(
            context,
          ).pushNamed('/orders', arguments: notification.data['orderId']);
        }
        break;
      case 'support':
        if (notification.data.containsKey('questionId')) {
          // Navigate to support question details
          Navigator.of(
            context,
          ).pushNamed('/support', arguments: notification.data['questionId']);
        }
        break;
      case 'stock':
        if (notification.data.containsKey('productId')) {
          // Navigate to product details
          Navigator.of(
            context,
          ).pushNamed('/products', arguments: notification.data['productId']);
        }
        break;
      default:
        // For system notifications, just close the panel
        break;
    }
  }
}
