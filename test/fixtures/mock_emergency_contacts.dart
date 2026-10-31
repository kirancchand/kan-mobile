import 'package:mv_app/data/models/emergency_contact.dart';
import 'package:mv_app/core/theme/app_icons.dart';

final List<EmergencyContact> mockEmergencyContacts = [
  const EmergencyContact(
      id: 'ec_1',
      name: 'Police Station',
      phone: '100',
      icon: AppIcons.shieldCheck),
  const EmergencyContact(
      id: 'ec_2', name: 'Ambulance', phone: '108', icon: AppIcons.ambulance),
  const EmergencyContact(
      id: 'ec_3', name: 'Fire Station', phone: '101', icon: AppIcons.fireTruck),
  const EmergencyContact(
      id: 'ec_4',
      name: 'Panchayat Office',
      phone: '04162-234567',
      icon: AppIcons.buildings),
  const EmergencyContact(
      id: 'ec_5',
      name: 'Primary Health Centre',
      phone: '04162-234890',
      icon: AppIcons.firstAidKit),
  const EmergencyContact(
      id: 'ec_6',
      name: 'Electricity Board (Complaints)',
      phone: '1912',
      icon: AppIcons.lightning),
];
