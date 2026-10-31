import 'package:mv_app/data/models/village_event.dart';

final DateTime _now = DateTime.now();

final List<VillageEvent> mockEvents = [
  VillageEvent(
    id: 'evt_1',
    title: 'Gram Sabha Meeting',
    description: 'Monthly village council meeting — all residents welcome.',
    category: EventCategory.event,
    dateTime: _now.add(const Duration(days: 2, hours: 3)),
    location: 'Panchayat Office',
  ),
  VillageEvent(
    id: 'evt_2',
    title: 'Water Supply Maintenance',
    description:
        'Water supply will be interrupted from 10 AM to 2 PM for pipeline repair.',
    category: EventCategory.announcement,
    dateTime: _now.add(const Duration(days: 1)),
    location: 'Entire Village',
  ),
  VillageEvent(
    id: 'evt_3',
    title: 'New Bus Timing',
    description:
        'The 7:45 AM bus to the district town has been rescheduled to 8:15 AM.',
    category: EventCategory.update,
    dateTime: _now.subtract(const Duration(hours: 5)),
    location: 'Bus Stand',
  ),
  VillageEvent(
    id: 'evt_4',
    title: 'Blood Donation Camp',
    description:
        'Organized with the district hospital. Donors will receive a certificate.',
    category: EventCategory.event,
    dateTime: _now.add(const Duration(days: 5)),
    location: 'Community Hall',
  ),
  VillageEvent(
    id: 'evt_5',
    title: 'Road Repair Completed',
    description:
        'The main road near the temple has been repaved and reopened to traffic.',
    category: EventCategory.update,
    dateTime: _now.subtract(const Duration(days: 1)),
    location: 'Temple Road',
  ),
];
