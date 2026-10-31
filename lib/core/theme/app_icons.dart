import 'package:flutter/widgets.dart';

/// One consistent icon family app-wide (design guidelines §5: "never mix
/// icon families"), sourced from the Phosphor icon font
/// (https://phosphoricons.com). The `phosphor_flutter` package stays a
/// pubspec dependency purely so its font files get bundled — its Dart API
/// subclasses the (now `final`) [IconData] class, which this Flutter/Dart
/// SDK no longer allows outside its own library, so we build [IconData]
/// values directly here instead of importing that package's code.
///
/// Constants are named after the same icon (e.g. `house`) with a `Fill` /
/// `Bold` suffix for the heavier weights used for active nav states and
/// button/FAB icons; the unsuffixed name is the regular weight used
/// everywhere else.
class AppIcons {
  AppIcons._();

  static const String _pkg = 'phosphor_flutter';

  static const IconData bell = IconData(0xe0ce, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData shoppingCart = IconData(0xe41e, fontFamily: 'PhosphorRegular', fontPackage: _pkg);

  static const IconData ambulance = IconData(0xe572, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData bicycle = IconData(0xe0d6, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData bookOpen = IconData(0xe0e6, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData buildings = IconData(0xe102, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData cake = IconData(0xe780, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData car = IconData(0xe112, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData caretRight = IconData(0xe13a, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData chartBar = IconData(0xe150, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData chatCircle = IconData(0xe168, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData checkCircle = IconData(0xe184, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData clock = IconData(0xe19a, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData confetti = IconData(0xe81a, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData currencyInr = IconData(0xe558, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData eye = IconData(0xe220, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData fan = IconData(0xe9f2, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData fileText = IconData(0xe23a, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData fireTruck = IconData(0xe574, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData firstAid = IconData(0xe56e, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData firstAidKit = IconData(0xe570, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData flowerLotus = IconData(0xe6cc, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData gearSix = IconData(0xe272, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData gridFour = IconData(0xe296, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData heartbeat = IconData(0xe2ac, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData house = IconData(0xe2c2, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData houseLine = IconData(0xe2c4, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData identificationBadge = IconData(0xe6f6, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData image = IconData(0xe2ca, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData info = IconData(0xe2ce, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData leaf = IconData(0xe2da, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData lightning = IconData(0xe2de, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData listBullets = IconData(0xe2f2, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData lock = IconData(0xe2fa, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData magnifyingGlass = IconData(0xe30c, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData mapPin = IconData(0xe316, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData moped = IconData(0xe824, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData phoneCall = IconData(0xe3ba, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData pill = IconData(0xe700, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData playCircle = IconData(0xe3d2, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData pottedPlant = IconData(0xec22, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData receipt = IconData(0xe3ec, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData shieldCheck = IconData(0xe40c, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData signOut = IconData(0xe42a, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData storefront = IconData(0xe470, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData table = IconData(0xe476, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData tag = IconData(0xe478, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData tractor = IconData(0xec6e, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData tree = IconData(0xe6da, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData truck = IconData(0xe4b4, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData user = IconData(0xe4c2, fontFamily: 'PhosphorRegular', fontPackage: _pkg);
  static const IconData usersThree = IconData(0xe68e, fontFamily: 'PhosphorRegular', fontPackage: _pkg);

  // Fill (solid) — used for the active bottom-nav tab.
  static const IconData houseFill = IconData(0xe2c2, fontFamily: 'PhosphorFill', fontPackage: _pkg);
  static const IconData gridFourFill = IconData(0xe296, fontFamily: 'PhosphorFill', fontPackage: _pkg);
  static const IconData mapPinFill = IconData(0xe316, fontFamily: 'PhosphorFill', fontPackage: _pkg);
  static const IconData playCircleFill = IconData(0xe3d2, fontFamily: 'PhosphorFill', fontPackage: _pkg);
  static const IconData shieldCheckFill = IconData(0xe40c, fontFamily: 'PhosphorFill', fontPackage: _pkg);
  static const IconData userFill = IconData(0xe4c2, fontFamily: 'PhosphorFill', fontPackage: _pkg);

  // Bold — used for primary button/FAB icons.
  static const IconData caretRightBold = IconData(0xe13a, fontFamily: 'PhosphorBold', fontPackage: _pkg);
  static const IconData phoneCallBold = IconData(0xe3ba, fontFamily: 'PhosphorBold', fontPackage: _pkg);
  static const IconData plusBold = IconData(0xe3d4, fontFamily: 'PhosphorBold', fontPackage: _pkg);
  static const IconData uploadSimpleBold = IconData(0xe4c0, fontFamily: 'PhosphorBold', fontPackage: _pkg);
}
