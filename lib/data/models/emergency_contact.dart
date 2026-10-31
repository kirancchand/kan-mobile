import 'package:flutter/material.dart';
import '../../core/theme/app_icons.dart';

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final IconData icon;

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    final id = json['villageorganisation_id'];
    final name = json['organisation_name'];
    final phone = json['contact'];
    if (id == null ||
        name is! String ||
        name.trim().isEmpty ||
        phone is! String ||
        phone.trim().isEmpty) {
      throw const FormatException('Invalid emergency organisation.');
    }
    final category = '${json['icon'] ?? ''} ${json['organisation_type'] ?? ''}'
        .toLowerCase();
    final IconData icon;
    if (category.contains('police')) {
      icon = AppIcons.shieldCheck;
    } else if (category.contains('ambulance')) {
      icon = AppIcons.ambulance;
    } else if (category.contains('fire')) {
      icon = AppIcons.fireTruck;
    } else if (category.contains('hospital') ||
        category.contains('health') ||
        category.contains('medical')) {
      icon = AppIcons.firstAidKit;
    } else if (category.contains('electric')) {
      icon = AppIcons.lightning;
    } else {
      icon = AppIcons.buildings;
    }
    return EmergencyContact(
        id: '$id', name: name.trim(), phone: phone.trim(), icon: icon);
  }

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.icon,
  });
}
