import '../../data/models/service_definition.dart';
import 'package:flutter/material.dart';

import '../../data/models/service_type.dart';
import 'delivery/delivery_screen.dart';
import 'library/library_list_screen.dart';
import 'marketplace/marketplace_list_screen.dart';
import 'ride_pool/ride_list_screen.dart';
import 'plants/plants_list_screen.dart';
import 'cake/cake_list_screen.dart';
import 'pharmacy/pharmacy_list_screen.dart';
import 'youtube/youtube_screen.dart';

/// Single place that knows how to open any [ServiceType]. New services just
/// add a case here (and, if bespoke, a screen) — nothing else that links to
/// services needs to change.
void openService(BuildContext context, ServiceType service) {
  Widget screen;
  switch (service) {
    case ServiceType.library:
      screen = const LibraryListScreen();
      break;
    case ServiceType.ridePool:
      screen = const RideListScreen();
      break;
    case ServiceType.youtube:
      screen = const YoutubeScreen();
      break;
    case ServiceType.delivery:
      screen = const DeliveryScreen();
      break;
    case ServiceType.plants:
      screen = const PlantsListScreen();
      break;
    case ServiceType.cake:
      screen = const CakeListScreen();
      break;
    case ServiceType.pharmacy:
      screen = const PharmacyListScreen();
      break;
    case ServiceType.buySell:
      screen = MarketplaceListScreen(serviceType: service);
      break;
  }
  Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

/// Unknown server services remain visible without routing to an unrelated module.
void openCatalogService(BuildContext context, ServiceDefinition service) {
  final module = service.module;
  if (module != null) {
    openService(context, module);
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          '${service.label} is not available in this version of the app.')));
}
