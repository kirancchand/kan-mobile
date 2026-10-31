import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../data/models/village_event.dart';
import '../../data/services/advertisements_api.dart';
import 'widgets/events_feed.dart';

class AllEventsScreen extends StatelessWidget {
  final List<VillageEvent> events;
  final List<AdvertisementType> types;

  const AllEventsScreen(
      {super.key, required this.events, this.types = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events & Updates')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [EventsFeed(events: events, types: types)],
      ),
    );
  }
}
