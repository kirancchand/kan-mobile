import 'package:mv_app/data/services/emergency_organisation_api.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/home_repository.dart';
import 'package:mv_app/data/repositories/location_repository.dart';
import 'package:mv_app/data/repositories/latest_entries_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/data/services/organisation_content_api.dart';
import 'package:mv_app/data/services/organisation_api.dart';
import 'package:mv_app/features/home/home_screen.dart';
import 'package:mv_app/state/app_state.dart';
import 'package:mv_app/core/theme/app_theme.dart';
import 'package:mv_app/data/repositories/marketplace_repository.dart';
import 'package:mv_app/data/repositories/book_repository.dart';
import 'package:mv_app/data/repositories/ride_repository.dart';
import 'package:mv_app/data/repositories/video_repository.dart';
import 'package:mv_app/data/repositories/delivery_repository.dart';

class _Auth extends AuthRepository {
  _Auth() : super(WhatsAppGroupRepository());
  @override
  Future<String> validAccessToken() async => 't';
}

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  testWidgets(
      'Home search replaces the spinner with common/searchProduct results',
      (tester) async {
    final groups = WhatsAppGroupRepository();
    final auth = _Auth();
    final home = HomeRepository(
        emergencyApi: EmergencyOrganisationApi(
            client: MockClient((_) async => http.Response('[]', 200))),
        organisationApi: OrganisationApi(
            authRepository: auth,
            client: MockClient((_) async =>
                http.Response('{"totalCount":0,"result":[]}', 200))),
        organisationContentApi: OrganisationContentApi(
            authRepository: auth,
            client: MockClient((r) async => http.Response(
                jsonEncode({
                  'totalCount': 1,
                  'result': [
                    {
                      'organisation': 'Darsana',
                      'organisation_type': 'School',
                      'product_name': 'sample'
                    }
                  ]
                }),
                200))));
    await tester.pumpWidget(MultiProvider(providers: [
      Provider<LocationRepository>(create: (_) => LocationRepository()),
      Provider<HomeRepository>.value(value: home),
      ChangeNotifierProvider<LatestEntriesRepository>(
          create: (_) => LatestEntriesRepository(
              marketplace: MarketplaceRepository(),
              books: BookRepository(),
              rides: RideRepository(),
              videos: VideoRepository(),
              deliveries: DeliveryRepository())),
      ChangeNotifierProvider<AppState>(
          create: (_) =>
              AppState(whatsAppGroupRepository: groups, authRepository: auth)),
    ], child: MaterialApp(theme: AppTheme.light, home: const HomeScreen())));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.enterText(find.byType(TextField).first, 'sa');
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(tester.takeException(), isNull);
    expect(find.text('sample'), findsOneWidget);
    expect(find.text('Darsana • School'), findsOneWidget);
    expect(find.text('Search is unavailable. Please try again.'), findsNothing);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    await tester.tap(find.byTooltip('Filter search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Product'), findsOneWidget);
    expect(find.text('Organisation type'), findsOneWidget);
    await tester
        .tap(find.widgetWithText(CheckedPopupMenuItem<String>, 'Organisation'));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(
        tester
            .widget<TextField>(find.byType(TextField).first)
            .decoration
            ?.hintText,
        'Search organisations');
    expect(find.text('sample'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(find.byTooltip('Filter search'), findsOneWidget);
    expect(find.byTooltip('Clear search'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
  });
}
