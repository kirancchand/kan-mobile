import 'delivery_order_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/contact_actions.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/service_type.dart';
import '../../state/cart_state.dart';
import '../../state/delivery_session.dart';

class DeliveryDashboard extends StatefulWidget {
  const DeliveryDashboard({super.key});
  @override
  State<DeliveryDashboard> createState() => _DeliveryDashboardState();
}

class _DeliveryDashboardState extends State<DeliveryDashboard> {
  PurchaseStatus? _filter;

  void _pickUp(String orderId, String itemKey) {
    try {
      context.read<CartState>().pickUp(orderId, itemKey);
    } on StateError catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<DeliverySession>();
    final courier = session.currentUser;
    if (courier == null) {
      return const Scaffold(
          body: Center(child: Text('Delivery login required')));
    }
    final orders = context.watch<CartState>().deliveryOrders;
    final entries = [
      for (final order in orders)
        for (final line in order.lines)
          if (_filter == null || line.status == _filter)
            (order: order, line: line)
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Regional deliveries'), actions: [
        IconButton(
            tooltip: 'Sign out of delivery',
            icon: const Icon(AppIcons.signOut),
            onPressed: session.signOut),
      ]),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(courier.regionName,
                        style: Theme.of(context).textTheme.headlineSmall),
                    Text(courier.name),
                    const SizedBox(height: 8),
                    const Text(
                        'Products marked ready for shipping in your pickup region. Contact the seller to arrange collection.'),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      ChoiceChip(
                          label: const Text('All'),
                          selected: _filter == null,
                          onSelected: (_) => setState(() => _filter = null)),
                      ChoiceChip(
                          label: const Text('Awaiting pickup'),
                          selected: _filter == PurchaseStatus.readyForShipping,
                          onSelected: (_) => setState(
                              () => _filter = PurchaseStatus.readyForShipping)),
                      ChoiceChip(
                          label: const Text('Picked up'),
                          selected: _filter == PurchaseStatus.pickedUp,
                          onSelected: (_) => setState(
                              () => _filter = PurchaseStatus.pickedUp)),
                    ]),
                  ],
                ))),
        if (entries.isEmpty)
          const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: AppIcons.truck,
                title: 'No matching deliveries',
                message:
                    'Ready products in your assigned region and your picked-up products appear here.',
              ))
        else
          SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final line = entry.line;
                    return AppCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(line.item.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                Text(
                                    '${entry.order.id} • ${line.item.service.label}'),
                                Text('Quantity: ${line.quantity}'),
                                Text('Seller: ${line.item.seller}'),
                                Text('Buyer: ${entry.order.buyerName}'),
                                Text('Status: ${line.status.label}'),
                                if (line.pickedUpAt != null)
                                  Text(
                                      'Picked up ${Formatters.dateTime(line.pickedUpAt!)}'),
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  icon: Icon(
                                      line.status == PurchaseStatus.pickedUp
                                          ? Icons.check_circle_outline
                                          : AppIcons.truck),
                                  label: Text(
                                      line.status == PurchaseStatus.pickedUp
                                          ? 'Picked up'
                                          : 'Pick up'),
                                  onPressed: line.status ==
                                          PurchaseStatus.readyForShipping
                                      ? () =>
                                          _pickUp(entry.order.id, line.item.key)
                                      : null,
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.map_outlined),
                                  label: const Text('View map & distances'),
                                  onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                          builder: (_) =>
                                              DeliveryOrderMapScreen(
                                                  orderId: entry.order.id,
                                                  itemKey: line.item.key))),
                                ),
                                if (line.item.sellerPhone.isNotEmpty)
                                  TextButton.icon(
                                      icon: const Icon(AppIcons.phoneCallBold),
                                      label: const Text('Contact Seller'),
                                      onPressed: () => showCallSheet(context,
                                          name: line.item.seller,
                                          phone: line.item.sellerPhone)),
                                if (entry.order.buyerPhone.isNotEmpty)
                                  TextButton.icon(
                                      icon: const Icon(AppIcons.phoneCallBold),
                                      label: const Text('Contact Buyer'),
                                      onPressed: () => showCallSheet(context,
                                          name: entry.order.buyerName,
                                          phone: entry.order.buyerPhone)),
                              ]),
                        ));
                  })),
      ]),
    );
  }
}
