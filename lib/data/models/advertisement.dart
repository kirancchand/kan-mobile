import 'package:flutter/material.dart';

/// A featured/sponsored ad shown in the home page banner carousel.
class Advertisement {
  final String id;
  final String? imageUrl;
  final String title;
  final String subtitle;
  final String sponsor;
  final Color color;
  final IconData icon;

  const Advertisement({
    required this.id,
    this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.sponsor,
    required this.color,
    required this.icon,
  });

  /// Only real media is shown; missing media uses a neutral placeholder.
  String get bannerImageUrl => imageUrl ?? '';
}
