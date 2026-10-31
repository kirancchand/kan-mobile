import '../models/media_attachment.dart';
import 'package:flutter/foundation.dart';
import '../models/delivery_order.dart';

class DeliveryRepository {
  DeliveryRepository({Iterable<DeliveryOrder> initialItems = const []})
      : _orders = List.of(initialItems);
  final _changes = ValueNotifier<int>(0);
  Listenable get changes => _changes;
  void dispose() => _changes.dispose();

  final List<DeliveryOrder> _orders;

  Future<List<DeliveryOrder>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [..._orders]..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }

  Future<DeliveryOrder> requestDelivery({
    required String itemDescription,
    required String pickupAddress,
    required String dropAddress,
    required String requestedBy,
    required double fee,
    List<MediaAttachment> attachments = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final order = DeliveryOrder(
      attachments: List.unmodifiable(attachments),
      id: 'dl_${DateTime.now().millisecondsSinceEpoch}',
      itemDescription: itemDescription,
      pickupAddress: pickupAddress,
      dropAddress: dropAddress,
      requestedBy: requestedBy,
      fee: fee,
      status: DeliveryStatus.requested,
      requestedAt: DateTime.now(),
    );
    _orders.insert(0, order);
    _changes.value++;
    return order;
  }
}
