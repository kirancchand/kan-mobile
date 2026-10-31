import 'package:flutter/material.dart';
import '../../data/models/village_carousel_item.dart';
import '../../data/services/village_carousel_api.dart';
import '../theme/app_spacing.dart';
import 'app_network_image.dart';
import 'paper_banner.dart';

/// API-backed village images, swiped horizontally without page controls.
class VillageCarousel extends StatefulWidget {
  const VillageCarousel({super.key, this.api, this.homeBannerStyle = false});
  final bool homeBannerStyle;
  final VillageCarouselApi? api;

  @override
  State<VillageCarousel> createState() => _VillageCarouselState();
}

class _VillageCarouselState extends State<VillageCarousel> {
  late final VillageCarouselApi _api;
  late Future<List<VillageCarouselItem>> _future;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? VillageCarouselApi();
    _future = _api.fetch();
  }

  @override
  void dispose() {
    if (widget.api == null) _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<List<VillageCarouselItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: TextButton.icon(
              onPressed: () => setState(() {
                _future = _api.fetch();
              }),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry village images'),
            ));
          }
          if (!snapshot.hasData) {
            return const SizedBox(
                height: 200, child: Center(child: CircularProgressIndicator()));
          }
          final items = snapshot.data!;
          if (items.isEmpty) return const SizedBox.shrink();
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: SizedBox(
              height: 220,
              child: PageView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Semantics(
                    label: [item.name, item.description]
                        .where((text) => text.isNotEmpty)
                        .join('. '),
                    image: true,
                    child: widget.homeBannerStyle
                        ? PaperBanner(
                            color: PaperBanner.teal,
                            child: AppNetworkImage(
                                url: item.imageUrl, fit: BoxFit.cover),
                          )
                        : AppNetworkImage(
                            url: item.imageUrl, fit: BoxFit.cover),
                  );
                },
              ),
            ),
          );
        },
      );
}
