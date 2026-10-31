import 'package:flutter/material.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: EmptyState(
          icon: AppIcons.bell,
          title: 'You’re all caught up',
          message:
              'No notifications yet. You can find village events and updates on Home.',
          actionLabel: 'Go back',
          onAction: () => Navigator.of(context).pop(),
        ),
      );
}
