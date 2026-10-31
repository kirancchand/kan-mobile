/// 8-point spacing scale (design.md §7) — use these instead of picking
/// arbitrary padding values per screen.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4; // icon-to-text gap
  static const double sm = 8; // tight spacing
  static const double ms = 12; // compact card padding / list gaps
  static const double md = 16; // standard screen margin / card padding
  static const double lg = 24; // section spacing
  static const double xl = 32; // large section breaks
  static const double xxl = 40;
  static const double xxxl = 48;
  static const double huge = 64;

  /// Bottom list padding so the last item clears an extended FAB.
  static const double fabClearance = 88;
}

/// Controlled corner radii (design.md §8).
class AppRadius {
  AppRadius._();

  static const double sm = 8; // chips, tags, small thumbnails
  static const double md = 12; // buttons, inputs, icon badges
  static const double lg = 16; // cards
  static const double xl = 20; // prominent surfaces: hero, sheets, dialogs

  static const double button = md;
  static const double input = md;
  static const double card = lg;
  static const double chip = sm;
  static const double pill = 999; // avatars and indicator dots only
}
