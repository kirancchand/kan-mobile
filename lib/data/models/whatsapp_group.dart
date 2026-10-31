/// Mirrors the "Location -> [Group 1, Group 2, ...]" mapping table described
/// in the concept doc (Section 4). Real implementation would be backed by
/// the WhatsApp Business API; here it is simulated in-memory.
class WhatsAppGroup {
  final String id;
  final String locationId;
  final int sequenceNumber; // 1, 2, 3... within the location
  int memberCount;
  final int memberLimit;

  WhatsAppGroup({
    required this.id,
    required this.locationId,
    required this.sequenceNumber,
    this.memberCount = 0,
    this.memberLimit = 1024,
  });

  bool get isFull => memberCount >= memberLimit;

  String get displayName => 'Group $sequenceNumber';
}
