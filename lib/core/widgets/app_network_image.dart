import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_icons.dart';
import '../theme/app_tokens.dart';

/// Consistent image treatment app-wide: cached loading, a shimmer
/// placeholder instead of a bare spinner, a graceful fallback icon on error,
/// and a fixed border radius.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.borderRadius = 0,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    if (url.trim().isEmpty) {
      return Container(
        width: width,
        height: height,
        color: tokens.soft(AppTone.neutral),
        child: Icon(AppIcons.image, color: tokens.textMuted),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, _) => Shimmer.fromColors(
          baseColor: tokens.skeletonBase,
          highlightColor: tokens.skeletonHighlight,
          child: Container(
              width: width, height: height, color: tokens.skeletonBase),
        ),
        errorWidget: (context, _, __) => Container(
          width: width,
          height: height,
          color: tokens.soft(AppTone.neutral),
          child: Icon(AppIcons.image, color: tokens.textMuted),
        ),
      ),
    );
  }
}
