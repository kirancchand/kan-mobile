import 'dart:math' as math;

/// An explicitly selected geographic point, never inferred from a village name.
class MapLocation {
  MapLocation(
      {required this.latitude, required this.longitude, String address = ''})
      : address = address.trim() {
    if (!latitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        !longitude.isFinite ||
        longitude < -180 ||
        longitude > 180) {
      throw ArgumentError('Enter valid latitude and longitude.');
    }
  }
  final double latitude;
  final double longitude;
  final String address;
  String get coordinates =>
      '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
  String get label => address.isEmpty ? coordinates : address;

  double distanceKmTo(MapLocation other) {
    const radians = math.pi / 180;
    final latDelta = (other.latitude - latitude) * radians;
    final lonDelta = (other.longitude - longitude) * radians;
    final a = math.pow(math.sin(latDelta / 2), 2) +
        math.cos(latitude * radians) *
            math.cos(other.latitude * radians) *
            math.pow(math.sin(lonDelta / 2), 2);
    return 6371.0088 * 2 * math.asin(math.sqrt(a.clamp(0, 1)));
  }
}

Uri directionsUri(
        {required MapLocation origin,
        required MapLocation destination,
        MapLocation? via}) =>
    Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'origin': origin.coordinates,
      'destination': destination.coordinates,
      'travelmode': 'driving',
      if (via != null) 'waypoints': via.coordinates,
    });
