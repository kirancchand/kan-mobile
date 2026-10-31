import '../../data/models/delivery_order.dart';
import '../../data/models/service_type.dart';
import '../../data/models/video_submission.dart';
import '../../data/models/village_event.dart';
import 'app_tokens.dart';

/// Single place mapping domain states to design-system tones, replacing the
/// per-screen `Colors.orange / blue / green` switches. Presentation only —
/// the models themselves are unchanged.

extension ServiceTypeTone on ServiceType {
  AppTone get tone {
    switch (this) {
      case ServiceType.buySell:
      case ServiceType.pharmacy:
        return AppTone.brand;
      case ServiceType.library:
      case ServiceType.ridePool:
        return AppTone.info;
      case ServiceType.cake:
      case ServiceType.youtube:
        return AppTone.accent;
      case ServiceType.plants:
      case ServiceType.delivery:
        return AppTone.lime;
    }
  }
}

extension DeliveryStatusTone on DeliveryStatus {
  AppTone get tone {
    switch (this) {
      case DeliveryStatus.requested:
        return AppTone.accent;
      case DeliveryStatus.pickedUp:
        return AppTone.info;
      case DeliveryStatus.onTheWay:
        return AppTone.lime;
      case DeliveryStatus.delivered:
        return AppTone.brand;
      case DeliveryStatus.cancelled:
        return AppTone.attention;
    }
  }
}

extension VideoStatusTone on VideoStatus {
  AppTone get tone {
    switch (this) {
      case VideoStatus.pending:
        return AppTone.accent;
      case VideoStatus.approved:
        return AppTone.info;
      case VideoStatus.featured:
        return AppTone.brand;
      case VideoStatus.rejected:
        return AppTone.attention;
    }
  }
}

extension EventCategoryTone on EventCategory {
  /// Sunshine is reserved for events/announcements (design.md §2, §12).
  AppTone get tone {
    switch (this) {
      case EventCategory.event:
        return AppTone.accent;
      case EventCategory.announcement:
        return AppTone.accent;
      case EventCategory.update:
        return AppTone.info;
    }
  }
}
