import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:mv_app/core/theme/app_tokens.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/data/services/kan_auth_api.dart';
import 'package:mv_app/features/onboarding/login_screen.dart';
import 'package:mv_app/state/app_state.dart';

void main() {
  test('Login matches Postman and retains tokens until sign-out', () async {
    late http.Request sent;
    final groups = WhatsAppGroupRepository();
    final auth = AuthRepository(groups,
        api: KanAuthApi(client: MockClient((request) async {
      sent = request;
      return http.Response(
          '{"access_token":"access-test","refresh_token":"refresh-test","userInfo":{"message":"Listed Successfully!!","status":200,"data":{"user_id":42,"mobno":"09876543210","email_id":"owner@example.com"}}}',
          200);
    })));
    final app = AppState(whatsAppGroupRepository: groups, authRepository: auth);
    addTearDown(app.dispose);
    addTearDown(auth.dispose);
    await app.login('  kiran3 ', password: ' secret ');
    expect(sent.method, 'POST');
    expect(sent.url.toString(), 'http://localhost:8084/auth/login');
    expect(sent.headers['Content-Type'], 'application/json');
    expect(sent.headers.containsKey('Authorization'), isFalse);
    expect(
        jsonDecode(sent.body), {'username': 'kiran3', 'password': ' secret '});
    expect(auth.tokens!.accessToken, 'access-test');
    expect(auth.tokens!.refreshToken, 'refresh-test');
    expect(auth.tokens!.userId, 42);
    expect(auth.tokens!.mobileNumber, '09876543210');
    expect(auth.tokens!.email, 'owner@example.com');
    expect(app.currentUser!.locationId, isEmpty);
    expect(app.currentUser!.id, '42');
    expect(auth.registeredUsers, isEmpty);
    app.signOut();
    expect(auth.tokens, isNull);
    expect(app.currentUser, isNull);
  });

  for (final id in [42, '42']) {
    test('Login reads nested userInfo.user_id (${id.runtimeType})', () async {
      final api = KanAuthApi(
          client: MockClient((_) async => http.Response(
              jsonEncode({
                'access_token': 'test',
                'userInfo': {'user_id': id},
                'userid': 99,
              }),
              200)));
      addTearDown(api.dispose);
      final tokens = await api.login(username: 'owner', password: 'test');
      expect(tokens.userId, 42);
    });
  }

  for (final id in [625, '625']) {
    test('Login reads userInfo.data.user_id (${id.runtimeType})', () async {
      final api = KanAuthApi(
          client: MockClient((_) async => http.Response(
              jsonEncode({
                'access_token': 'test',
                'userInfo': {
                  'message': 'Listed Successfully!!',
                  'status': 200,
                  'data': {'user_id': id},
                  'user_id': 99,
                },
                'userid': 98,
              }),
              200)));
      addTearDown(api.dispose);
      final tokens = await api.login(username: 'owner', password: 'test');
      expect(tokens.userId, 625);
    });
  }

  for (final failure in [
    '401',
    '500',
    'network',
    'timeout',
    'malformed',
    'missing token'
  ]) {
    test('$failure rejects login without a session or registration', () async {
      final groups = WhatsAppGroupRepository();
      final api = KanAuthApi(
          timeout: const Duration(milliseconds: 2),
          client: MockClient((_) async {
            if (failure == 'network') throw http.ClientException('offline');
            if (failure == 'timeout') {
              await Future<void>.delayed(const Duration(milliseconds: 10));
            }
            return switch (failure) {
              'malformed' => http.Response('not json', 200),
              'missing token' => http.Response('{}', 200),
              _ => http.Response('', int.tryParse(failure) ?? 503),
            };
          }));
      final auth = AuthRepository(groups, api: api);
      addTearDown(auth.dispose);
      await expectLater(
          auth.login('new-user', password: 'test'), throwsA(anything));
      expect(auth.tokens, isNull);
      expect(auth.registeredUsers, isEmpty);
      expect(groups.groupsFor('loc_1'), isEmpty);
    });
  }

  test('Failed login clears previous API tokens', () async {
    var calls = 0;
    final auth = AuthRepository(WhatsAppGroupRepository(),
        api: KanAuthApi(client: MockClient((_) async {
      return ++calls == 1
          ? http.Response('{"access_token":"test"}', 200)
          : http.Response('', 401);
    })));
    addTearDown(auth.dispose);
    await auth.login('first', password: 'test');
    expect(auth.tokens, isNotNull);
    await expectLater(auth.login('second', password: 'test'), throwsStateError);
    expect(auth.tokens, isNull);
  });

  test('Sign-out cancels pending login and concurrent attempts are blocked',
      () async {
    final response = Completer<http.Response>();
    final groups = WhatsAppGroupRepository();
    final auth = AuthRepository(groups,
        api: KanAuthApi(client: MockClient((_) => response.future)));
    final app = AppState(whatsAppGroupRepository: groups, authRepository: auth);
    addTearDown(app.dispose);
    addTearDown(auth.dispose);
    final pending = app.login('first', password: 'test');
    await expectLater(app.login('second', password: 'test'), throwsStateError);
    app.signOut();
    final cancelled = expectLater(pending, throwsStateError);
    response.complete(http.Response('{"access_token":"late"}', 200));
    await cancelled;
    expect(app.currentUser, isNull);
    expect(auth.tokens, isNull);
  });

  testWidgets('Login form validates credentials and shows an error on failure',
      (tester) async {
    final groups = WhatsAppGroupRepository();
    final auth = AuthRepository(groups,
        api: KanAuthApi(
            client: MockClient((_) async => http.Response('', 503))));
    final app = AppState(whatsAppGroupRepository: groups, authRepository: auth);
    addTearDown(app.dispose);
    addTearDown(auth.dispose);
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: app,
        child: MaterialApp(
          theme: ThemeData(extensions: [AppTokens.light]),
          home: const LoginScreen(),
        )));
    await tester.ensureVisible(find.text('Log in'));
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your username or mobile number'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey('login-username')), 'test-user');
    await tester.enterText(
        find.byKey(const ValueKey('login-password')), 'test-password');
    expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('login-password')))
            .controller!
            .text,
        'test-password');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Log in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(app.isRegistered, isFalse);
    expect(app.currentUser, isNull);
    expect(find.text('Login service rejected the request.'), findsOneWidget);
  });
}
