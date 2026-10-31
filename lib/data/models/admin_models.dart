/// A row in the "Businesses/people currently registered" table that a
/// Location Admin sees for their own location (Section 5).
class RegisteredEntity {
  final String id;
  final String name;
  final String type; // "Business" or "Resident"
  final String category;
  final DateTime registeredOn;

  const RegisteredEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.registeredOn,
  });
}

/// A transaction happening within a location, visible to that location's
/// admin.
class LocationTransaction {
  final String id;
  final String serviceLabel;
  final String description;
  final double amount;
  final DateTime timestamp;

  const LocationTransaction({
    required this.id,
    required this.serviceLabel,
    required this.description,
    required this.amount,
    required this.timestamp,
  });
}

/// Rolled-up analytics for one location, as seen by its Location Admin and
/// aggregated for the Head Admin's consolidated view.
class LocationAnalytics {
  final String locationId;
  final String locationName;
  final int activeUsers;
  final int registeredBusinesses;
  final int whatsAppGroupCount;
  final int totalWhatsAppMembers;
  final double totalTransactionValue;
  final Map<String, int> serviceUsageCounts;

  const LocationAnalytics({
    required this.locationId,
    required this.locationName,
    required this.activeUsers,
    required this.registeredBusinesses,
    required this.whatsAppGroupCount,
    required this.totalWhatsAppMembers,
    required this.totalTransactionValue,
    required this.serviceUsageCounts,
  });
}
