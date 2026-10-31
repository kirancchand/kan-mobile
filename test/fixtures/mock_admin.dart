import 'package:mv_app/data/models/admin_models.dart';

final DateTime _now = DateTime.now();

/// Registered entities keyed by locationId.
final Map<String, List<RegisteredEntity>> mockRegisteredEntities = {
  'loc_1': [
    RegisteredEntity(
        id: 're_1',
        name: 'Sri Ganesh Store',
        type: 'Business',
        category: 'Grocery',
        registeredOn: _now.subtract(const Duration(days: 200))),
    RegisteredEntity(
        id: 're_2',
        name: 'Ravi Kumar',
        type: 'Resident',
        category: 'Individual',
        registeredOn: _now.subtract(const Duration(days: 40))),
    RegisteredEntity(
        id: 're_3',
        name: 'Lakshmi Medicals',
        type: 'Business',
        category: 'Pharmacy',
        registeredOn: _now.subtract(const Duration(days: 150))),
    RegisteredEntity(
        id: 're_4',
        name: 'Meena Devi',
        type: 'Resident',
        category: 'Individual',
        registeredOn: _now.subtract(const Duration(days: 12))),
  ],
  'loc_2': [
    RegisteredEntity(
        id: 're_5',
        name: 'Sweet Treats Bakery',
        type: 'Business',
        category: 'Bakery',
        registeredOn: _now.subtract(const Duration(days: 90))),
    RegisteredEntity(
        id: 're_6',
        name: 'Farida Begum',
        type: 'Resident',
        category: 'Individual',
        registeredOn: _now.subtract(const Duration(days: 25))),
  ],
  'loc_3': [
    RegisteredEntity(
        id: 're_7',
        name: 'Nursery Ramesh',
        type: 'Business',
        category: 'Plants',
        registeredOn: _now.subtract(const Duration(days: 60))),
  ],
};

/// Transactions keyed by locationId.
final Map<String, List<LocationTransaction>> mockTransactions = {
  'loc_1': [
    LocationTransaction(
        id: 'tx_1',
        serviceLabel: 'Buy & Sell',
        description: 'Study Table with Chair',
        amount: 1500,
        timestamp: _now.subtract(const Duration(hours: 4))),
    LocationTransaction(
        id: 'tx_2',
        serviceLabel: 'Pharmacy',
        description: 'Paracetamol strip',
        amount: 25,
        timestamp: _now.subtract(const Duration(hours: 1))),
    LocationTransaction(
        id: 'tx_3',
        serviceLabel: 'Delivery',
        description: 'Grocery delivery fee',
        amount: 30,
        timestamp: _now.subtract(const Duration(minutes: 40))),
  ],
  'loc_2': [
    LocationTransaction(
        id: 'tx_4',
        serviceLabel: 'Cake Marketplace',
        description: 'Vanilla Birthday Cake',
        amount: 350,
        timestamp: _now.subtract(const Duration(days: 1, hours: 2))),
    LocationTransaction(
        id: 'tx_5',
        serviceLabel: 'Ride Pool',
        description: 'Sundarpalli -> Vijayawada (2 seats)',
        amount: 400,
        timestamp: _now.subtract(const Duration(hours: 6))),
  ],
  'loc_3': [
    LocationTransaction(
        id: 'tx_6',
        serviceLabel: 'Plants',
        description: 'Mango Sapling',
        amount: 250,
        timestamp: _now.subtract(const Duration(days: 3))),
  ],
};

/// Consolidated per-location analytics, as viewed by the Head Admin, and by
/// each Location Admin for their own row.
final List<LocationAnalytics> mockLocationAnalytics = [
  LocationAnalytics(
    locationId: 'loc_1',
    locationName: 'Rampura',
    activeUsers: 842,
    registeredBusinesses: 18,
    whatsAppGroupCount: 1,
    totalWhatsAppMembers: 612,
    totalTransactionValue: 1555,
    serviceUsageCounts: const {
      'Buy & Sell': 34,
      'Pharmacy': 51,
      'Delivery': 22,
      'Plants': 10,
      'Cake Marketplace': 8,
    },
  ),
  LocationAnalytics(
    locationId: 'loc_2',
    locationName: 'Sundarpalli',
    activeUsers: 1290,
    registeredBusinesses: 27,
    whatsAppGroupCount: 2,
    totalWhatsAppMembers: 1290,
    totalTransactionValue: 750,
    serviceUsageCounts: const {
      'Ride Pool': 40,
      'Cake Marketplace': 15,
      'Library': 12,
      'Buy & Sell': 20,
    },
  ),
  LocationAnalytics(
    locationId: 'loc_3',
    locationName: 'Kothapet',
    activeUsers: 356,
    registeredBusinesses: 9,
    whatsAppGroupCount: 1,
    totalWhatsAppMembers: 356,
    totalTransactionValue: 250,
    serviceUsageCounts: const {
      'Plants': 14,
      'Ride Pool': 9,
    },
  ),
  LocationAnalytics(
    locationId: 'loc_4',
    locationName: 'Devipura',
    activeUsers: 512,
    registeredBusinesses: 11,
    whatsAppGroupCount: 1,
    totalWhatsAppMembers: 512,
    totalTransactionValue: 180,
    serviceUsageCounts: const {
      'Ride Pool': 18,
      'Pharmacy': 22,
    },
  ),
  LocationAnalytics(
    locationId: 'loc_5',
    locationName: 'Mannargudi',
    activeUsers: 998,
    registeredBusinesses: 21,
    whatsAppGroupCount: 1,
    totalWhatsAppMembers: 998,
    totalTransactionValue: 400,
    serviceUsageCounts: const {
      'Ride Pool': 12,
      'Buy & Sell': 30,
      'Village YouTube': 5,
    },
  ),
];
