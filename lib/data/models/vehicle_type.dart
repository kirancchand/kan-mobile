import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';

enum VehicleType { car, bike }

extension VehicleTypeMeta on VehicleType {
  String get label => this == VehicleType.car ? 'Car' : 'Bike';
  IconData get icon => this == VehicleType.car ? AppIcons.car : AppIcons.moped;
}
