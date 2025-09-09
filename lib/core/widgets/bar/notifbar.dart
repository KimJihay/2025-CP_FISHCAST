import 'package:flutter/material.dart';

class NotificationBar extends StatelessWidget implements PreferredSizeWidget {
  const NotificationBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        "Notifications",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      actions: [
        TextButton.icon(
          onPressed: () {
            // TODO: handle "mark all as read"
          },
          icon: const Icon(Icons.mark_email_read_outlined, size: 20),
          label: const Text("Mark all as read"),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
