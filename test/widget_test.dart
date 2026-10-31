import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mv_app/data/services/kan_auth_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mv_app/main.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Splash opens login and validates username and password',
      (tester) async {
    await tester.pumpWidget(const VillageApp());
    expect(find.text('Your village. Closer together.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.ensureVisible(find.text('Log in'));
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your username or mobile number'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    await tester.ensureVisible(find.text('Create an account'));
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('Register & Continue'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });

  test('Failed login cannot create an account or assign a group', () async {
    final groups = WhatsAppGroupRepository();
    final auth = AuthRepository(groups,
        api: KanAuthApi(
            client: MockClient((_) async => http.Response('', 503))));
    addTearDown(auth.dispose);
    await expectLater(
        auth.login('9999999999', password: 'test-password'), throwsStateError);
    expect(auth.tokens, isNull);
    expect(auth.registeredUsers, isEmpty);
    expect(groups.groupsFor('loc_1'), isEmpty);
  });
}
