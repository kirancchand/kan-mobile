import 'package:flutter/material.dart';
import '../../core/widgets/village_top_bar.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/icon_badge.dart';
import '../../core/widgets/textured_surface.dart';
import '../../state/app_state.dart';
import 'location_group_screen.dart';
import 'my_listings_screen.dart';
import 'my_organisations_screen.dart';
import 'my_orders_screen.dart';
import 'received_orders_screen.dart';
import 'settings_screen.dart';
import '../home/add_organisation_screen.dart';
import '../../core/widgets/app_card.dart';
import '../../core/theme/app_icons.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const VillageTopBar(subtitle: Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg),
        children: [
          TexturedSurface(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.18),
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(AppIcons.user,
                      color: AppColors.white, size: 30),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YOUR COMMUNITY CORNER',
                          style: textTheme.labelSmall?.copyWith(
                              color: AppColors.white,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(user?.name ?? 'Guest',
                          style: textTheme.headlineSmall
                              ?.copyWith(color: AppColors.white)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(user?.phone ?? '',
                          style: textTheme.bodyMedium
                              ?.copyWith(color: AppColors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ProfileTile(
            icon: AppIcons.usersThree,
            title: 'Add Organisation',
            subtitle: 'List your organisation in the village directory',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddOrganisationScreen())),
          ),
          _ProfileTile(
            icon: AppIcons.usersThree,
            title: 'My organisations',
            subtitle: 'Organisations you are a member of',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MyOrganisationsScreen())),
          ),
          _ProfileTile(
            icon: AppIcons.listBullets,
            title: 'My Listings',
            subtitle: 'Items, books, rides & videos you posted',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MyListingsScreen())),
          ),
          _ProfileTile(
            icon: AppIcons.receipt,
            title: 'My Orders / Requests',
            subtitle: 'Purchases and delivery requests you made',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MyOrdersScreen())),
          ),
          _ProfileTile(
            icon: AppIcons.storefront,
            title: 'Received Orders',
            subtitle: 'Orders customers placed for your items',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ReceivedOrdersScreen())),
          ),
          _ProfileTile(
            icon: AppIcons.usersThree,
            title: 'My Location & WhatsApp Group',
            subtitle: 'Your village and group assignment',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LocationGroupScreen())),
          ),
          _ProfileTile(
            icon: AppIcons.gearSix,
            title: 'Settings',
            subtitle: 'App preferences',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ProfileTile(
            icon: AppIcons.signOut,
            title: 'Sign Out',
            subtitle: 'Return to the registration screen',
            tone: AppTone.attention,
            onTap: () => _confirmSignOut(context),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('You will need to register again to use the app.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AppState>().signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final AppTone tone;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.tone = AppTone.brand,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.ms),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
        leading: IconBadge(icon: icon, tone: tone),
        title: Text(title,
            style: tone == AppTone.attention
                ? Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: context.tokens.ink(AppTone.attention))
                : null),
        subtitle: Text(subtitle),
        trailing: const Icon(AppIcons.caretRight, size: 18),
        onTap: onTap,
      ),
    );
  }
}
