import 'package:mv_app/data/models/delivery_order.dart';

final DateTime _now = DateTime.now();

final List<DeliveryOrder> mockDeliveries = [
  DeliveryOrder(
    id: 'dl_1',
    itemDescription: 'Grocery bag from Sri Ganesh Store',
    pickupAddress: 'Sri Ganesh Store, Main Road',
    dropAddress: '12, Temple Street',
    requestedBy: 'Anitha Rao',
    fee: 30,
    status: DeliveryStatus.onTheWay,
    requestedAt: _now.subtract(const Duration(minutes: 40)),
  ),
  DeliveryOrder(
    id: 'dl_2',
    itemDescription: 'Medicines from Lakshmi Medicals',
    pickupAddress: 'Lakshmi Medicals',
    dropAddress: '7, Farmer Colony',
    requestedBy: 'Mohan Das',
    fee: 20,
    status: DeliveryStatus.delivered,
    requestedAt: _now.subtract(const Duration(hours: 3)),
  ),
  DeliveryOrder(
    id: 'dl_3',
    itemDescription: 'Documents to Panchayat Office',
    pickupAddress: '4, Lake View Colony',
    dropAddress: 'Panchayat Office',
    requestedBy: 'Divya Sharma',
    fee: 15,
    status: DeliveryStatus.requested,
    requestedAt: _now.subtract(const Duration(minutes: 10)),
  ),
  DeliveryOrder(
    id: 'dl_4',
    itemDescription: 'Cake pickup from Sweet Treats Bakery',
    pickupAddress: 'Sweet Treats Bakery',
    dropAddress: '22, School Road',
    requestedBy: 'Kiran Reddy',
    fee: 25,
    status: DeliveryStatus.pickedUp,
    requestedAt: _now.subtract(const Duration(hours: 1)),
  ),
];
