import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/semantic_tones.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/icon_badge.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/village_event.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/theme/app_icons.dart';
import '../../../data/services/advertisements_api.dart';
import '../../../core/widgets/app_network_image.dart';

class EventsFeed extends StatefulWidget {
  final List<VillageEvent> events;

  final List<AdvertisementType> types;
  final int? maxItems;

  const EventsFeed(
      {super.key, required this.events, this.types = const [], this.maxItems});

  @override
  State<EventsFeed> createState() => _EventsFeedState();
}

class _EventsFeedState extends State<EventsFeed> {
  String? _selectedType;

  IconData _categoryIcon(EventCategory c) {
    switch (c) {
      case EventCategory.event:
        return AppIcons.confetti;
      case EventCategory.announcement:
        return AppIcons.info;
      case EventCategory.update:
        return AppIcons.lightning;
    }
  }

  String _categoryLabel(EventCategory c) {
    switch (c) {
      case EventCategory.event:
        return 'Event';
      case EventCategory.announcement:
        return 'Announcement';
      case EventCategory.update:
        return 'Update';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = context.tokens.textMuted;
    final selected = widget.types.any((type) => type.id == _selectedType)
        ? _selectedType
        : null;
    final filtered = widget.events.where((event) =>
        selected == null ||
        event.typeId == selected ||
        (event.typeId?.isEmpty != false &&
            widget.types.any((type) =>
                type.id == selected && type.label == event.typeLabel)));
    final events =
        (widget.maxItems == null ? filtered : filtered.take(widget.maxItems!))
            .toList();
    return Column(
      children: [
        if (widget.types.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(children: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChoiceChip(
                    label: const Text('All'),
                    selected: selected == null,
                    onSelected: (_) => setState(() => _selectedType = null)),
              ),
              ...widget.types.map((type) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                        label: Text(type.label),
                        selected: selected == type.id,
                        onSelected: (_) =>
                            setState(() => _selectedType = type.id)),
                  )),
            ]),
          ),
        if (events.isEmpty)
          const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text('No events or updates in this category.')),
        ...events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          final tone = event.category.tone;
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
            child: AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconBadge(icon: _categoryIcon(event.category), tone: tone),
                    const SizedBox(width: AppSpacing.ms),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.xs,
                            children: [
                              StatusChip(
                                  label: event.typeLabel ??
                                      _categoryLabel(event.category),
                                  tone: tone),
                              if (event.dateTime != null)
                                Text(Formatters.relative(event.dateTime!),
                                    style: textTheme.bodySmall),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (event.imageUrl.isNotEmpty) ...[
                            AppNetworkImage(
                                url: event.imageUrl,
                                height: 140,
                                width: double.infinity,
                                borderRadius: AppRadius.md),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          Text(event.title, style: textTheme.titleMedium),
                          const SizedBox(height: AppSpacing.xs),
                          Text(event.description,
                              style:
                                  textTheme.bodyMedium?.copyWith(color: muted)),
                          const SizedBox(height: AppSpacing.sm),
                          if (event.location.isNotEmpty)
                            Row(
                              children: [
                                Icon(AppIcons.buildings,
                                    size: 14, color: muted),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                    child: Text(event.location,
                                        style: textTheme.bodySmall)),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              .animate(delay: (index * 40).ms)
              .fadeIn(duration: 250.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
        }),
      ],
    );
  }
}
