import 'package:mv_app/features/profile/my_orders_screen.dart';
import 'package:mv_app/data/repositories/delivery_repository.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mv_app/core/theme/app_theme.dart';
import 'package:mv_app/data/models/book_listing.dart';
import 'package:mv_app/data/models/cart_item.dart';
import 'package:mv_app/data/models/marketplace_listing.dart';
import 'package:mv_app/data/models/service_type.dart';
import 'package:mv_app/features/cart/cart_screen.dart';
import 'package:mv_app/features/services/marketplace/marketplace_detail_screen.dart';
import 'package:mv_app/features/services/library/book_detail_screen.dart';
import 'package:mv_app/state/cart_state.dart';

MarketplaceListing listing(ServiceType service, {bool available = true}) =>
    MarketplaceListing(
      id: 'same-id',
      serviceType: service,
      title: '${service.name} item',
      description: 'A local item',
      price: 12.35,
      category: 'Other',
      condition: ListingCondition.newItem,
      sellerName: 'Seller',
      sellerPhone: '123',
      location: 'Village',
      postedAt: DateTime(2026),
      icon: Icons.shopping_bag,
      color: Colors.blue,
      isAvailable: available,
    );
BookListing book(BookListingType type) => BookListing(
    id: 'same-id',
    title: 'Book',
    author: 'Author',
    listingType: type,
    price: 20.25,
    ownerName: 'Owner',
    ownerPhone: '123',
    genre: 'Fiction',
    postedAt: DateTime(2026));

Widget app(CartState cart, Widget home, {bool dark = false}) =>
    ChangeNotifierProvider.value(
        value: cart,
        child: MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.6)),
                child: child!),
            home: home));

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  testWidgets(
      'Cart confirmation expires after three seconds and View cart still works',
      (tester) async {
    final cart = CartState();
    await tester.pumpWidget(app(
        cart, MarketplaceDetailScreen(listing: listing(ServiceType.buySell))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to cart'));
    await tester.pumpAndSettle();
    expect(find.text('buySell item added to cart'), findsOneWidget);
    expect(find.text('View cart'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('View cart'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('buySell item added to cart'), findsNothing);
    expect(cart.count, 1);
    await tester.tap(find.text('Add to cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View cart'));
    await tester.pumpAndSettle();
    expect(find.text('Your cart'), findsOneWidget);
    expect(cart.count, 2);
  });
  testWidgets('Repeated additions do not leave queued cart confirmations',
      (tester) async {
    final cart = CartState();
    await tester.pumpWidget(app(
        cart, MarketplaceDetailScreen(listing: listing(ServiceType.plants))));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Add to cart'));
      await tester.pumpAndSettle();
    }
    expect(cart.count, 3);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });
  test(
      'Mixed services retain quantities and totals when checkout is unavailable',
      () {
    final cart = CartState();
    final plant = CartItem.marketplace(listing(ServiceType.plants));
    cart.add(plant);
    cart.add(plant);
    cart.add(CartItem.marketplace(listing(ServiceType.cake)));
    cart.add(CartItem.book(book(BookListingType.sell)));
    expect(cart.lines.length, 3);
    expect(cart.count, 4);
    expect(cart.totalPaise, 5730);
    expect(cart.checkout, throwsStateError);
    expect(cart.count, 4);
    expect(cart.orders, isEmpty);
  });
  test('Unavailable, rental and wanted items cannot be purchased', () {
    final cart = CartState();
    final source = listing(ServiceType.pharmacy);
    cart.add(CartItem.marketplace(source));
    source.isAvailable = false;
    expect(cart.checkout, throwsStateError);
    expect(cart.count, 1);
    expect(cart.orders, isEmpty);
    expect(() => cart.add(CartItem.marketplace(source)), throwsStateError);
    for (final type in [BookListingType.rent, BookListingType.buy]) {
      expect(() => cart.add(CartItem.book(book(type))), throwsStateError);
    }
  });
  test('Quantity bounds and account changes protect session contents', () {
    final cart = CartState()..setUser('one');
    final item = CartItem.marketplace(listing(ServiceType.buySell));
    cart.add(item);
    cart.setQuantity(item.key, 99);
    expect(() => cart.add(item), throwsStateError);
    expect(() => cart.setQuantity(item.key, -1), throwsArgumentError);
    expect(cart.checkout, throwsStateError);
    cart.setQuantity(item.key, 1);
    cart.setUser('one');
    expect(cart.count, 1);
    cart.setUser(null);
    expect(cart.lines, isEmpty);
    expect(cart.orders, isEmpty);
    cart.setUser('two');
    expect(cart.orders, isEmpty);
  });
  for (final service
      in ServiceType.values.where((s) => s.isGenericMarketplace)) {
    testWidgets('${service.name} adds items and Buy now opens shared cart',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 740));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final cart = CartState();
      await tester.pumpWidget(app(
          cart, MarketplaceDetailScreen(listing: listing(service)),
          dark: true));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to cart'));
      await tester.pumpAndSettle();
      expect(cart.count, 1);
      await tester.tap(find.text('Buy now'));
      await tester.pumpAndSettle();
      expect(find.text('Your cart'), findsOneWidget);
      expect(cart.count, 2);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('For-sale books use the shared cart', (tester) async {
    final cart = CartState();
    await tester.pumpWidget(
        app(cart, BookDetailScreen(book: book(BookListingType.sell))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to cart'));
    await tester.pumpAndSettle();
    expect(cart.lines.single.item.service, ServiceType.library);
    expect(tester.takeException(), isNull);
  });
  testWidgets('My Orders does not manufacture receipts from a cart',
      (tester) async {
    final cart = CartState()..add(CartItem.book(book(BookListingType.sell)));
    expect(cart.checkout, throwsStateError);
    final groups = WhatsAppGroupRepository();
    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: cart),
          ChangeNotifierProvider(
              create: (_) => AppState(
                  whatsAppGroupRepository: groups,
                  authRepository: AuthRepository(groups))),
          Provider(create: (_) => DeliveryRepository()),
        ],
        child:
            MaterialApp(theme: AppTheme.light, home: const MyOrdersScreen())));
    await tester.pumpAndSettle();
    expect(find.textContaining('DEMO-'), findsNothing);
    expect(cart.orders, isEmpty);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Rental and wanted details do not expose purchase actions',
      (tester) async {
    for (final type in [BookListingType.rent, BookListingType.buy]) {
      await tester
          .pumpWidget(app(CartState(), BookDetailScreen(book: book(type))));
      await tester.pumpAndSettle();
      expect(find.text('Add to cart'), findsNothing);
      expect(find.text('Buy now'), findsNothing);
    }
  });
  testWidgets('Unavailable listings disable purchase controls', (tester) async {
    final cart = CartState();
    await tester.pumpWidget(app(
        cart,
        MarketplaceDetailScreen(
            listing: listing(ServiceType.plants, available: false))));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Buy now'))
            .onPressed,
        isNull);
    expect(
        tester
            .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Unavailable'))
            .onPressed,
        isNull);
    expect(cart.lines, isEmpty);
  });
  for (final dark in [false, true]) {
    testWidgets('Cart edits work while checkout is unavailable, dark=$dark',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 740));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final cart = CartState()
        ..add(CartItem.marketplace(listing(ServiceType.plants)));
      await tester.pumpWidget(app(cart, const CartScreen(), dark: dark));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Increase plants item'));
      await tester.pumpAndSettle();
      expect(cart.totalPaise, 2470);
      await tester.scrollUntilVisible(find.text('Checkout unavailable'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(
          tester
              .widget<FilledButton>(
                  find.widgetWithText(FilledButton, 'Checkout unavailable'))
              .onPressed,
          isNull);
      expect(cart.count, 2);
      expect(cart.orders, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}
