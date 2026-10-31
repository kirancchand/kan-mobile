import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mv_app/core/theme/app_theme.dart';
import 'package:mv_app/data/models/admin_hierarchy.dart';
import 'package:mv_app/data/repositories/admin_repository.dart';
import 'package:mv_app/features/admin/admin_entry_screen.dart';
import 'package:mv_app/state/admin_state.dart';

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Admin tab opens the Main Admin dashboard for every user',
      (tester) async {
    final adminState = AdminState();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: adminState),
        Provider(
            create: (_) => AdminRepository(
                assignedAccounts: const [AdminRepository.everyoneAccount])),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const AdminEntryScreen()),
    ));
    await tester.pump();
    await tester.pump();

    expect(adminState.account?.id, AdminRepository.everyoneAccount.id);
    expect(find.text(AdminLevel.main.label), findsOneWidget);
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.textContaining('sign-in is not available'), findsNothing);
  });

  testWidgets('Without a main account the tab keeps the unavailable notice',
      (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminState()),
        Provider(create: (_) => AdminRepository()),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const AdminEntryScreen()),
    ));
    await tester.pump();
    expect(find.textContaining('sign-in is not available'), findsOneWidget);
  });
}
