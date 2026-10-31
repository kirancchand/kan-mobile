import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mv_app/core/theme/app_icons.dart';
import 'package:mv_app/data/repositories/home_repository.dart';
import 'package:mv_app/data/services/emergency_organisation_api.dart';

void main() {
  HomeRepository repository(http.Response response) {
    final repo = HomeRepository(
      emergencyApi:
          EmergencyOrganisationApi(client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(),
            'http://localhost:5001/api/organisations/getEmergencyOrganisation');
        expect(request.headers['X-App-Id'], '1');
        return response;
      })),
    );
    addTearDown(repo.dispose);
    return repo;
  }

  test('API contacts replace dummy contacts and retain contact numbers',
      () async {
    final repo = repository(http.Response(
        jsonEncode([
          {
            'villageorganisation_id': 2,
            'organisation_name': 'Palode Police Station',
            'contact': '0472-123456',
            'organisation_type': 'Police Station',
            'icon': 'emojione-v1:police-car'
          },
          {
            'villageorganisation_id': 1,
            'organisation_name': 'Darsana',
            'contact': '099999999',
            'organisation_type': 'School',
            'icon': 'noto:school'
          },
        ]),
        200));
    final contacts = await repo.getEmergencyContacts();
    expect(contacts.map((c) => c.id), ['2', '1']);
    expect(contacts.first.name, 'Palode Police Station');
    expect(contacts.first.phone, '0472-123456');
    expect(contacts.first.icon, AppIcons.shieldCheck);
    expect(contacts.last.phone, '099999999');
    expect(contacts.last.icon, AppIcons.buildings);
  });

  test('Empty API response does not bring back dummy contacts', () async {
    expect(await repository(http.Response('[]', 200)).getEmergencyContacts(),
        isEmpty);
  });

  test('Failed requests never return sample phone numbers', () async {
    await expectLater(repository(http.Response('', 503)).getEmergencyContacts(),
        throwsA(isA<http.ClientException>()));
  });

  test('Malformed API response never returns sample contacts', () async {
    await expectLater(
        repository(http.Response('{}', 200)).getEmergencyContacts(),
        throwsFormatException);
  });
}
