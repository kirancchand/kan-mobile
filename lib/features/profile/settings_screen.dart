import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_card.dart';
import '../../state/theme_state.dart';
import '../../core/theme/app_icons.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _whatsAppUpdates = true;

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeState>();
    final sectionLabelStyle = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(color: context.tokens.textMuted);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text('Notifications', style: sectionLabelStyle),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Ads, events & service updates'),
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  title: const Text('WhatsApp Group Updates'),
                  subtitle:
                      const Text('Get notified about your group activity'),
                  value: _whatsAppUpdates,
                  onChanged: (v) => setState(() => _whatsAppUpdates = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Appearance', style: sectionLabelStyle),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: Text(themeState.isDark ? 'On' : 'Off'),
              value: themeState.isDark,
              onChanged: (v) => themeState.setDark(v),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('About', style: sectionLabelStyle),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(AppIcons.info),
                  title: Text('App Version'),
                  subtitle: Text('1.0.0'),
                ),
                Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(AppIcons.lock),
                  title: Text('Privacy Policy'),
                  trailing: Icon(AppIcons.caretRight, size: 18),
                ),
                Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(AppIcons.fileText),
                  title: Text('Terms of Service'),
                  trailing: Icon(AppIcons.caretRight, size: 18),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 220.ms),
    );
  }
}
