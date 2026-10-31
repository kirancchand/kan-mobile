enum EventCategory { event, announcement, update }

class VillageEvent {
  final String id;
  final String title;
  final String description;
  final EventCategory category;
  final DateTime? dateTime;
  final String? typeId, typeLabel;
  final String imageUrl;
  final String location;

  const VillageEvent({
    required this.id,
    this.typeId,
    this.typeLabel,
    this.imageUrl = '',
    required this.title,
    required this.description,
    required this.category,
    required this.dateTime,
    required this.location,
  });
}
