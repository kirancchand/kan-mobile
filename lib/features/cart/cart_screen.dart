import '../../core/widgets/map_location_field.dart';
import '../../core/utils/cart_money.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/service_type.dart';
import '../../state/cart_state.dart';
import '../services/service_router.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Your cart')),
      body: cart.lines.isEmpty
          ? EmptyState(
              icon: AppIcons.shoppingCart,
              title: 'Your cart is empty',
              message:
                  'Add items from local listings, then review your purchase here.',
              actionLabel: 'Browse local listings',
              onAction: () => openService(context, ServiceType.buySell),
            )
          : ListView(padding: const EdgeInsets.all(16), children: [
              for (final line in cart.lines)
                Card(
                    child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(line.item.title,
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(
                            '${line.item.service.label} • ${line.item.seller}'),
                        Text('${cartMoney(line.item.unitPricePaise)} each'),
                        if (!line.item.isAvailable)
                          const Text('Unavailable — remove before checkout'),
                        Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            children: [
                              IconButton(
                                  tooltip: 'Decrease ${line.item.title}',
                                  onPressed: () => cart.setQuantity(
                                      line.item.key, line.quantity - 1),
                                  icon: const Icon(Icons.remove)),
                              Text('${line.quantity}',
                                  semanticsLabel: 'Quantity ${line.quantity}'),
                              IconButton(
                                  tooltip: 'Increase ${line.item.title}',
                                  onPressed: line.quantity < 99
                                      ? () => cart.setQuantity(
                                          line.item.key, line.quantity + 1)
                                      : null,
                                  icon: const Icon(Icons.add)),
                              Text(cartMoney(line.totalPaise)),
                              TextButton(
                                  onPressed: () =>
                                      cart.setQuantity(line.item.key, 0),
                                  child: const Text('Remove')),
                            ]),
                      ]),
                )),
              const SizedBox(height: 16),
              Text('Total: ${cartMoney(cart.totalPaise)}',
                  style: Theme.of(context).textTheme.titleLarge),
              const Text(
                  'Checkout is not available. No orders or payments can be submitted yet.'),
              const SizedBox(height: 12),
              const FilledButton(
                  onPressed: null, child: Text('Checkout unavailable')),
              const SizedBox(height: 12),
              MapLocationField(
                  label: 'delivery location',
                  value: cart.deliveryPoint,
                  onChanged: cart.setDeliveryPoint),
              if (cart.deliveryPoint == null)
                const Text(
                    'Add a delivery pin so the delivery user can find your address.'),
            ]),
    );
  }
}
