import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mv_app/data/models/admin_hierarchy.dart';
import 'package:mv_app/data/models/app_user.dart';
import 'package:mv_app/data/repositories/admin_repository.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/data/services/kan_auth_api.dart';
import 'kan_registration_test.dart' show details;

void main() {
  for (final success in [true, false]) {
    test('Branch registration only adds a record after API success: $success',
        () async {
      final auth = AuthRepository(WhatsAppGroupRepository(),
          api: KanAuthApi(
              client: MockClient(
                  (_) async => http.Response('', success ? 201 : 503))));
      addTearDown(auth.dispose);
      final repo =
          AdminRepository(authRepository: auth, assignedAccounts: const [
        AdminAccount(
            id: 'branch',
            name: 'Branch',
            level: AdminLevel.branch,
            territory: 'Ward',
            locationId: '2'),
      ]);
      final future = repo.addUser(
          viewerId: 'branch',
          name: details.fullName,
          phone: details.mobile,
          userType: UserType.resident,
          registration: details);
      if (success) {
        final user = await future;
        expect(user.apiRegistered, isTrue);
        expect(user.whatsAppGroupId, isNull);
        expect(repo.getUsers(viewerId: 'branch', targetId: 'branch').single.id,
            user.id);
      } else {
        await expectLater(future, throwsStateError);
        expect(repo.getUsers(viewerId: 'branch', targetId: 'branch'), isEmpty);
      }
    });
  }
}
