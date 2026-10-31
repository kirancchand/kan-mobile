import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mv_app/core/theme/app_tokens.dart';
import 'package:mv_app/data/models/organisation_draft.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/home_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/data/services/organisation_api.dart';
import 'package:mv_app/data/services/kan_auth_api.dart';
import 'package:mv_app/features/home/add_organisation_screen.dart';
import 'package:mv_app/state/app_state.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Form loads master options, validates and saves through the API',
      (tester) async {
    final groups = WhatsAppGroupRepository();
    final auth = AuthRepository(groups,
        api: KanAuthApi(
            client: MockClient((_) async => http.Response(
                '{"access_token":"test","userInfo":{"message":"Listed Successfully!!","status":200,"data":{"user_id":42,"mobno":"09876543210","email_id":"owner@example.com"}}}',
                200))));
    final app = AppState(whatsAppGroupRepository: groups, authRepository: auth);
    addTearDown(auth.dispose);
    addTearDown(app.dispose);
    await app.login('owner', password: 'test');
    Map<String, dynamic>? submitted;
    var saves = 0;
    final repository = HomeRepository(
        organisationApi: OrganisationApi(client: MockClient((request) async {
      final path = request.url.path;
      Object response;
      if (path.endsWith('listOrganisationType')) {
        response = {
          'totalCount': 1,
          'result': [
            {'organisation_type_id': 8, 'organisation_type': 'Pharmacy'}
          ]
        };
      } else if (path.endsWith('listBranch')) {
        response = {
          'totalCount': 1,
          'result': [
            {'branch_id': 4, 'branch': 'Village branch'}
          ]
        };
      } else if (path == '/keyValue') {
        expect(jsonDecode(request.body), {'requestName': 'getAll_Status'});
        response = [
          {'value': 1, 'label': 'Active'}
        ];
      } else if (path.endsWith('/add')) {
        expect(request.method, 'POST');
        expect(request.url.toString(),
            'http://localhost:8070/master/organisation/add');
        expect(request.headers['content-type'], 'application/json');
        saves++;
        submitted = jsonDecode(request.body) as Map<String, dynamic>;
        if (saves == 1) return http.Response('', 503);
        response = {'message': 'Created'};
      } else {
        response = {
          'totalCount': 1,
          'result': [
            {
              'organisation_id': 12,
              'organisation': 'Community Trust',
              'organisation_address': 'Village Road',
              'organisation_contact': '09876543210',
              'organisation_email': 'owner@example.com',
              'organisation_type': {'value': 8, 'label': 'Pharmacy'},
            }
          ]
        };
      }
      return http.Response(jsonEncode(response), 200);
    })));
    addTearDown(repository.dispose);
    await tester.pumpWidget(MultiProvider(
        providers: [
          Provider.value(value: repository),
          Provider.value(value: auth),
          ChangeNotifierProvider.value(value: app),
        ],
        child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.light]),
            home: Builder(
                builder: (context) => Scaffold(
                      body: TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const AddOrganisationScreen())),
                          child: const Text('Open form')),
                    )))));
    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
    final submit = find.widgetWithText(FilledButton, 'Add Organisation');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(saves, 0);
    expect(find.text('Select Organisation type'), findsWidgets);
    // Ownership comes from the login session without an editable field.
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), ' Community Trust ');
    await tester.enterText(
        find.byKey(const ValueKey('organisation-address')), ' Village Road ');
    expect(find.byKey(const ValueKey('organisation-owner-id')), findsNothing);
    expect(find.text('Owner user ID'), findsNothing);
    final selectors = find.byType(DropdownButtonFormField<OrganisationOption>);
    for (final entry in [
      (0, 'Pharmacy'),
      (1, 'Village branch'),
      (2, 'Active')
    ]) {
      await tester.ensureVisible(selectors.at(entry.$1));
      await tester.pumpAndSettle();
      await tester.tap(selectors.at(entry.$1));
      await tester.pumpAndSettle();
      await tester.tap(find.text(entry.$2).last);
      await tester.pumpAndSettle();
    }
    auth.clearSession();
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(saves, 0);
    expect(find.text('Please sign in again to add your organisation.'),
        findsOneWidget);
    await app.login('owner', password: 'test');
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.byType(AddOrganisationScreen), findsOneWidget);
    expect(repository.shops, isEmpty);
    expect(find.text(' Community Trust '), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(saves, 2);
    expect(submitted, {
      'organisation': 'Community Trust',
      'organisation_address': 'Village Road',
      'organisation_contact': '09876543210',
      'organisation_email': 'owner@example.com',
      'organisation_type': {'value': '8', 'label': 'Pharmacy'},
      'branch': {'value': '4', 'label': 'Village branch'},
      'status': {'value': '1', 'label': 'Active'},
      'ownerId': 42,
      'latitude': null,
      'longitude': null,
    });
    expect(find.byType(AddOrganisationScreen), findsNothing);
    expect(repository.shops.single.id, '12');
  });

  test(
      'Successful create with failed refresh does not create a dummy row or resubmit',
      () async {
    var saves = 0;
    final repository = HomeRepository(
        organisationApi: OrganisationApi(client: MockClient((request) async {
      if (request.url.path.endsWith('/add')) {
        saves++;
        return http.Response('', 201);
      }
      return http.Response('', 503);
    })));
    addTearDown(repository.dispose);
    const option = OrganisationOption(value: '1', label: 'Option');
    expect(
        await repository.createOrganisation(const OrganisationDraft(
            name: 'Test',
            address: 'Village Road',
            type: option,
            branch: option,
            status: option,
            ownerId: 42)),
        isFalse);
    expect(saves, 1);
    expect(repository.shops, isEmpty);
  });

  testWidgets('Guests cannot submit an organisation', (tester) async {
    final groups = WhatsAppGroupRepository();
    final auth = AuthRepository(groups);
    final app = AppState(whatsAppGroupRepository: groups, authRepository: auth);
    addTearDown(auth.dispose);
    addTearDown(app.dispose);
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: app, child: const MaterialApp(home: AddOrganisationScreen())));
    expect(find.text('Sign in to add your organisation.'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });
}
