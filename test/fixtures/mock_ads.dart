import 'package:flutter/material.dart';
import 'package:mv_app/data/models/advertisement.dart';
import 'package:mv_app/core/theme/app_icons.dart';

final List<Advertisement> mockAds = [
  const Advertisement(
    id: 'ad_1',
    title: 'Village Harvest Festival',
    subtitle: 'This Saturday at the community ground — stalls, music & food',
    sponsor: 'Panchayat Office',
    color: Color(0xFF2E7D32),
    icon: AppIcons.confetti,
  ),
  const Advertisement(
    id: 'ad_2',
    title: '20% Off at Sri Ganesh Store',
    subtitle: 'Groceries & household essentials — this week only',
    sponsor: 'Sri Ganesh Store',
    color: Color(0xFFEF6C00),
    icon: AppIcons.tag,
  ),
  const Advertisement(
    id: 'ad_3',
    title: 'Free Health Camp',
    subtitle: 'Sunday 9 AM - 1 PM at the Primary Health Centre',
    sponsor: 'District Health Dept.',
    color: Color(0xFFC62828),
    icon: AppIcons.firstAid,
  ),
  const Advertisement(
    id: 'ad_4',
    title: 'New Tractor Rentals',
    subtitle: 'Book by the hour for this sowing season',
    sponsor: 'Farmers Cooperative',
    color: Color(0xFF1565C0),
    icon: AppIcons.tractor,
  ),
];
