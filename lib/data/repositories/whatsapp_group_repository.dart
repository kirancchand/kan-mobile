import '../models/whatsapp_group.dart';

/// No groups are manufactured without a connected group service.
class WhatsAppGroupRepository {
  List<WhatsAppGroup> groupsFor(String locationId) => const [];

  Future<WhatsAppGroup> assignUserToGroup(String locationId) async {
    throw StateError('WhatsApp group assignment is not available.');
  }
}
