import 'package:flutter_test/flutter_test.dart';
import 'package:mv_app/data/models/service_type.dart';
import 'package:http/http.dart' as http;
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/data/services/kan_auth_api.dart';
import 'package:mv_app/data/services/service_api.dart';

void main() {
  const simulation = String.fromEnvironment('service_simulation_url');
  test(
      'GET services uses kan URL, bearer refresh, envelopes and server errors over HTTP',
      () async {
    final auth = AuthRepository(WhatsAppGroupRepository(),
        api: KanAuthApi(baseUrl: simulation));
    addTearDown(auth.dispose);
    await auth.login('test', password: 'test');
    final api = ServiceApi(baseUrl: simulation, authRepository: auth);
    addTearDown(api.dispose);
    final services = await api.fetchAll();
    expect(auth.tokens!.accessToken, 'valid-test');
    expect(services.single.label, 'Online Library');
    expect(services.single.module, ServiceType.library);
    for (final prefix in ['bare', 'empty', 'failure']) {
      final variant =
          ServiceApi(baseUrl: '$simulation/$prefix', authRepository: auth);
      addTearDown(variant.dispose);
      if (prefix == 'failure') {
        await expectLater(
            variant.fetchAll(), throwsA(isA<http.ClientException>()));
      } else {
        expect((await variant.fetchAll()).length, prefix == 'empty' ? 0 : 1);
      }
    }
  },
      skip: simulation.isEmpty
          ? 'Run with the local Postman service simulation URL.'
          : false);
}
