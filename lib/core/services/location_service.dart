import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../data/models/map_location.dart';

class LocationFix {
  const LocationFix(this.point,
      {required this.accuracyMeters, required this.measuredAt});
  final MapLocation point;
  final double accuracyMeters;
  final DateTime measuredAt;
}

class LocationFailure implements Exception {
  const LocationFailure(this.message, {this.settingsRequired = false});
  final String message;
  final bool settingsRequired;
}

class LocationService {
  const LocationService();

  Future<LocationFix> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationFailure(
            'Turn on location services, then try again.',
            settingsRequired: true);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw const LocationFailure(
            'Location permission is blocked. Enable it in app or browser settings.',
            settingsRequired: true);
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        throw const LocationFailure(
            'Location permission was not granted. You can still view saved pickup and delivery pins.');
      }
      final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 20)));
      return LocationFix(
          MapLocation(
              latitude: position.latitude, longitude: position.longitude),
          accuracyMeters: position.accuracy,
          measuredAt: position.timestamp);
    } on LocationFailure {
      rethrow;
    } on TimeoutException {
      throw const LocationFailure(
          'Getting your location timed out. Move to an open area and try again.');
    } catch (_) {
      throw const LocationFailure(
          'Current location is unavailable on this device. Check location settings and try again.');
    }
  }

  Future<bool> openSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }
}
