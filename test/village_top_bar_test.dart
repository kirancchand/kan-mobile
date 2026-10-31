import 'package:provider/provider.dart';
import 'package:mv_app/state/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mv_app/core/theme/app_theme.dart';
import 'package:mv_app/core/widgets/village_top_bar.dart';

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Header opens notifications and cart with back navigation',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => CartState(),
        child: MaterialApp(
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const Scaffold(
              appBar: VillageTopBar(subtitle: Text('Home • Our village'))),
        )));
    expect(find.text('Village Connect'), findsOneWidget);
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('You’re all caught up'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('Browse local listings'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Village Connect'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
