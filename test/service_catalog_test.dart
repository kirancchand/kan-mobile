import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mv_app/core/theme/app_icons.dart';
import 'package:mv_app/core/theme/app_tokens.dart';
import 'package:mv_app/core/widgets/icon_badge.dart';
import 'package:mv_app/data/models/service_definition.dart';
import 'package:mv_app/data/models/service_type.dart';
import 'package:mv_app/data/repositories/home_repository.dart';
import 'package:mv_app/features/home/widgets/services_grid.dart';
import 'package:mv_app/features/services/service_catalog_builder.dart';

const sample = <String, dynamic>{
  'service_id': 2,
  'service': 'Online Library',
  'shortform': 'library',
  'description': 'Rent, buy & sell books peer-to-peer',
  'icon': '        return AppIcons.bookOpen;\n',
  'color': '0xFF326B65',
};

class CatalogRepository extends HomeRepository {
  var calls = 0;
  @override
  Future<List<ServiceDefinition>> getServices() async {
    if (++calls == 1) throw StateError('Temporary failure');
    return [
      ServiceDefinition.fromJson(
          {...sample, 'service': 'Community help', 'shortform': 'help'})
    ];
  }
}

void main() {
  test('API metadata selects library by shortform and decodes icon/color', () {
    final service = ServiceDefinition.fromJson({...sample, 'service_id': 901});
    expect(service.id, 901);
    expect(service.label, 'Online Library');
    expect(service.description, sample['description']);
    expect(service.module, ServiceType.library);
    expect(service.icon, AppIcons.bookOpen);
    expect(service.color, const Color(0xFF326B65));
    final unknown = ServiceDefinition.fromJson({
      ...sample,
      'shortform': 'new-service',
      'icon': 'arbitrary code()',
      'color': 'invalid'
    });
    expect(unknown.module, isNull);
    expect(unknown.icon, AppIcons.gridFour);
    expect(unknown.color, const Color(0xFF326B65));
    expect(() => ServiceDefinition.fromJson({...sample, 'service_id': null}),
        throwsFormatException);
  });

  testWidgets(
      'Catalog retries and renders only server entries with their color',
      (tester) async {
    final repo = CatalogRepository();
    addTearDown(repo.dispose);
    await tester.pumpWidget(Provider<HomeRepository>.value(
        value: repo,
        child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.light]),
            home: Scaffold(
                body: ServiceCatalogBuilder(
                    builder: (context, services, refresh) =>
                        ServicesGrid(services: services))))));
    await tester.pumpAndSettle();
    expect(find.text('Could not load services'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Community help'), findsOneWidget);
    expect(find.text('Online Library'), findsNothing);
    expect(tester.widget<IconBadge>(find.byType(IconBadge)).color,
        const Color(0xFF326B65));
    await tester.tap(find.text('Community help'));
    await tester.pump();
    expect(
        find.text(
            'Community help is not available in this version of the app.'),
        findsOneWidget);
  });
}
