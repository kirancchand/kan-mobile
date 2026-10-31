import 'data/services/market_api.dart';
import 'data/services/service_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/admin_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/book_repository.dart';
import 'data/repositories/delivery_repository.dart';
import 'data/repositories/home_repository.dart';
import 'data/services/organisation_api.dart';
import 'data/services/organisation_content_api.dart';
import 'data/repositories/latest_entries_repository.dart';
import 'data/repositories/location_repository.dart';
import 'data/repositories/marketplace_repository.dart';
import 'data/repositories/ride_repository.dart';
import 'data/repositories/video_repository.dart';
import 'data/repositories/whatsapp_group_repository.dart';
import 'features/onboarding/auth_gate.dart';
import 'state/admin_state.dart';
import 'state/app_state.dart';
import 'state/cart_state.dart';
import 'state/delivery_session.dart';
import 'state/theme_state.dart';

void main() {
  runApp(const VillageApp());
}

class VillageApp extends StatelessWidget {
  const VillageApp({super.key});

  @override
  Widget build(BuildContext context) {
    final whatsAppGroupRepository = WhatsAppGroupRepository();

    return MultiProvider(
      providers: [
        // Repositories — API-backed data and user-created session records.
        Provider<LocationRepository>(create: (_) => LocationRepository()),
        Provider<WhatsAppGroupRepository>.value(value: whatsAppGroupRepository),
        Provider<AuthRepository>(
            create: (_) => AuthRepository(whatsAppGroupRepository),
            dispose: (_, repository) => repository.dispose()),
        Provider<HomeRepository>(
            create: (context) => HomeRepository(
                organisationContentApi: OrganisationContentApi(
                    authRepository: context.read<AuthRepository>()),
                serviceApi:
                    ServiceApi(authRepository: context.read<AuthRepository>()),
                organisationApi: OrganisationApi(
                    authRepository: context.read<AuthRepository>())),
            dispose: (_, repository) => repository.dispose()),
        Provider<MarketplaceRepository>(
            create: (_) => MarketplaceRepository(marketApi: MarketApi()),
            dispose: (_, repository) => repository.dispose()),
        Provider<BookRepository>(
            create: (_) => BookRepository(),
            dispose: (_, repository) => repository.dispose()),
        Provider<RideRepository>(
            create: (_) => RideRepository(),
            dispose: (_, repository) => repository.dispose()),
        Provider<VideoRepository>(
            create: (_) => VideoRepository(),
            dispose: (_, repository) => repository.dispose()),
        Provider<DeliveryRepository>(
            create: (_) => DeliveryRepository(),
            dispose: (_, repository) => repository.dispose()),
        Provider<AdminRepository>(
            create: (context) => AdminRepository(
                // The Admin tab is open to all users.
                assignedAccounts: const [AdminRepository.everyoneAccount],
                authRepository: context.read<AuthRepository>(),
                homeRepository: context.read<HomeRepository>())),
        ChangeNotifierProvider<LatestEntriesRepository>(
          create: (context) => LatestEntriesRepository(
            marketplace: context.read<MarketplaceRepository>(),
            books: context.read<BookRepository>(),
            rides: context.read<RideRepository>(),
            videos: context.read<VideoRepository>(),
            deliveries: context.read<DeliveryRepository>(),
          ),
        ),

        // App-wide state
        ChangeNotifierProvider<AppState>(
          create: (context) => AppState(
            whatsAppGroupRepository: whatsAppGroupRepository,
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider<DeliverySession>(
            create: (_) => DeliverySession()),
        ChangeNotifierProxyProvider<AppState, CartState>(
          create: (context) =>
              CartState(deliverySession: context.read<DeliverySession>()),
          update: (_, app, cart) => cart!
            ..setUser(app.currentUser?.id,
                name: app.currentUser?.name ?? 'Guest',
                phone: app.currentUser?.phone ?? ''),
        ),
        ChangeNotifierProvider<AdminState>(create: (_) => AdminState()),
        ChangeNotifierProvider<ThemeState>(create: (_) => ThemeState()),
      ],
      child: Consumer<ThemeState>(
        builder: (context, themeState, _) {
          return MaterialApp(
            title: 'Village Connect',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeState.mode,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
