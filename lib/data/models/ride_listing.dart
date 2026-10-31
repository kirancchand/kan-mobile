import 'media_attachment.dart';
import 'vehicle_type.dart';

class RideListing {
  final List<MediaAttachment> attachments;
  final String id;
  final VehicleType vehicleType;
  final String driverName;
  final String driverPhone;
  final String from;
  final String to;
  final DateTime departureTime;
  final DateTime postedAt;
  final int seatsAvailable;
  final double pricePerSeat;
  final String vehicleInfo;

  const RideListing({
    required this.id,
    this.attachments = const [],
    required this.vehicleType,
    required this.driverName,
    required this.driverPhone,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.postedAt,
    required this.seatsAvailable,
    required this.pricePerSeat,
    required this.vehicleInfo,
  });
}
