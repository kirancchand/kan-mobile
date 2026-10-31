import 'media_attachment.dart';

enum DeliveryStatus { requested, pickedUp, onTheWay, delivered, cancelled }

extension DeliveryStatusLabel on DeliveryStatus {
  String get label {
    switch (this) {
      case DeliveryStatus.requested:
        return 'Requested';
      case DeliveryStatus.pickedUp:
        return 'Picked Up';
      case DeliveryStatus.onTheWay:
        return 'On the Way';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class DeliveryOrder {
  final List<MediaAttachment> attachments;
  final String id;
  final String itemDescription;
  final String pickupAddress;
  final String dropAddress;
  final String requestedBy;
  final double fee;
  final DeliveryStatus status;
  final DateTime requestedAt;

  const DeliveryOrder({
    required this.id,
    this.attachments = const [],
    required this.itemDescription,
    required this.pickupAddress,
    required this.dropAddress,
    required this.requestedBy,
    required this.fee,
    required this.status,
    required this.requestedAt,
  });
}
