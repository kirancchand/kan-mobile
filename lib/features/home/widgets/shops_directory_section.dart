import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/contact_actions.dart';
import '../../../data/models/shop_org.dart';
import '../organisation_detail_screen.dart';
import '../../../core/theme/app_icons.dart';

class ShopsDirectorySection extends StatelessWidget {
  final List<ShopOrg> shops;

  const ShopsDirectorySection({super.key, required this.shops});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: shops.asMap().entries.map((entry) {
        final index = entry.key;
        final shop = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
          child: AppCard(
            child: ListTile(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => OrganisationDetailScreen(organisation: shop),
              )),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.ms, vertical: AppSpacing.xs + 2),
              leading: shop.imageUrl.isEmpty
                  ? const SizedBox(
                      width: 52, height: 52, child: Icon(AppIcons.buildings))
                  : AppNetworkImage(
                      url: shop.imageUrl,
                      width: 52,
                      height: 52,
                      borderRadius: AppRadius.md),
              title: Text(shop.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                      [
                        shop.organisationType?.isNotEmpty == true
                            ? shop.organisationType!
                            : shop.category.label,
                        if (shop.timings.isNotEmpty) shop.timings
                      ].join(' • '),
                      style: textTheme.bodySmall),
                  if (shop.address.isNotEmpty)
                    Text(shop.address,
                        style: textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
              isThreeLine: true,
              trailing: IconButton.filledTonal(
                tooltip: 'Call ${shop.name}',
                icon: const Icon(AppIcons.phoneCall, size: 20),
                onPressed: shop.phone.isEmpty
                    ? null
                    : () => showCallSheet(context,
                        name: shop.name, phone: shop.phone),
              ),
            ),
          ),
        )
            .animate(delay: (index * 40).ms)
            .fadeIn(duration: 250.ms)
            .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
      }).toList(),
    );
  }
}
