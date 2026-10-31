import '../../../core/widgets/media_gallery.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/contact_actions.dart';
import '../../../core/widgets/icon_badge.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/ride_listing.dart';
import '../../../data/models/vehicle_type.dart';
import 'ride_pool_theme.dart';

class RideDetailScreen extends StatelessWidget {
  const RideDetailScreen({super.key, required this.ride});
  final RideListing ride;
  @override
  Widget build(BuildContext context) => RidePoolTheme(
      child: Builder(
          builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Ride Pool')),
                bottomNavigationBar: RidePoolActionBar(
                    child: FilledButton.icon(
                  icon: const Icon(AppIcons.phoneCallBold),
                  label: const Text('Contact Driver'),
                  onPressed: () => showCallSheet(context,
                      name: ride.driverName, phone: ride.driverPhone),
                )),
                body: ListView(padding: const EdgeInsets.all(20), children: [
                  MediaGallery(attachments: ride.attachments),
                  RidePoolGlass(
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        IconBadge(
                            icon: ride.vehicleType.icon,
                            tone: AppTone.info,
                            size: 88),
                        const SizedBox(height: 20),
                        Text('${ride.from} → ${ride.to}',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        Text(Formatters.dateTime(ride.departureTime),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: context.tokens.textMuted)),
                        const SizedBox(height: 18),
                        Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              StatusChip(
                                  label: ride.vehicleType.label,
                                  tone: AppTone.info),
                              StatusChip(
                                  label: '${ride.seatsAvailable} seat(s) left',
                                  tone: ride.seatsAvailable > 0
                                      ? AppTone.brand
                                      : AppTone.attention),
                              StatusChip(
                                  label:
                                      '${Formatters.currency(ride.pricePerSeat)}/seat'),
                            ]),
                      ])),
                  const SizedBox(height: 16),
                  RidePoolGlass(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Vehicle',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(ride.vehicleInfo,
                                style: const TextStyle(height: 1.5)),
                          ])),
                  const SizedBox(height: 16),
                  RidePoolGlass(
                      child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const Icon(AppIcons.user),
                          title: Text(ride.driverName),
                          subtitle: const Text('Driver'))),
                ]),
              )));
}
