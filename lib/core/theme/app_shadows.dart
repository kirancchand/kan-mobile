import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Subtle elevation (design.md §9: "avoid heavy shadows"). Dark mode relies
/// on surface contrast + borders instead, since shadows vanish on dark
/// backgrounds.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get cardLight => [
        BoxShadow(
          color: AppColors.midnight.withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.midnight.withValues(alpha: 0.03),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static const List<BoxShadow> cardDark = [];
}
