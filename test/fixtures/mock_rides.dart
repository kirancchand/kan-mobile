import 'package:mv_app/data/models/ride_listing.dart';
import 'package:mv_app/data/models/vehicle_type.dart';

final DateTime _now = DateTime.now();

final List<RideListing> mockRides = [
  RideListing(
    id: 'ride_1',
    postedAt: _now.subtract(const Duration(hours: 4)),
    vehicleType: VehicleType.car,
    driverName: 'Ajay Verma',
    driverPhone: '9876522001',
    from: 'Rampura',
    to: 'Nashik City',
    departureTime: _now.add(const Duration(hours: 3)),
    seatsAvailable: 3,
    pricePerSeat: 150,
    vehicleInfo: 'Maruti Swift (White) - KA-01-AB-1234',
  ),
  RideListing(
    id: 'ride_2',
    postedAt: _now.subtract(const Duration(hours: 20)),
    vehicleType: VehicleType.car,
    driverName: 'Farida Begum',
    driverPhone: '9876522002',
    from: 'Sundarpalli',
    to: 'Vijayawada',
    departureTime: _now.add(const Duration(days: 1, hours: 1)),
    seatsAvailable: 2,
    pricePerSeat: 200,
    vehicleInfo: 'Hyundai i10 (Silver) - AP-16-CD-5678',
  ),
  RideListing(
    id: 'ride_3',
    postedAt: _now.subtract(const Duration(hours: 2)),
    vehicleType: VehicleType.bike,
    driverName: 'Vijay Kumar',
    driverPhone: '9876522003',
    from: 'Kothapet',
    to: 'Warangal',
    departureTime: _now.add(const Duration(hours: 5)),
    seatsAvailable: 1,
    pricePerSeat: 50,
    vehicleInfo: 'Honda Activa - TS-09-EF-4321',
  ),
  RideListing(
    id: 'ride_4',
    postedAt: _now.subtract(const Duration(hours: 1)),
    vehicleType: VehicleType.bike,
    driverName: 'Sneha Patil',
    driverPhone: '9876522004',
    from: 'Devipura',
    to: 'Udaipur',
    departureTime: _now.add(const Duration(hours: 8)),
    seatsAvailable: 1,
    pricePerSeat: 60,
    vehicleInfo: 'TVS Jupiter - RJ-27-GH-9988',
  ),
  RideListing(
    id: 'ride_5',
    postedAt: _now.subtract(const Duration(hours: 30)),
    vehicleType: VehicleType.car,
    driverName: 'Mohan Das',
    driverPhone: '9876522005',
    from: 'Mannargudi',
    to: 'Thanjavur',
    departureTime: _now.add(const Duration(days: 2)),
    seatsAvailable: 4,
    pricePerSeat: 100,
    vehicleInfo: 'Toyota Innova (Grey) - TN-51-JK-6655',
  ),
];

List<RideListing> ridesFor(VehicleType vehicleType) =>
    mockRides.where((r) => r.vehicleType == vehicleType).toList();
