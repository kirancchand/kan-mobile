import 'map_location.dart';
import 'book_listing.dart';
import 'marketplace_listing.dart';
import 'service_type.dart';

/// A purchasable listing snapshot; amounts are stored in paise.
class CartItem {
  CartItem._(
      {required this.id,
      required this.service,
      required this.title,
      required this.seller,
      required this.sellerId,
      required this.pickupLocationId,
      required this.pickupPoint,
      required this.sellerPhone,
      required this.unitPricePaise,
      required bool Function() available})
      : _available = available;

  factory CartItem.marketplace(MarketplaceListing listing) => CartItem._(
      id: listing.id,
      service: listing.serviceType,
      title: listing.title,
      seller: listing.sellerName,
      sellerId: listing.sellerId,
      pickupLocationId: listing.locationId,
      pickupPoint: listing.pickupPoint,
      sellerPhone: listing.sellerPhone,
      unitPricePaise: _price(listing.price),
      available: () =>
          listing.serviceType.isGenericMarketplace && listing.isAvailable);

  factory CartItem.book(BookListing book) => CartItem._(
      id: book.id,
      service: ServiceType.library,
      title: book.title,
      seller: book.ownerName,
      sellerId: book.ownerId,
      pickupLocationId: book.locationId,
      pickupPoint: book.pickupPoint,
      sellerPhone: book.ownerPhone,
      unitPricePaise: _price(book.price),
      available: () => book.listingType == BookListingType.sell);

  static int _price(double price) {
    if (!price.isFinite || price < 0) throw ArgumentError('Invalid item price');
    return (price * 100).round();
  }

  final String id;
  final ServiceType service;
  final String title;
  final String seller;
  final String? sellerId;
  final String? pickupLocationId;
  final MapLocation? pickupPoint;
  final String sellerPhone;
  final int unitPricePaise;
  final bool Function() _available;
  String get key => '${service.name}:$id';
  bool get isAvailable => _available();
}

enum PurchaseStatus {
  received('Received'),
  readyForShipping('Ready for shipping'),
  pickedUp('Picked up');

  const PurchaseStatus(this.label);
  final String label;
}

class CartLine {
  const CartLine(this.item, this.quantity,
      {this.status = PurchaseStatus.received,
      this.pickedUpById,
      this.pickedUpByName,
      this.pickedUpAt});
  final CartItem item;
  final int quantity;
  final PurchaseStatus status;
  final String? pickedUpById;
  final String? pickedUpByName;
  final DateTime? pickedUpAt;
  int get totalPaise => item.unitPricePaise * quantity;
}

class PurchaseOrder {
  PurchaseOrder(
      {required this.id,
      required this.createdAt,
      this.buyerId,
      this.buyerName = 'Guest',
      this.buyerPhone = '',
      this.deliveryPoint,
      required List<CartLine> lines})
      : lines = List.unmodifiable(lines);
  final String id;
  final DateTime createdAt;
  final String? buyerId;
  final String buyerName;
  final String buyerPhone;
  final MapLocation? deliveryPoint;
  final List<CartLine> lines;

  bool get isReadyForShipping =>
      lines.isNotEmpty &&
      lines.every((line) => line.status == PurchaseStatus.readyForShipping);

  bool get canMarkReady =>
      lines.any((line) => line.status == PurchaseStatus.received);

  String get statusLabel {
    if (lines.isNotEmpty &&
        lines.every((line) => line.status == PurchaseStatus.pickedUp)) {
      return 'Picked up';
    }
    if (lines.any((line) => line.status == PurchaseStatus.pickedUp)) {
      return 'Partially picked up';
    }
    return isReadyForShipping ? 'Ready for shipping' : 'Received';
  }

  PurchaseOrder withLines(List<CartLine> updatedLines) => PurchaseOrder(
        id: id,
        createdAt: createdAt,
        buyerId: buyerId,
        buyerName: buyerName,
        buyerPhone: buyerPhone,
        deliveryPoint: deliveryPoint,
        lines: updatedLines,
      );
  int get totalPaise => lines.fold(0, (total, line) => total + line.totalPaise);
}
