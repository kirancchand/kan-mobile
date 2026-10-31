import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mv_app/core/theme/app_tokens.dart';
import 'package:mv_app/state/cart_state.dart';
import 'package:mv_app/features/profile/received_orders_screen.dart';

void main() {
  test('Accounts never inherit fabricated received or delivery orders', () {
    final cart = CartState();
    addTearDown(cart.dispose);
    for (final id in [null, 'buyer', 'seller', null]) {
      cart.setUser(id);
      expect(cart.orders, isEmpty);
      expect(cart.receivedOrders, isEmpty);
      expect(cart.deliveryOrders, isEmpty);
    }
    expect(() => cart.markReadyForShipping('DEMO-1'), throwsStateError);
  });
  testWidgets('Received orders renders its empty state', (tester) async {
    final cart = CartState()..setUser('seller');
    addTearDown(cart.dispose);
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: cart,
        child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.light]),
            home: const ReceivedOrdersScreen())));
    expect(find.textContaining('DEMO-'), findsNothing);
    expect(cart.receivedOrders, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
