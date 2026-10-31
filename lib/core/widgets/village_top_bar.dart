import 'package:provider/provider.dart';
import '../../state/cart_state.dart';
import 'package:flutter/material.dart';

import '../../features/cart/cart_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../theme/app_icons.dart';
import '../theme/app_tokens.dart';

/// Shared resident header. Detail pages retain their own back navigation.
class VillageTopBar extends StatelessWidget implements PreferredSizeWidget {
  const VillageTopBar({super.key, required this.subtitle});

  final Widget subtitle;

  @override
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 88,
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Village Connect',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          DefaultTextStyle(
            style: theme.textTheme.bodySmall!
                .copyWith(color: context.tokens.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: subtitle,
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: const Icon(AppIcons.bell),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const NotificationsScreen())),
        ),
        IconButton(
          tooltip: 'Cart',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: Badge.count(
              count: context.watch<CartState?>()?.count ?? 0,
              isLabelVisible: (context.watch<CartState?>()?.count ?? 0) > 0,
              child: const Icon(AppIcons.shoppingCart)),
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CartScreen())),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: Size.zero,
        child: Divider(height: 1, thickness: 1, color: context.tokens.border),
      ),
    );
  }
}
