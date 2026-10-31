import 'package:flutter_test/flutter_test.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/data/services/kan_auth_api.dart';
import 'package:mv_app/data/models/shop_org.dart';
import 'package:mv_app/data/models/organisation_draft.dart';
import 'package:mv_app/data/services/organisation_api.dart';

void main() {
  test('Only membership f_usertype_id 5 or 6 permits editing', () {
    for (final value in [null, 1, 5, 6, 7, '5', '6', 'invalid']) {
      final org = ShopOrg.fromJson({
        'organisation_id': 12,
        'organisation': 'Organisation',
        'f_user_id': 624,
        'f_usertype_id': value,
      });
      expect(org.canEditOrganisation, [5, 6, '5', '6'].contains(value));
    }
  });

  test('User IDs 5 and 6 do not grant edit permission', () {
    for (final userId in [5, 6]) {
      final org = ShopOrg.fromJson({
        'organisation_id': 12,
        'organisation': 'Organisation',
        'f_user_id': userId,
        'f_usertype_id': 3,
      });
      expect(org.canEditOrganisation, isFalse);
    }
  });

  test('Membership fields without labels retain edit-form option IDs', () {
    final org = ShopOrg.fromJson({
      'organisation_member_id': 51,
      'f_organisation_id': 2,
      'f_user_id': 624,
      'f_status_id': 1,
      'f_usertype_id': 11,
      'usertype': 'Owner',
      'organisation_id': 2,
      'organisation': 'Palode Police Station',
      'organisation_address': 'Police Station Palode',
      'f_organisation_type_id': 4,
      'f_branch_id': 2986,
      'latitude': null,
      'longitude': null,
      'f_owner_id': 624,
    });
    expect(org.id, '2');
    expect(org.typeOption!.value, '4');
    expect(org.branchOption!.value, '2986');
    expect(org.statusOption!.value, '1');
    expect(org.ownerId, '624');
    expect(org.canEditOrganisation, isFalse);
  });

  const simulation = String.fromEnvironment('organisation_simulation_url');
  test('Membership listing and permitted updates over real HTTP', () async {
    final auth = AuthRepository(WhatsAppGroupRepository(),
        api: KanAuthApi(baseUrl: simulation));
    addTearDown(auth.dispose);
    await auth.login('simulation-user', password: 'simulation-only');
    expect(auth.tokens!.userId, 624);
    final api = OrganisationApi(baseUrl: simulation, authRepository: auth);
    addTearDown(api.dispose);
    final organisations = await api.fetchByUserId(auth.tokens!.userId!);
    expect(organisations.map((org) => org.id), ['5', '6', '7']);
    const option = OrganisationOption(value: '1', label: 'School');
    const draft = OrganisationDraft(
      name: 'Updated organisation',
      address: 'Village',
      type: option,
      branch: option,
      status: option,
      ownerId: 624,
    );
    await expectLater(api.update(organisations.last, draft), throwsStateError);
    await api.update(organisations.first, draft);
    expect((await api.fetchByUserId(auth.tokens!.userId!)).first.name,
        'Updated organisation');
  },
      skip: simulation.isEmpty
          ? 'Run with the local Postman simulation URL.'
          : false);
}
