import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:mv_app/core/theme/app_theme.dart';
import 'package:mv_app/data/repositories/admin_repository.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/data/services/kan_auth_api.dart';
import 'package:mv_app/data/services/kan_master_api.dart';
import 'package:mv_app/features/admin/admin_entry_screen.dart';
import 'package:mv_app/state/admin_state.dart';

class _Auth extends AuthRepository {
  _Auth() : super(WhatsAppGroupRepository());
  @override
  KanLoginTokens? get tokens => const KanLoginTokens(accessToken: 'token');
}

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  testWidgets('Large districts open and an area loads its branches', (tester) async {
    final requested = <String>[];
    final api = KanMasterApi(
        baseUrl: 'https://example.test/kan',
        client: MockClient((request) async {
          final path = request.url.path;
          requested.add(path);
          if (path.endsWith('/state/getAll')) {
            return http.Response(jsonEncode([{'state_id': 42, 'state': 'Kerala'}]), 200);
          }
          if (path.endsWith('/district/getByState/42')) {
            return http.Response(jsonEncode([
              for (var i = 1; i <= 14; i++) {'district_id': i, 'district': 'District $i'}
            ]), 200);
          }
          if (path.contains('/area/getByDistrict/')) {
            final d = path.split('/').last;
            return http.Response(jsonEncode([
              for (var i = 0; i < 300; i++) {'area_id': '$d$i', 'area_name': 'Area $d-$i'}
            ]), 200);
          }
          if (path.contains('/branch/getByArea/')) {
            return http.Response(jsonEncode({'data': [{'branch_id': 1, 'branch': 'Branch X'}]}), 200);
          }
          return http.Response('[]', 200);
        }));
    final auth = _Auth();
    final adminState = AdminState();
    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider.value(value: adminState),
      Provider<AuthRepository?>.value(value: auth),
      Provider(create: (_) => AdminRepository(
          assignedAccounts: const [AdminRepository.everyoneAccount], masterApi: api)),
    ], child: MaterialApp(theme: AppTheme.light, home: const AdminEntryScreen())));
    await tester.pumpAndSettle();
    Future<void> open(String text) async {
      final f = find.text(text);
      await tester.scrollUntilVisible(f, 300, maxScrolls: 500, scrollable: find.byType(Scrollable).first);
      await tester.tap(f.first);
      await tester.pumpAndSettle();
    }
    await open('State Admin • Kerala');
    // Areas from every visited district stay loaded, as in real browsing.
    await open('District Admin • District 2');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await open('District Admin • District 3');
    await open('Area Admin • Area 3-150');
    expect(requested.where((p) => p.contains('/branch/getByArea/')),
        ['/kan/master/branch/getByArea/3150']);
    await tester.scrollUntilVisible(find.text('Branch Admin • Branch X'), 300,
        maxScrolls: 50, scrollable: find.byType(Scrollable).first);
    expect(find.text('Branch Admin • Branch X'), findsOneWidget);
  });
}
