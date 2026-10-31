import '../models/location.dart';

/// Locations must be supplied by a real directory; no sample villages are bundled.
class LocationRepository {
  Future<List<VillageLocation>> getLocations() async => const [];
  Future<VillageLocation?> getById(String id) async => null;
}
