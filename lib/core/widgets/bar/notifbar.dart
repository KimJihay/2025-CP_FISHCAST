import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class NotificationBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMarkAllAsRead;
  final bool hasUnreadNotifications;
  
  const NotificationBar({
    super.key,
    this.onMarkAllAsRead,
    this.hasUnreadNotifications = false,
  });

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
        if (hasUnreadNotifications)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Tooltip(
              message: 'Mark all as read',
              child: Material(
                color: kSecondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: onMarkAllAsRead,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.done_all,
                          size: 18,
                          color: kSecondaryColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Mark all',
                          style: TextStyle(
                            color: kSecondaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
