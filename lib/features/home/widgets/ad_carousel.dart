import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/paper_banner.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../data/models/advertisement.dart';

/// Full-size API banner images with readable sponsored content overlays.
class AdCarousel extends StatefulWidget {
  final List<Advertisement> ads;

  const AdCarousel({super.key, required this.ads});

  @override
  State<AdCarousel> createState() => _AdCarouselState();
}

class _AdCarouselState extends State<AdCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.ads.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) {
              final ad = widget.ads[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xs + 2),
                child: PaperBanner(
                  color: PaperBanner.terracotta,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (ad.bannerImageUrl.isNotEmpty) ...[
                        AppNetworkImage(
                            url: ad.bannerImageUrl, fit: BoxFit.cover),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.75),
                                Colors.black.withValues(alpha: 0.15),
                              ],
                            ),
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md + 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.15),
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.pill),
                                    ),
                                    child: Text('SPONSORED',
                                        style: text.labelSmall?.copyWith(
                                            color: PaperBanner.mustard,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    ad.title,
                                    style: text.titleMedium?.copyWith(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w700),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    ad.subtitle,
                                    style: text.bodySmall
                                        ?.copyWith(color: AppColors.white),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  if (ad.sponsor.isNotEmpty)
                                    Text(
                                      'by ${ad.sponsor}',
                                      style: text.labelSmall?.copyWith(
                                          color: AppColors.white
                                              .withValues(alpha: 0.85)),
                                    ),
                                ],
                              ),
                            ),
                            if (ad.bannerImageUrl.isEmpty) ...[
                              const SizedBox(width: 12),
                              Icon(ad.icon,
                                  color: PaperBanner.mustard, size: 36),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.ms),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.ads.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            );
          }),
        ),
      ],
    );
  }
}
