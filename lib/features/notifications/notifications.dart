import 'package:fishcast/core/widgets/bar/notifbar.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Sample notification data
  List<Map<String, dynamic>> unreadNotifications = [
    {
      'icon': Icons.trending_up,
      'title': 'Price Surge Alert',
      'description': 'Tilapia prices have increased by 15% in the market',
    },
    {
      'icon': Icons.warning,
      'title': 'Low Supply Warning',
      'description': 'Galunggong supply is running low in your area',
    },
    {
      'icon': Icons.new_releases,
      'title': 'New Market Data',
      'description': 'Latest fish market data has been updated',
    },
  ];

  List<Map<String, dynamic>> readNotifications = [
    {
      'icon': Icons.check_circle,
      'title': 'Price Drop Alert',
      'description': 'Bangus prices have decreased by 8%',
    },
    {
      'icon': Icons.info,
      'title': 'Market Update',
      'description': 'Weekly market summary is now available',
    },
  ];

  void _markAllAsRead() {
    setState(() {
      // Move all unread notifications to read
      readNotifications.insertAll(0, unreadNotifications);
      unreadNotifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NotificationBar(
        onMarkAllAsRead: _markAllAsRead,
        hasUnreadNotifications: unreadNotifications.isNotEmpty,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Unread Section
          _buildSectionHeader('Unread', unreadNotifications.length),
          const SizedBox(height: 8),
          ...unreadNotifications.map(
            (notification) => _buildNotificationTile(notification, true),
          ),
          const SizedBox(height: 24),

          // Divider between sections
          const Row(
            children: [
              Expanded(child: Divider(color: Colors.grey)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Read',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 24),

          // Read Section
          _buildSectionHeader('Read', readNotifications.length),
          const SizedBox(height: 8),
          ...readNotifications.map(
            (notification) => _buildNotificationTile(notification, false),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationTile(
    Map<String, dynamic> notification,
    bool isUnread,
  ) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isUnread
                  ? Colors.blue.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              notification['icon'],
              color: isUnread ? Colors.blue : Colors.grey,
              size: 20,
            ),
          ),
          title: Text(
            notification['title'],
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification['description'],
                style: TextStyle(
                  color: isUnread ? Colors.black87 : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          trailing: isUnread
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () {
            // Handle notification tap
            setState(() {
              if (isUnread) {
                // Move from unread to read
                unreadNotifications.remove(notification);
                readNotifications.insert(0, notification);
              }
            });
          },
        ),
        if ((unreadNotifications.isNotEmpty &&
                notification != unreadNotifications.last) &&
            (readNotifications.isNotEmpty &&
                notification != readNotifications.last))
          const Divider(height: 1),
      ],
    );
  }
}
