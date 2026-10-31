import 'fixtures/mock_rides.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mv_app/core/theme/app_theme.dart';
import 'package:mv_app/data/models/vehicle_type.dart';
import 'package:mv_app/data/repositories/ride_repository.dart';
import 'package:mv_app/features/services/ride_pool/ride_list_screen.dart';
import 'package:provider/provider.dart';

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  test('Unified pool retains vehicle type when posting and filtering',
      () async {
    final repository = RideRepository(initialItems: mockRides);
    final ride = await repository.postRide(
      vehicleType: VehicleType.bike,
      driverName: 'Test Driver',
      driverPhone: '9876543210',
      from: 'Village',
      to: 'Town',
      departureTime: DateTime.now().add(const Duration(hours: 1)),
      seatsAvailable: 1,
      pricePerSeat: 20,
      vehicleInfo: 'Test bike',
    );
    expect(await repository.getRides(), contains(ride));
    expect(await repository.getRides(vehicleType: VehicleType.bike),
        contains(ride));
    expect(await repository.getRides(vehicleType: VehicleType.car),
        isNot(contains(ride)));
  });

  testWidgets('Vehicle filter switches between all, car and bike rides',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(Provider(
      create: (_) => RideRepository(initialItems: mockRides),
      child: MaterialApp(theme: AppTheme.light, home: const RideListScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Ride Pool'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsWidgets);
    expect(find.textContaining('Car •'), findsWidgets);
    expect(find.textContaining('Bike •'), findsWidgets);
    await tester.tap(find.text('Bike'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Car •'), findsNothing);
    expect(find.textContaining('Bike •'), findsWidgets);
    await tester.tap(find.text('Car'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Bike •'), findsNothing);
    expect(find.textContaining('Car •'), findsWidgets);
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Bike •'), findsWidgets);
  });

  for (final dark in [false, true]) {
    testWidgets('Route search works at mobile width, dark=$dark',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(Provider(
        create: (_) => RideRepository(initialItems: mockRides),
        child: MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            home: const RideListScreen()),
      ));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Rampura');
      await tester.tap(find.text('Search rides'));
      await tester.pumpAndSettle();
      expect(find.text('Rampura'), findsWidgets);
      expect(find.text('Vijayawada'), findsNothing);
      await tester.enterText(find.byType(TextField).first, 'No such village');
      await tester.tap(find.text('Search rides'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -350));
      await tester.pumpAndSettle();
      expect(find.text('No matching rides'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
