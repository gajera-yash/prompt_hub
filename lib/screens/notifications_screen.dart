import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.bellOff, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No notifications', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
