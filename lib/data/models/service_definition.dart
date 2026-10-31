import 'package:flutter/material.dart';
import '../../core/theme/app_icons.dart';
import 'service_type.dart';

/// Metadata and ordering come from the service master API.
class ServiceDefinition {
  const ServiceDefinition(
      {required this.id,
      required this.label,
      required this.shortform,
      required this.description,
      required this.icon,
      required this.color});

  final int id;
  final String label, shortform, description;
  final IconData icon;
  final Color color;

  /// Built-in screens are selected by a stable shortform, never the API ID.
  ServiceType? get module {
    final key = shortform.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return switch (key) {
      'buysell' => ServiceType.buySell,
      'library' => ServiceType.library,
      'plants' => ServiceType.plants,
      'ridepool' => ServiceType.ridePool,
      'pharmacy' => ServiceType.pharmacy,
      'youtube' => ServiceType.youtube,
      'cake' => ServiceType.cake,
      'delivery' => ServiceType.delivery,
      _ => null,
    };
  }

  factory ServiceDefinition.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse('${json['service_id']}');
    final name = json['service'];
    final shortform = json['shortform'];
    if (id == null ||
        id <= 0 ||
        name is! String ||
        name.trim().isEmpty ||
        shortform is! String ||
        shortform.trim().isEmpty) {
      throw const FormatException('Invalid service record.');
    }
    final rawIcon = '${json['icon'] ?? ''}'.trim();
    final iconName = RegExp(r'^(?:return\s+)?(?:AppIcons\.)?(\w+)\s*;?$')
        .firstMatch(rawIcon)
        ?.group(1);
    final hex = '${json['color'] ?? ''}'
        .trim()
        .replaceFirst(RegExp(r'^(0x|#)', caseSensitive: false), '');
    final color = RegExp(r'^[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$').hasMatch(hex)
        ? int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16)
        : 0xFF326B65;
    return ServiceDefinition(
        id: id,
        label: name.trim(),
        shortform: shortform.trim(),
        description: '${json['description'] ?? ''}'.trim(),
        icon: _icons[iconName] ?? AppIcons.gridFour,
        color: Color(color));
  }

  static const _icons = <String, IconData>{
    'bell': AppIcons.bell,
    'shoppingCart': AppIcons.shoppingCart,
    'ambulance': AppIcons.ambulance,
    'bicycle': AppIcons.bicycle,
    'bookOpen': AppIcons.bookOpen,
    'buildings': AppIcons.buildings,
    'cake': AppIcons.cake,
    'car': AppIcons.car,
    'caretRight': AppIcons.caretRight,
    'chartBar': AppIcons.chartBar,
    'chatCircle': AppIcons.chatCircle,
    'checkCircle': AppIcons.checkCircle,
    'clock': AppIcons.clock,
    'confetti': AppIcons.confetti,
    'currencyInr': AppIcons.currencyInr,
    'eye': AppIcons.eye,
    'fan': AppIcons.fan,
    'fileText': AppIcons.fileText,
    'fireTruck': AppIcons.fireTruck,
    'firstAid': AppIcons.firstAid,
    'firstAidKit': AppIcons.firstAidKit,
    'flowerLotus': AppIcons.flowerLotus,
    'gearSix': AppIcons.gearSix,
    'gridFour': AppIcons.gridFour,
    'heartbeat': AppIcons.heartbeat,
    'house': AppIcons.house,
    'houseLine': AppIcons.houseLine,
    'identificationBadge': AppIcons.identificationBadge,
    'image': AppIcons.image,
    'info': AppIcons.info,
    'leaf': AppIcons.leaf,
    'lightning': AppIcons.lightning,
    'listBullets': AppIcons.listBullets,
    'lock': AppIcons.lock,
    'magnifyingGlass': AppIcons.magnifyingGlass,
    'mapPin': AppIcons.mapPin,
    'moped': AppIcons.moped,
    'phoneCall': AppIcons.phoneCall,
    'pill': AppIcons.pill,
    'playCircle': AppIcons.playCircle,
    'pottedPlant': AppIcons.pottedPlant,
    'receipt': AppIcons.receipt,
    'shieldCheck': AppIcons.shieldCheck,
    'signOut': AppIcons.signOut,
    'storefront': AppIcons.storefront,
    'table': AppIcons.table,
    'tag': AppIcons.tag,
    'tractor': AppIcons.tractor,
    'tree': AppIcons.tree,
    'truck': AppIcons.truck,
    'user': AppIcons.user,
    'usersThree': AppIcons.usersThree,
    'houseFill': AppIcons.houseFill,
    'gridFourFill': AppIcons.gridFourFill,
    'mapPinFill': AppIcons.mapPinFill,
    'playCircleFill': AppIcons.playCircleFill,
    'shieldCheckFill': AppIcons.shieldCheckFill,
    'userFill': AppIcons.userFill,
    'caretRightBold': AppIcons.caretRightBold,
    'phoneCallBold': AppIcons.phoneCallBold,
    'plusBold': AppIcons.plusBold,
    'uploadSimpleBold': AppIcons.uploadSimpleBold,
  };
}
