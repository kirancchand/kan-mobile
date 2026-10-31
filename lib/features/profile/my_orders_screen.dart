import '../../state/cart_state.dart';
import '../cart/purchase_history.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/semantic_tones.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/status_chip.dart';
import '../../data/models/delivery_order.dart';
import '../../data/repositories/delivery_repository.dart';
import '../../state/app_state.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/shimmer_list_placeholder.dart';
import '../../core/theme/app_icons.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  late Future<List<DeliveryOrder>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<DeliveryOrder>> _load() async {
    final userName = context.read<AppState>().currentUser?.name;
    final orders = await context.read<DeliveryRepository>().getOrders();
    return orders.where((o) => o.requestedBy == userName).toList();
  }

  @override
  Widget build(BuildContext context) {
    final purchases = context.watch<CartState>().orders;
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders / Requests')),
      body: FutureBuilder<List<DeliveryOrder>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(onRetry: () => setState(() {
                  _future = _load();
                }));
          }
          if (!snapshot.hasData) return const ShimmerListPlaceholder();
          final orders = snapshot.data!;
          if (orders.isEmpty && purchases.isEmpty) {
            return const EmptyState(
              icon: AppIcons.receipt,
              tone: AppTone.lime,
              title: 'No orders or requests yet',
              message: 'Purchases and delivery requests will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: purchases.length + orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.ms),
            itemBuilder: (context, index) {
              if (index < purchases.length) {
                return PurchaseOrderCard(order: purchases[index]);
              }
              final order = orders[index - purchases.length];
              return AppCard(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  title: Text(order.itemDescription),
                  subtitle: Text(
                      '${order.pickupAddress} → ${order.dropAddress}\n${Formatters.currency(order.fee)} • ${Formatters.relative(order.requestedAt)}'),
                  isThreeLine: true,
                  trailing: StatusChip(
                      label: order.status.label, tone: order.status.tone),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
