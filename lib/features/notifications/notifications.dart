import 'package:fishcast/core/widgets/bar/notifbar.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: NotificationBar(),
      body: Center(
        child: Text("Notifications", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
