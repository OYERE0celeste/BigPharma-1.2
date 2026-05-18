import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/notification_provider.dart';
import '../models/notification_model.dart';

class NotificationPanel extends StatelessWidget {
  final Function(String, dynamic)? onTap;
  const NotificationPanel({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.notifications;

    final size = MediaQuery.of(context).size;
    final panelWidth = size.width < 400 ? size.width * 0.92 : 350.0;
    final panelHeight = size.height < 500 ? size.height * 0.75 : 450.0;

    return Container(
      width: panelWidth,
      height: panelHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                Text(
                  'Notifications',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (notificationProvider.unreadCount > 0)
                  TextButton(
                    onPressed: () => notificationProvider.markAllAsRead(),
                    child: const Text('Tout marquer comme lu'),
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
        ],
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
            : Theme.of(context).primaryColor.withOpacity(0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(context),
            const SizedBox(width: 12),
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
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color,
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
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
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
      case 'invoice':
        iconData = Icons.receipt_long_outlined;
        color = Colors.green;
        break;
      case 'review':
        iconData = Icons.star_outline_rounded;
        color = Colors.amber.shade700;
        break;
      case 'complaint':
        iconData = Icons.report_problem_outlined;
        color = Colors.deepOrange;
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
}
