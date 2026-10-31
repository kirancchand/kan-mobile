import 'package:flutter/material.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/service_type.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/cart_money.dart';

class PurchaseOrderCard extends StatelessWidget {
  const PurchaseOrderCard({super.key, required this.order});
  final PurchaseOrder order;

  @override
  Widget build(BuildContext context) => Card(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${order.id} • Order',
              style: Theme.of(context).textTheme.titleMedium),
          Text(Formatters.dateTime(order.createdAt)),
          const SizedBox(height: 8),
          for (final line in order.lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                  '${line.item.title} × ${line.quantity}\n${line.item.service.label} • ${line.item.seller}\n${cartMoney(line.totalPaise)}\nStatus: ${line.status.label}'),
            ),
          Text('Total: ${cartMoney(order.totalPaise)}'),
        ]),
      ));
}
