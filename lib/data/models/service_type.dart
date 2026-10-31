import 'package:flutter/material.dart';
import '../../core/theme/app_icons.dart';

/// Internal identifiers for the built-in modules and their local listings.
/// The visible service catalog and metadata come from ServiceDefinition/API.
enum ServiceType {
  buySell,
  library,
  plants,
  ridePool,
  pharmacy,
  youtube,
  cake,
  delivery,
}

extension ServiceTypeMeta on ServiceType {
  String get label {
    switch (this) {
      case ServiceType.buySell:
        return 'Buy & Sell';
      case ServiceType.library:
        return 'Online Library';
      case ServiceType.plants:
        return 'Plants';
      case ServiceType.ridePool:
        return 'Ride Pool';
      case ServiceType.pharmacy:
        return 'Pharmacy';
      case ServiceType.youtube:
        return 'Village YouTube';
      case ServiceType.cake:
        return 'Cake Marketplace';
      case ServiceType.delivery:
        return 'Delivery';
    }
  }

  String get description {
    switch (this) {
      case ServiceType.buySell:
        return 'Buy and sell used or new items';
      case ServiceType.library:
        return 'Rent, buy & sell books peer-to-peer';
      case ServiceType.plants:
        return 'Buy and sell plants';
      case ServiceType.ridePool:
        return 'Share a car or bike ride';
      case ServiceType.pharmacy:
        return 'Medicines & health essentials from local pharmacies';
      case ServiceType.youtube:
        return 'Submit videos to the village channel';
      case ServiceType.cake:
        return 'Home bakers & local bakeries';
      case ServiceType.delivery:
        return 'Local delivery within the village';
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceType.buySell:
        return AppIcons.storefront;
      case ServiceType.library:
        return AppIcons.bookOpen;
      case ServiceType.plants:
        return AppIcons.flowerLotus;
      case ServiceType.ridePool:
        return AppIcons.car;
      case ServiceType.pharmacy:
        return AppIcons.pill;
      case ServiceType.youtube:
        return AppIcons.playCircle;
      case ServiceType.cake:
        return AppIcons.cake;
      case ServiceType.delivery:
        return AppIcons.truck;
    }
  }

  Color get color {
    switch (this) {
      case ServiceType.buySell:
        return const Color(0xFF326B65);
      case ServiceType.library:
        return const Color(0xFF326B65);
      case ServiceType.plants:
        return const Color(0xFF326B65);
      case ServiceType.ridePool:
        return const Color(0xFF326B65);
      case ServiceType.pharmacy:
        return const Color(0xFF087F83);
      case ServiceType.youtube:
        return const Color(0xFF96564F);
      case ServiceType.cake:
        return const Color(0xFF96564F);
      case ServiceType.delivery:
        return const Color(0xFF96564F);
    }
  }

  /// Whether this service uses marketplace listings and the shared posting flow.
  bool get isGenericMarketplace =>
      this == ServiceType.buySell ||
      this == ServiceType.plants ||
      this == ServiceType.cake ||
      this == ServiceType.pharmacy;

  bool get isRidePool => this == ServiceType.ridePool;
}
