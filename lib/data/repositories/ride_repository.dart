import '../models/media_attachment.dart';
import 'package:flutter/foundation.dart';
import '../models/ride_listing.dart';
import '../models/vehicle_type.dart';

/// Unified ride pool, optionally filtered by vehicle type.
class RideRepository {
  RideRepository({Iterable<RideListing> initialItems = const []})
      : _rides = List.of(initialItems);
  final _changes = ValueNotifier<int>(0);
  Listenable get changes => _changes;
  void dispose() => _changes.dispose();

  final List<RideListing> _rides;

  Future<List<RideListing>> getRides({VehicleType? vehicleType}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _rides
        .where((r) => vehicleType == null || r.vehicleType == vehicleType)
        .toList()
      ..sort((a, b) => a.departureTime.compareTo(b.departureTime));
  }

  Future<RideListing> postRide({
    required VehicleType vehicleType,
    required String driverName,
    required String driverPhone,
    required String from,
    required String to,
    required DateTime departureTime,
    required int seatsAvailable,
    required double pricePerSeat,
    required String vehicleInfo,
    List<MediaAttachment> attachments = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final ride = RideListing(
      attachments: List.unmodifiable(attachments),
      id: 'ride_${DateTime.now().millisecondsSinceEpoch}',
      vehicleType: vehicleType,
      driverName: driverName,
      driverPhone: driverPhone,
      from: from,
      to: to,
      departureTime: departureTime,
      postedAt: DateTime.now(),
      seatsAvailable: seatsAvailable,
      pricePerSeat: pricePerSeat,
      vehicleInfo: vehicleInfo,
    );
    _rides.insert(0, ride);
    _changes.value++;
    return ride;
  }
}
