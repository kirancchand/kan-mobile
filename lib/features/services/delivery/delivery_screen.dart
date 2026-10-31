import '../../../core/widgets/media_gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/semantic_tones.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_list_placeholder.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/delivery_order.dart';
import '../../../data/repositories/delivery_repository.dart';
import 'request_delivery_screen.dart';
import '../../../core/theme/app_icons.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  late Future<List<DeliveryOrder>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = context.read<DeliveryRepository>().getOrders();
  }

  Future<void> _openRequestScreen() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RequestDeliveryScreen()),
    );
    if (created == true) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRequestScreen,
        icon: const Icon(AppIcons.plusBold),
        label: const Text('Request Delivery'),
      ),
      body: FutureBuilder<List<DeliveryOrder>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(onRetry: () => setState(_reload));
          }
          if (!snapshot.hasData) return const ShimmerListPlaceholder();
          final orders = snapshot.data!;
          if (orders.isEmpty) {
            return EmptyState(
              icon: AppIcons.truck,
              tone: AppTone.lime,
              title: 'No delivery requests yet',
              message:
                  'Need something picked up and dropped off in the village? Request a delivery for a flat fee.',
              actionLabel: 'Request Delivery',
              onAction: _openRequestScreen,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.ms,
                AppSpacing.md, AppSpacing.fabClearance),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.ms),
            itemBuilder: (context, index) {
              final order = orders[index];
              final textTheme = Theme.of(context).textTheme;
              final tokens = context.tokens;
              return AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MediaGallery(attachments: order.attachments),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.itemDescription,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            StatusChip(
                                label: order.status.label,
                                tone: order.status.tone),
                          ]),
                      const SizedBox(height: AppSpacing.ms),
                      Row(
                        children: [
                          Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: tokens.brand, shape: BoxShape.circle)),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                              child: Text('Pickup: ${order.pickupAddress}',
                                  style: textTheme.bodySmall)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 3),
                        child: SizedBox(
                            height: 16, child: VerticalDivider(width: 1)),
                      ),
                      Row(
                        children: [
                          Icon(AppIcons.mapPin,
                              size: 8, color: tokens.ink(AppTone.attention)),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                              child: Text('Drop: ${order.dropAddress}',
                                  style: textTheme.bodySmall)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.ms),
                      Wrap(spacing: 16, runSpacing: 8, children: [
                        Text('Fee: ${Formatters.currency(order.fee)}',
                            style: textTheme.titleSmall),
                        Text(Formatters.relative(order.requestedAt),
                            style: textTheme.bodySmall),
                      ]),
                    ],
                  ),
                ),
              )
                  .animate(delay: (index * 40).ms)
                  .fadeIn(duration: 250.ms)
                  .slideY(begin: 0.06, end: 0, curve: Curves.easeOut);
            },
          );
        },
      ),
    );
  }
}
