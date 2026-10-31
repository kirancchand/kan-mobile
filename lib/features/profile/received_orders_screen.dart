import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/cart_money.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/contact_actions.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/service_type.dart';
import '../../state/cart_state.dart';

class ReceivedOrdersScreen extends StatelessWidget {
  const ReceivedOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartState>();
    final orders = cart.receivedOrders;
    return Scaffold(
      appBar: AppBar(title: const Text('Received Orders')),
      body: orders.isEmpty
          ? EmptyState(
              icon: AppIcons.receipt,
              title: cart.isSignedIn
                  ? 'No received orders yet'
                  : 'Sign in to see received orders',
              message:
                  'When someone buys an item you listed, their order will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Text('Orders for your items, newest first.');
                }
                final order = orders[index - 1];
                return AppCard(
                    child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('${order.id} • Order received',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(Formatters.dateTime(order.createdAt)),
                        const SizedBox(height: 12),
                        Text('Buyer: ${order.buyerName}'),
                        if (order.buyerPhone.isNotEmpty) Text(order.buyerPhone),
                        const Divider(height: 24),
                        for (final line in order.lines)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(line.item.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall),
                                  Text(line.item.service.label),
                                  Text(
                                      'Quantity: ${line.quantity} • ${cartMoney(line.item.unitPricePaise)} each'),
                                  Text(
                                      'Subtotal: ${cartMoney(line.totalPaise)}'),
                                  Text('Status: ${line.status.label}'),
                                  if (line.pickedUpByName != null)
                                    Text('Picked up by ${line.pickedUpByName}'),
                                ]),
                          ),
                        Text('Your order total: ${cartMoney(order.totalPaise)}',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Text('Order status: ${order.statusLabel}'),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          icon: Icon(!order.canMarkReady
                              ? Icons.check_circle_outline
                              : AppIcons.truck),
                          label: const Text('Ready for shipping',
                              textAlign: TextAlign.center),
                          onPressed: !order.canMarkReady
                              ? null
                              : () => cart.markReadyForShipping(order.id),
                        ),
                        if (order.buyerPhone.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            icon: const Icon(AppIcons.phoneCallBold),
                            label: const Text('Contact Buyer'),
                            onPressed: () => showCallSheet(context,
                                name: order.buyerName, phone: order.buyerPhone),
                          ),
                        ],
                      ]),
                ));
              },
            ),
    );
  }
}
