import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mv_app/core/theme/app_theme.dart';
import 'package:mv_app/core/widgets/village_bottom_bar.dart';

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final rtl in [false, true]) {
    testWidgets('Bottom bar switches every tab, rtl=$rtl', (tester) async {
      var selected = 0;
      await tester.pumpWidget(MaterialApp(
        theme: rtl ? AppTheme.dark : AppTheme.light,
        home: StatefulBuilder(
            builder: (context, setState) => Directionality(
                  textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                  child: MediaQuery(
                    data: const MediaQueryData(
                      size: Size(320, 640),
                      padding: EdgeInsets.only(bottom: 24),
                      textScaler: TextScaler.linear(2),
                      disableAnimations: true,
                    ),
                    child: Scaffold(
                      bottomNavigationBar: VillageBottomBar(
                        selectedIndex: selected,
                        onSelected: (value) => setState(() => selected = value),
                      ),
                    ),
                  ),
                )),
      ));
      for (final (index, label)
          in ['Home', 'Services', 'Profile', 'Admin'].indexed) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(selected, index);
        expect(tester.takeException(), isNull);
      }
    });
  }
}
