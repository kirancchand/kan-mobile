import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/data/services/kan_auth_api.dart';
import 'package:mv_app/data/services/kan_master_api.dart';

void main() {
  late AuthRepository auth;
  late KanMasterApi master;
  late int refreshes;
  late int requests;
  late Future<http.Response> Function() refreshResponse;
  late int Function(String) status;

  setUp(() async {
    refreshes = 0;
    requests = 0;
    refreshResponse = () async =>
        http.Response('{"access_token":"new","refresh_token":"rotated"}', 200);
    status = (token) => token == 'Bearer old' ? 401 : 200;
    auth = AuthRepository(WhatsAppGroupRepository(),
        api: KanAuthApi(
            baseUrl: 'https://auth.example/base/',
            client: MockClient((request) async {
              if (request.url.path.endsWith('/login')) {
                return http.Response(
                    '{"access_token":"old","refresh_token":"refresh","userInfo":{"message":"Listed Successfully!!","status":200,"data":{"user_id":42,"mobno":"09876543210","email_id":"owner@example.com"}}}',
                    200);
              }
              refreshes++;
              expect(request.method, 'POST');
              expect(request.url.toString(),
                  'https://auth.example/base/auth/refresh-accesstoken');
              expect(jsonDecode(request.body), {'refresh_token': 'refresh'});
              return refreshResponse();
            })));
    master = KanMasterApi(
        authRepository: auth,
        client: MockClient((request) async {
          requests++;
          return http.Response('[]', status(request.headers['Authorization']!));
        }));
    await auth.login('user', password: 'password');
  });
  tearDown(() {
    master.dispose();
    auth.dispose();
  });

  test('401 refreshes, rotates tokens and retries with new access token',
      () async {
    expect(await master.getStates(accessToken: 'old'), isEmpty);
    expect(refreshes, 1);
    expect(requests, 2);
    expect(auth.tokens!.refreshToken, 'rotated');
    expect(auth.tokens!.userId, 42);
    expect(auth.tokens!.mobileNumber, '09876543210');
    expect(auth.tokens!.email, 'owner@example.com');
    await master.getStates(accessToken: 'old');
    expect(refreshes, 1);
  });

  test('successful requests reuse the access token without refreshing',
      () async {
    status = (token) {
      expect(token, 'Bearer old');
      return 200;
    };
    for (var i = 0; i < 3; i++) {
      await master.getStates(accessToken: 'old');
    }
    expect(refreshes, 0);
    expect(requests, 3);
    expect(auth.tokens!.accessToken, 'old');
  });

  test('concurrent 401 responses share refresh request', () async {
    final pending = Completer<http.Response>();
    final started = Completer<void>();
    refreshResponse = () {
      started.complete();
      return pending.future;
    };
    final first = master.getStates(accessToken: 'old');
    final second = master.getStates(accessToken: 'old');
    await started.future;
    pending.complete(http.Response('{"access_token":"new"}', 200));
    await Future.wait([first, second]);
    expect(refreshes, 1);
    expect(auth.tokens!.refreshToken, 'refresh');
  });

  test('second 401 fails without a refresh loop', () async {
    status = (_) => 401;
    await expectLater(master.getStates(accessToken: 'old'), throwsStateError);
    expect(refreshes, 1);
    expect(requests, 2);
  });

  test('403 does not trigger refresh', () async {
    status = (_) => 403;
    await expectLater(master.getStates(accessToken: 'old'), throwsStateError);
    expect(refreshes, 0);
  });

  for (final response in [http.Response('', 401), http.Response('{}', 200)]) {
    test('refresh failure clears credentials (${response.statusCode})',
        () async {
      refreshResponse = () async => response;
      await expectLater(
          master.getStates(accessToken: 'old'), throwsA(anything));
      expect(auth.tokens, isNull);
      expect(requests, 1);
    });
  }

  test('sign-out prevents pending refresh from restoring session', () async {
    final pending = Completer<http.Response>();
    final started = Completer<void>();
    refreshResponse = () {
      started.complete();
      return pending.future;
    };
    final result =
        expectLater(master.getStates(accessToken: 'old'), throwsStateError);
    await started.future;
    auth.clearSession();
    pending.complete(http.Response('{"access_token":"new"}', 200));
    await result;
    expect(auth.tokens, isNull);
    expect(requests, 1);
  });
}
