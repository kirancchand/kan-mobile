import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/semantic_tones.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/icon_badge.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/book_listing.dart';
import '../../data/models/service_type.dart';
import '../../data/models/vehicle_type.dart';
import '../../data/models/video_submission.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../../data/repositories/ride_repository.dart';
import '../../data/repositories/video_repository.dart';
import '../../state/app_state.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/shimmer_list_placeholder.dart';
import '../../core/theme/app_icons.dart';

class _ListingRow {
  final IconData icon;
  final AppTone tone;
  final String title;
  final String subtitle;
  final DateTime date;

  _ListingRow(
      {required this.icon,
      required this.tone,
      required this.title,
      required this.subtitle,
      required this.date});
}

/// Aggregates everything the current user has posted across every service —
/// demonstrates how "My Listings" pulls from each module without those
/// modules needing to know about each other.
class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  late Future<List<_ListingRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_ListingRow>> _load() async {
    final userName = context.read<AppState>().currentUser?.name;
    if (userName == null) return [];

    final marketplaceRepo = context.read<MarketplaceRepository>();
    final bookRepo = context.read<BookRepository>();
    final rideRepo = context.read<RideRepository>();
    final videoRepo = context.read<VideoRepository>();

    final marketplaceLists = await Future.wait(
      [
        ServiceType.buySell,
        ServiceType.plants,
        ServiceType.cake,
        ServiceType.pharmacy
      ].map((t) => marketplaceRepo.getListings(t)),
    );
    final books = await bookRepo.getBooks();
    final rides = await rideRepo.getRides();
    final videos = await videoRepo.getVideos();

    final rows = <_ListingRow>[];
    for (final list in marketplaceLists) {
      for (final l in list.where((l) => l.sellerName == userName)) {
        rows.add(_ListingRow(
            icon: l.icon,
            tone: l.serviceType.tone,
            title: l.title,
            subtitle:
                '${l.serviceType.label} • ${Formatters.currency(l.price)}',
            date: l.postedAt));
      }
    }
    for (final b in books.where((b) => b.ownerName == userName)) {
      rows.add(_ListingRow(
          icon: AppIcons.bookOpen,
          tone: ServiceType.library.tone,
          title: b.title,
          subtitle: 'Online Library • ${b.listingType.label}',
          date: b.postedAt));
    }
    for (final r in rides.where((r) => r.driverName == userName)) {
      rows.add(_ListingRow(
          icon: r.vehicleType.icon,
          tone: ServiceType.ridePool.tone,
          title: '${r.from} → ${r.to}',
          subtitle:
              'Ride Pool • ${r.vehicleType.label} • ${Formatters.dateTime(r.departureTime)}',
          date: r.departureTime));
    }
    for (final v in videos.where((v) => v.submittedBy == userName)) {
      rows.add(_ListingRow(
          icon: AppIcons.playCircle,
          tone: ServiceType.youtube.tone,
          title: v.title,
          subtitle: 'Village YouTube • ${v.status.label}',
          date: v.submittedAt));
    }

    rows.sort((a, b) => b.date.compareTo(a.date));
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: FutureBuilder<List<_ListingRow>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(onRetry: () => setState(() {
                  _future = _load();
                }));
          }
          if (!snapshot.hasData) return const ShimmerListPlaceholder();
          final rows = snapshot.data!;
          if (rows.isEmpty) {
            return const EmptyState(
              icon: AppIcons.listBullets,
              title: 'Nothing posted yet',
              message:
                  'Anything you list or post across services — items, books, rides or videos — will show up here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.ms),
            itemBuilder: (context, index) {
              final row = rows[index];
              return AppCard(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  leading: IconBadge(icon: row.icon, tone: row.tone),
                  title: Text(row.title),
                  subtitle: Text(row.subtitle),
                  trailing: Text(Formatters.relative(row.date)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
