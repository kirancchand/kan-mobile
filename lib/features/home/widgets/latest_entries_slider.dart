import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/semantic_tones.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/book_listing.dart';
import '../../../data/models/delivery_order.dart';
import '../../../data/models/latest_module_entry.dart';
import '../../../data/models/marketplace_listing.dart';
import '../../../data/models/ride_listing.dart';
import '../../../data/models/service_type.dart';
import '../../../data/models/vehicle_type.dart';
import '../../../data/models/video_submission.dart';
import '../../../data/repositories/latest_entries_repository.dart';
import '../../services/library/book_detail_screen.dart';
import '../../services/marketplace/marketplace_detail_screen.dart';
import '../../services/ride_pool/ride_detail_screen.dart';
import '../../services/service_router.dart';

class LatestEntriesSlider extends StatefulWidget {
  const LatestEntriesSlider({super.key});
  @override
  State<LatestEntriesSlider> createState() => _LatestEntriesSliderState();
}

class _LatestEntriesSliderState extends State<LatestEntriesSlider> {
  final _controller = PageController(viewportFraction: 0.92);
  late LatestEntriesRepository _repository;
  late Future<List<LatestModuleEntry>> _future;
  int _page = 0;
  int _entryCount = 0;
  Timer? _autoAdvance;

  @override
  void initState() {
    super.initState();
    _repository = context.read<LatestEntriesRepository>();
    _future = _repository.getLatestEntries();
    _repository.addListener(_reload);
    _restartAutoAdvance();
  }

  void _restartAutoAdvance() {
    _autoAdvance?.cancel();
    _autoAdvance = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted ||
          _entryCount < 2 ||
          !_controller.hasClients ||
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed ||
          ModalRoute.of(context)?.isCurrent == false ||
          MediaQuery.disableAnimationsOf(context) ||
          _controller.position.isScrollingNotifier.value) {
        return;
      }
      _controller.animateToPage((_page + 1) % _entryCount,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  void _reload() {
    if (mounted) {
      setState(() {
        _future = _repository.getLatestEntries();
      });
    }
  }

  @override
  void dispose() {
    _autoAdvance?.cancel();
    _repository.removeListener(_reload);
    _controller.dispose();
    super.dispose();
  }

  void _open(LatestModuleEntry entry) {
    if (entry.failed) {
      _reload();
      return;
    }
    final screen = switch (entry.item) {
      MarketplaceListing listing => MarketplaceDetailScreen(listing: listing),
      BookListing book => BookDetailScreen(book: book),
      RideListing ride => RideDetailScreen(ride: ride),
      _ => null,
    };
    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    } else {
      // Video and delivery entries are displayed inside their module lists.
      openService(context, entry.service);
    }
  }

  void _move(int delta) => _controller.animateToPage(_page + delta,
      duration: const Duration(milliseconds: 250), curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: LayoutBuilder(builder: (context, constraints) {
              final title = Semantics(
                  header: true,
                  child: Text('Latest across services',
                      style: Theme.of(context).textTheme.titleLarge));
              final refresh =
                  TextButton(onPressed: _reload, child: const Text('Refresh'));
              if (MediaQuery.textScalerOf(context).scale(14) > 19 ||
                  constraints.maxWidth < 320) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      Align(alignment: Alignment.centerRight, child: refresh)
                    ]);
              }
              return Row(children: [Expanded(child: title), refresh]);
            })),
        FutureBuilder<List<LatestModuleEntry>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                  height: 240,
                  child: Center(
                      child: CircularProgressIndicator(
                          semanticsLabel: 'Loading latest entries')));
            }
            final entries = snapshot.data!;
            _entryCount = entries.length;
            if (entries.isEmpty) return const SizedBox.shrink();
            final height = 248 +
                (MediaQuery.textScalerOf(context).scale(14) - 14).clamp(0, 28) *
                    10;
            return Column(children: [
              SizedBox(
                  height: height.toDouble(),
                  child: PageView.builder(
                    key: const ValueKey('latest-entries-pages'),
                    controller: _controller,
                    itemCount: entries.length,
                    onPageChanged: (page) {
                      setState(() => _page = page);
                      _restartAutoAdvance();
                    },
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final tone = entry.service.tone;
                      return Padding(
                          padding: const EdgeInsets.fromLTRB(6, 4, 6, 12),
                          child: AppCard(
                            key: ValueKey('latest-${entry.service.name}'),
                            borderRadius: 24,
                            child: InkWell(
                                onTap: () => _open(entry),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                        context.tokens.soft(tone),
                                        Theme.of(context).colorScheme.surface
                                      ])),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Icon(entry.service.icon,
                                              color: context.tokens.ink(tone)),
                                          const SizedBox(width: 10),
                                          Expanded(
                                              child: Text(entry.service.label,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: context.tokens
                                                          .ink(tone),
                                                      fontWeight:
                                                          FontWeight.w700)))
                                        ]),
                                        const SizedBox(height: 16),
                                        Text(entry.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                        const SizedBox(height: 8),
                                        Text(_summary(entry),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: context.tokens.textMuted,
                                                fontSize: 12)),
                                        const Spacer(),
                                        Row(children: [
                                          Expanded(
                                              child: Text(
                                                  entry.postedAt == null
                                                      ? entry
                                                          .service.description
                                                      : Formatters.relative(
                                                          entry.postedAt!),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: context
                                                          .tokens.textMuted))),
                                          const SizedBox(width: 8),
                                          Text(
                                              entry.failed
                                                  ? 'Retry'
                                                  : entry.item == null
                                                      ? 'Explore'
                                                      : 'View',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary)),
                                          const SizedBox(width: 4),
                                          const Icon(AppIcons.caretRight,
                                              size: 16),
                                        ]),
                                      ]),
                                )),
                          ));
                    },
                  )),
              ExcludeSemantics(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(entries.length, (index) {
                    final active = index == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
              ),
              // Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              //   IconButton(
              //       tooltip: 'Previous latest entry',
              //       onPressed: _page > 0 ? () => _move(-1) : null,
              //       icon: const RotatedBox(
              //           quarterTurns: 2, child: Icon(AppIcons.caretRight))),
              //   Semantics(
              //       child: Text('${_page + 1} / ${entries.length}',
              //           style: Theme.of(context).textTheme.labelMedium)),
              //   IconButton(
              //       tooltip: 'Next latest entry',
              //       onPressed:
              //           _page < entries.length - 1 ? () => _move(1) : null,
              //       icon: const Icon(AppIcons.caretRight)),
              // ]),
            ]);
          },
        ),
      ]);

  String _summary(LatestModuleEntry entry) => switch (entry.item) {
        MarketplaceListing item =>
          '${Formatters.currency(item.price)} · ${item.sellerName}${item.isAvailable ? '' : ' · Sold out'}',
        BookListing book => '${book.author} · ${book.listingType.label}',
        RideListing ride =>
          '${ride.vehicleType.label} · ${ride.seatsAvailable} seat(s) · ${Formatters.currency(ride.pricePerSeat)}/seat',
        VideoSubmission video => '${video.submittedBy} · ${video.status.label}',
        DeliveryOrder order =>
          '${order.status.label} · ${Formatters.currency(order.fee)} delivery fee',
        _ => entry.failed
            ? 'Tap to try loading this service again.'
            : 'Be the first to add an entry in this service.',
      };
}
