import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mv_app/core/config/api_config.dart';
import 'package:mv_app/core/widgets/kan_registration_fields.dart';
import 'package:mv_app/data/models/kan_registration.dart';
import 'package:mv_app/data/models/gender_option.dart';
import 'package:mv_app/data/services/kan_master_api.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/data/services/kan_auth_api.dart';

const details = KanRegistration(
    username: 'sample',
    firstName: 'First',
    middleName: '',
    lastName: 'Last',
    email: 'sample@example.com',
    mobile: '9876543210',
    password: 'test-password',
    dateOfBirth: '21/01/2000',
    genderValue: 1,
    genderLabel: 'male',
    branchValue: 2,
    branchLabel: 'ward name');

void main() {
  test('Auth URL is centralized, supports base paths and rejects invalid URLs',
      () {
    expect(ApiConfig.registrationUri().toString(),
        'http://localhost:8084/auth/register');
    expect(ApiConfig.registrationUri('https://example.com/api/').toString(),
        'https://example.com/api/auth/register');
    expect(() => ApiConfig.registrationUri('localhost:8084'),
        throwsFormatException);
  });

  test(
      'API request follows Postman and successful registration retains profile after API login',
      () async {
    var calls = 0;
    final api = KanAuthApi(
        baseUrl: 'http://localhost:8084/',
        client: MockClient((request) async {
          if (request.url.path == '/auth/login') {
            return http.Response('{"access_token":"test"}', 200);
          }
          calls++;
          expect(request.method, 'POST');
          expect(request.url.toString(), 'http://localhost:8084/auth/register');
          expect(request.headers['Content-Type'], 'application/json');
          expect(request.headers.containsKey('Authorization'), isFalse);
          expect(jsonDecode(request.body), {
            'username': 'sample',
            'firstName': 'First',
            'middleName': '',
            'lastName': 'Last',
            'email': 'sample@example.com',
            'mobno': '9876543210',
            'password': 'test-password',
            'dateofbirth': '21/01/2000',
            'gender': {'value': 1, 'label': 'male'},
            'status': null,
            'usertype': null,
            'branch': {'value': 2, 'label': 'ward name'},
          });
          return http.Response('', 201);
        }));
    final auth = AuthRepository(WhatsAppGroupRepository(), api: api);
    addTearDown(auth.dispose);
    final user = await auth.register(
        name: details.fullName,
        phone: details.mobile,
        locationId: 'loc_1',
        registration: details);
    expect(user.apiRegistered, isTrue);
    expect(user.copyWith().apiRegistered, isTrue);
    expect(user.whatsAppGroupId, isNull);
    expect(await auth.login(details.mobile, password: 'test-password'),
        same(user));
    expect(await auth.login(details.username, password: 'test-password'),
        same(user));
    await expectLater(
        auth.register(
            name: details.fullName,
            phone: details.mobile,
            locationId: 'loc_1',
            registration: details),
        throwsStateError);
    expect(calls, 1);
  });

  for (final failure in ['400', '500', 'network', 'timeout']) {
    test('$failure does not create a local account or group', () async {
      var calls = 0;
      final api = KanAuthApi(
          timeout: const Duration(milliseconds: 1),
          client: MockClient((request) async {
            calls++;
            if (failure == 'network') throw http.ClientException('offline');
            if (failure == 'timeout') {
              await Future<void>.delayed(const Duration(milliseconds: 20));
              return http.Response('', 201);
            }
            return http.Response('', int.parse(failure));
          }));
      final auth = AuthRepository(WhatsAppGroupRepository(), api: api);
      addTearDown(auth.dispose);
      var notifications = 0;
      auth.changes.addListener(() => notifications++);
      await expectLater(
          auth.register(
              name: details.fullName,
              phone: details.mobile,
              locationId: 'loc_1',
              registration: details),
          throwsA(anything));
      expect(auth.registeredUsers, isEmpty);
      expect(notifications, 0);
      expect(calls, 1);
    });
  }

  test('Concurrent submission of the same phone makes only one request',
      () async {
    final response = Completer<http.Response>();
    var calls = 0;
    final auth = AuthRepository(WhatsAppGroupRepository(),
        api: KanAuthApi(client: MockClient((_) {
      calls++;
      return response.future;
    })));
    addTearDown(auth.dispose);
    final first = auth.register(
        name: details.fullName,
        phone: details.mobile,
        locationId: 'loc_1',
        registration: details);
    await expectLater(
        auth.register(
            name: details.fullName,
            phone: details.mobile,
            locationId: 'loc_1',
            registration: details),
        throwsStateError);
    response.complete(http.Response('', 200));
    await first;
    expect(calls, 1);
  });

  testWidgets(
      'Registration fields validate dates and submit the selected gender',
      (tester) async {
    final masterApi = KanMasterApi(
        client: MockClient((_) async => http.Response(
            '[{"value":"1","label":"Male"},{"value":"9","label":"Chosen gender"}]',
            200)));
    addTearDown(masterApi.dispose);
    final form = GlobalKey<FormState>();
    final fields = GlobalKey<KanRegistrationFieldsState>();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: Form(
                    key: form,
                    child: KanRegistrationFields(
                        key: fields, masterApi: masterApi))))));
    await tester.pumpAndSettle();
    expect(form.currentState!.validate(), isFalse);
    for (final entry in {
      'firstName': 'First',
      'lastName': 'Last',
      'mobno': '9876543210',
      'email': 'test@example.com',
      'password': 'test-password',
      'dateofbirth': '31/02/2000',
      'branchValue': '8',
      'branchLabel': 'Chosen branch',
    }.entries) {
      await tester.enterText(
          find.byKey(ValueKey('register-${entry.key}')), entry.value);
    }
    expect(form.currentState!.validate(), isFalse);
    await tester.enterText(
        find.byKey(const ValueKey('register-dateofbirth')), '29/02/2000');
    expect(form.currentState!.validate(), isTrue);
    final dropdown = find.byType(DropdownButtonFormField<GenderOption>);
    await tester.ensureVisible(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chosen gender').last);
    await tester.pumpAndSettle();
    final data = fields.currentState!.registration;
    expect(data.username, '9876543210');
    expect(data.branchValue, 8);
    expect(data.genderLabel, 'Chosen gender');
    expect(data.toJson()['gender'], {'value': 9, 'label': 'Chosen gender'});
    expect(data.toJson()['usertype'], isNull);
  });
}
