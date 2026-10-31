import '../data/models/map_location.dart';
import 'package:flutter/foundation.dart';
import '../data/models/cart_item.dart';
import 'delivery_session.dart';

/// Session cart. Checkout requires a connected order service.
class CartState extends ChangeNotifier {
  CartState({DeliverySession? deliverySession})
      : _deliverySession = deliverySession ?? DeliverySession(),
        _ownsDeliverySession = deliverySession == null {
    _deliverySession.addListener(notifyListeners);
  }
  final DeliverySession _deliverySession;
  final bool _ownsDeliverySession;

  @override
  void dispose() {
    _deliverySession.removeListener(notifyListeners);
    if (_ownsDeliverySession) _deliverySession.dispose();
    super.dispose();
  }

  List<PurchaseOrder> get deliveryOrders {
    final courier = _deliverySession.currentUser;
    if (courier == null) return const [];
    return List.unmodifiable(_orders.expand((order) {
      final regionalLines = order.lines
          .where((line) =>
              line.item.pickupLocationId == courier.locationId &&
              (line.status == PurchaseStatus.readyForShipping ||
                  (line.status == PurchaseStatus.pickedUp &&
                      line.pickedUpById == courier.id)))
          .toList();
      return regionalLines.isEmpty
          ? <PurchaseOrder>[]
          : [order.withLines(regionalLines)];
    }));
  }

  void pickUp(String orderId, String itemKey) {
    final courier = _deliverySession.currentUser;
    if (courier == null) throw StateError('Delivery login is required.');
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index < 0) throw StateError('Order not found.');
    final order = _orders[index];
    final lineIndex =
        order.lines.indexWhere((line) => line.item.key == itemKey);
    if (lineIndex < 0) throw StateError('Item not found.');
    final line = order.lines[lineIndex];
    if (line.item.pickupLocationId != courier.locationId) {
      throw StateError('This item is outside your delivery region.');
    }
    if (line.status != PurchaseStatus.readyForShipping) {
      throw StateError('This item is not awaiting pickup.');
    }
    final updated = [...order.lines];
    updated[lineIndex] = CartLine(line.item, line.quantity,
        status: PurchaseStatus.pickedUp,
        pickedUpById: courier.id,
        pickedUpByName: courier.name,
        pickedUpAt: DateTime.now());
    _orders[index] = order.withLines(updated);
    notifyListeners();
  }

  final Map<String, CartLine> _lines = {};
  final List<PurchaseOrder> _orders = [];
  MapLocation? _deliveryPoint;
  MapLocation? get deliveryPoint => _deliveryPoint;
  void setDeliveryPoint(MapLocation? point) {
    _deliveryPoint = point;
    notifyListeners();
  }

  String? _userId;
  String _userName = 'Guest';
  String _userPhone = '';
  bool get isSignedIn => _userId != null;
  List<CartLine> get lines => List.unmodifiable(_lines.values);
  // Keep the session ledger private and expose only the current account's view.
  List<PurchaseOrder> get orders =>
      List.unmodifiable(_orders.where((order) => order.buyerId == _userId));

  List<PurchaseOrder> get receivedOrders {
    if (_userId == null) return const [];
    return List.unmodifiable(_orders.expand((order) {
      final sellerLines =
          order.lines.where((line) => line.item.sellerId == _userId).toList();
      if (sellerLines.isEmpty) return <PurchaseOrder>[];
      return [order.withLines(sellerLines)];
    }));
  }

  int get count =>
      _lines.values.fold(0, (total, line) => total + line.quantity);
  int get totalPaise =>
      _lines.values.fold(0, (total, line) => total + line.totalPaise);

  void setUser(String? id, {String name = 'Guest', String phone = ''}) {
    final sameUser = _userId == id;
    final sameDetails = _userName == name && _userPhone == phone;
    _userName = name;
    _userPhone = phone;
    if (sameUser && sameDetails) return;
    if (sameUser) {
      notifyListeners();
      return;
    }
    _userId = id;
    _lines.clear();
    _deliveryPoint = null;
    // Anonymous orders cannot be recovered under another account.
    _orders.removeWhere((order) => order.buyerId == null);
    notifyListeners();
  }

  void add(CartItem item) {
    if (!item.isAvailable) {
      throw StateError('This item is no longer available.');
    }
    final quantity = (_lines[item.key]?.quantity ?? 0) + 1;
    if (quantity > 99) throw StateError('Maximum quantity is 99 per item.');
    _lines[item.key] = CartLine(item, quantity);
    notifyListeners();
  }

  void setQuantity(String key, int quantity) {
    final line = _lines[key];
    if (line == null) return;
    if (quantity < 0 || quantity > 99) throw ArgumentError('Invalid quantity');
    if (quantity == 0) {
      _lines.remove(key);
    } else {
      _lines[key] = CartLine(line.item, quantity);
    }
    notifyListeners();
  }

  /// A seller can update only their own lines in the selected order.
  void markReadyForShipping(String orderId) {
    if (_userId == null) throw StateError('Sign in to update received orders.');
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index < 0) throw StateError('Order not found.');
    final order = _orders[index];
    final ownedLines =
        order.lines.where((line) => line.item.sellerId == _userId);
    if (ownedLines.isEmpty) {
      throw StateError('This order has no items from you.');
    }
    if (ownedLines.every((line) => line.status != PurchaseStatus.received)) {
      return;
    }
    _orders[index] = order.withLines([
      for (final line in order.lines)
        if (line.item.sellerId == _userId &&
            line.status == PurchaseStatus.received)
          CartLine(line.item, line.quantity,
              status: PurchaseStatus.readyForShipping)
        else
          line,
    ]);
    notifyListeners();
  }

  PurchaseOrder checkout() {
    throw StateError('Checkout is not available. No order has been placed.');
  }
}
