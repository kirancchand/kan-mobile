import 'package:flutter/material.dart';
import '../../core/theme/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_tokens.dart';
import 'icon_badge.dart';

/// Phase 1 stand-in for actually dialing/opening WhatsApp (that needs
/// url_launcher + platform permissions, added in Phase 2 alongside real
/// backend integration). For now it just confirms the number to call so the
/// interaction flow is testable end-to-end.
void showCallSheet(BuildContext context,
    {required String name, required String phone}) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      final textTheme = Theme.of(context).textTheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(phone,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: context.tokens.textMuted)),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: const IconBadge(
                    icon: AppIcons.phoneCall, tone: AppTone.brand),
                title: const Text('Call'),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Call $phone using your phone app.')),
                  );
                },
              ),
              ListTile(
                leading: const IconBadge(
                    icon: AppIcons.chatCircle, tone: AppTone.info),
                title: const Text('Message'),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Messaging is not available in the app yet.')),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
