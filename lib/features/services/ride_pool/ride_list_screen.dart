import '../../../core/widgets/media_gallery.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/shimmer_list_placeholder.dart';
import '../../../data/models/ride_listing.dart';
import '../../../data/models/vehicle_type.dart';
import '../../../data/repositories/ride_repository.dart';
import 'post_ride_screen.dart';
import 'ride_detail_screen.dart';
import 'ride_pool_theme.dart';

class RideListScreen extends StatefulWidget {
  const RideListScreen({super.key});
  @override
  State<RideListScreen> createState() => _RideListScreenState();
}

class _RideListScreenState extends State<RideListScreen> {
  late Future<List<RideListing>> _future;
  VehicleType? _vehicleType;
  final _from = TextEditingController();
  final _to = TextEditingController();
  String _fromQuery = '', _toQuery = '';
  bool _cheapest = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  void _reload() {
    _future =
        context.read<RideRepository>().getRides(vehicleType: _vehicleType);
  }

  Future<void> _offer() async {
    final created = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => PostRideScreen(initialVehicleType: _vehicleType)));
    if (created == true && mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) =>
      RidePoolTheme(child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text('Ride Pool')),
          bottomNavigationBar: RidePoolActionBar(
              child: FilledButton.icon(
            onPressed: _offer,
            icon: const Icon(AppIcons.plusBold),
            label: const Text('Offer a Ride'),
          )),
          body: CustomScrollView(slivers: [
            SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    child: RidePoolGlass(
                      prominent: true,
                      borderRadius: 28,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text('Go together.\nGo further.',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(height: 8),
                                    Text(
                                        'Car & bike rides with your neighbours',
                                        style: TextStyle(
                                            color: Color(0xFFE5E9FF),
                                            fontSize: 12)),
                                  ])),
                              if (MediaQuery.textScalerOf(context).scale(14) <
                                  20)
                                Transform.rotate(
                                    angle: -0.15,
                                    child: const Icon(AppIcons.car,
                                        size: 80, color: Color(0xFFCAD6FF))),
                            ]),
                            const SizedBox(height: 20),
                            TextField(
                                controller: _from,
                                decoration: const InputDecoration(
                                    labelText: 'From',
                                    prefixIcon: Icon(AppIcons.mapPin))),
                            const SizedBox(height: 10),
                            TextField(
                                controller: _to,
                                decoration: const InputDecoration(
                                    labelText: 'To',
                                    prefixIcon: Icon(AppIcons.mapPin))),
                            const SizedBox(height: 12),
                            SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                    onPressed: () => setState(() {
                                          _fromQuery =
                                              _from.text.trim().toLowerCase();
                                          _toQuery =
                                              _to.text.trim().toLowerCase();
                                        }),
                                    icon: const Icon(AppIcons.magnifyingGlass),
                                    label: const Text('Search rides'))),
                          ]),
                    ))),
            SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: RidePoolGlass(
                        padding: const EdgeInsets.all(12),
                        child: Column(children: [
                          SizedBox(
                              width: double.infinity,
                              child: SegmentedButton<VehicleType?>(
                                segments: const [
                                  ButtonSegment(
                                      value: null, label: Text('All')),
                                  ButtonSegment(
                                      value: VehicleType.car,
                                      label: Text('Car'),
                                      icon: Icon(AppIcons.car)),
                                  ButtonSegment(
                                      value: VehicleType.bike,
                                      label: Text('Bike'),
                                      icon: Icon(AppIcons.moped))
                                ],
                                selected: {_vehicleType},
                                onSelectionChanged: (selection) => setState(() {
                                  _vehicleType = selection.single;
                                  _reload();
                                }),
                              )),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Expanded(
                                child: Text('Available rides',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700))),
                            DropdownButton<bool>(
                                value: _cheapest,
                                underline: const SizedBox.shrink(),
                                items: const [
                                  DropdownMenuItem(
                                      value: false, child: Text('Earliest')),
                                  DropdownMenuItem(
                                      value: true, child: Text('Cheapest'))
                                ],
                                onChanged: (value) =>
                                    setState(() => _cheapest = value ?? false)),
                          ]),
                        ])))),
            FutureBuilder<List<RideListing>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                        child: ErrorState(onRetry: () => setState(_reload)));
                  }
                  if (!snapshot.hasData) {
                    return const SliverFillRemaining(
                        child: ShimmerListPlaceholder());
                  }
                  final rides = snapshot.data!
                      .where((ride) =>
                          ride.from.toLowerCase().contains(_fromQuery) &&
                          ride.to.toLowerCase().contains(_toQuery))
                      .toList();
                  if (_cheapest) {
                    rides.sort(
                        (a, b) => a.pricePerSeat.compareTo(b.pricePerSeat));
                  }
                  if (rides.isEmpty) {
                    return SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                            icon: AppIcons.car,
                            title: 'No matching rides',
                            message:
                                'Try another route or vehicle type, or offer a ride.',
                            actionLabel: 'Offer a Ride',
                            onAction: _offer));
                  }
                  return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      sliver: SliverList.builder(
                          itemCount: rides.length,
                          itemBuilder: (context, index) {
                            final ride = rides[index];
                            return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: RidePoolGlass(
                                    borderRadius: 20,
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => RideDetailScreen(
                                                  ride: ride))),
                                      child: Padding(
                                          padding: const EdgeInsets.all(18),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (ride.attachments.isNotEmpty)
                                                  MediaCover(
                                                      attachments:
                                                          ride.attachments,
                                                      height: 140,
                                                      child: const SizedBox
                                                          .shrink()),
                                                Row(children: [
                                                  Icon(ride.vehicleType.icon,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                      child: Text(
                                                          '${ride.vehicleType.label} • ${ride.seatsAvailable} seat(s) left',
                                                          style: TextStyle(
                                                              color: context
                                                                  .tokens
                                                                  .textMuted,
                                                              fontSize: 12))),
                                                  Text(
                                                      Formatters.currency(
                                                          ride.pricePerSeat),
                                                      style: const TextStyle(
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.w700)),
                                                ]),
                                                const SizedBox(height: 18),
                                                Row(children: [
                                                  Expanded(
                                                      child: Text(ride.from,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600))),
                                                  const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 12),
                                                      child: Icon(
                                                          AppIcons.caretRight,
                                                          size: 18)),
                                                  Expanded(
                                                      child: Text(ride.to,
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600))),
                                                ]),
                                                const SizedBox(height: 12),
                                                Text(
                                                    Formatters.dateTime(
                                                        ride.departureTime),
                                                    style: TextStyle(
                                                        color: context
                                                            .tokens.textMuted,
                                                        fontSize: 12)),
                                                const Divider(height: 24),
                                                Row(children: [
                                                  const Icon(AppIcons.user,
                                                      size: 18),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                      child: Text(
                                                          ride.driverName)),
                                                  Text('per seat',
                                                      style: TextStyle(
                                                          color: context
                                                              .tokens.textMuted,
                                                          fontSize: 12))
                                                ]),
                                              ])),
                                    )));
                          }));
                }),
          ]),
        );
      }));
}
