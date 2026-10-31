import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_spacing.dart';
import '../theme/app_tokens.dart';

/// Loading skeleton used in place of a bare spinner (design.md §16).
/// Mimics the shape of a typical list-row card: a leading thumbnail plus
/// two lines of text.
class ShimmerListPlaceholder extends StatelessWidget {
  const ShimmerListPlaceholder({super.key, this.itemCount = 6, this.padding});

  final int itemCount;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final fill = tokens.skeletonBase;
    return Semantics(
      label: 'Loading',
      child: Shimmer.fromColors(
        baseColor: tokens.skeletonBase,
        highlightColor: tokens.skeletonHighlight,
        child: ListView.separated(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.ms),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(AppRadius.card)),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: tokens.skeletonHighlight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _bar(tokens, height: 14, width: double.infinity),
                        const SizedBox(height: AppSpacing.sm),
                        _bar(tokens, height: 12, width: 120),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _bar(AppTokens tokens, {required double height, required double width}) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: tokens.skeletonHighlight,
          borderRadius: BorderRadius.circular(AppSpacing.xs),
        ),
      );
}

/// Skeleton for a horizontal banner/carousel (e.g. the home page hero).
class ShimmerBanner extends StatelessWidget {
  const ShimmerBanner({super.key, this.height = 150});

  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Shimmer.fromColors(
      baseColor: tokens.skeletonBase,
      highlightColor: tokens.skeletonHighlight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Container(
          height: height,
          decoration: BoxDecoration(color: tokens.skeletonBase, borderRadius: BorderRadius.circular(AppRadius.xl)),
        ),
      ),
    );
  }
}
