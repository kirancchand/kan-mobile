import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mv_app/features/delivery/delivery_entry_screen.dart';
import 'package:mv_app/state/delivery_session.dart';

void main() {
  test('Former demo credentials cannot create a delivery session', () async {
    final session = DeliverySession();
    addTearDown(session.dispose);
    await expectLater(session.login('9000000001', '2468'), throwsStateError);
    expect(session.currentUser, isNull);
  });

  testWidgets('Delivery entry contains no selectable demo accounts',
      (tester) async {
    final session = DeliverySession();
    addTearDown(session.dispose);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: session,
      child: const MaterialApp(home: DeliveryEntryScreen()),
    ));
    expect(find.text('Demo delivery accounts'), findsNothing);
    expect(find.textContaining('Delivery sign-in is not available'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
