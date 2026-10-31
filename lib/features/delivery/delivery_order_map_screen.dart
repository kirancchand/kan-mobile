import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/location_map.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/map_location.dart';
import '../../state/cart_state.dart';
import '../../state/delivery_session.dart';

class DeliveryOrderMapScreen extends StatefulWidget {
  const DeliveryOrderMapScreen(
      {super.key,
      required this.orderId,
      required this.itemKey,
      this.locationService = const LocationService(),
      this.tileProvider});
  final String orderId;
  final String itemKey;
  final LocationService locationService;
  final TileProvider? tileProvider;
  @override
  State<DeliveryOrderMapScreen> createState() => _DeliveryOrderMapScreenState();
}

class _DeliveryOrderMapScreenState extends State<DeliveryOrderMapScreen> {
  LocationFix? _fix;
  LocationFailure? _failure;
  bool _busy = false;
  String? _courierId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _authorizedEntry() != null) _locate();
    });
  }

  ({PurchaseOrder order, CartLine line})? _authorizedEntry() {
    for (final order in context.read<CartState>().deliveryOrders) {
      if (order.id != widget.orderId) continue;
      for (final line in order.lines) {
        if (line.item.key == widget.itemKey) return (order: order, line: line);
      }
    }
    return null;
  }

  Future<void> _locate() async {
    if (_busy || _authorizedEntry() == null) return;
    final courierId = context.read<DeliverySession>().currentUser?.id;
    setState(() {
      _busy = true;
      _failure = null;
      _fix = null;
    });
    try {
      final fix = await widget.locationService.current();
      if (mounted &&
          context.read<DeliverySession>().currentUser?.id == courierId) {
        setState(() => _fix = fix);
      }
    } on LocationFailure catch (error) {
      if (mounted &&
          context.read<DeliverySession>().currentUser?.id == courierId) {
        setState(() => _failure = error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _directions(Uri uri) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {/* Show the same actionable failure if launch fails. */}
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Could not open directions. Try again with a maps app or browser available.')));
    }
  }

  Widget _distance(String label, MapLocation? from, MapLocation? to) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
            '$label: ${from != null && to != null ? '${from.distanceKmTo(to).toStringAsFixed(2)} km' : 'Unavailable'}'),
      );

  @override
  Widget build(BuildContext context) {
    context.watch<CartState>();
    final courierId = context.watch<DeliverySession>().currentUser?.id;
    if (_courierId != courierId) {
      _courierId = courierId;
      _fix = null;
      _failure = null;
    }
    final entry = _authorizedEntry();
    if (entry == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Order map')),
          body: const Center(
              child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                      'This order is not available for your delivery account.'))));
    }
    final pickup = entry.line.item.pickupPoint;
    final destination = entry.order.deliveryPoint;
    final current = _fix?.point;
    return Scaffold(
      appBar: AppBar(title: const Text('Order map')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(entry.line.item.title,
            style: Theme.of(context).textTheme.titleLarge),
        Text('${entry.order.id} • ${entry.line.status.label}'),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 8, children: [
          _legend('You', Colors.blue),
          _legend('Pickup', Colors.deepOrange),
          _legend('Delivery', Colors.purple),
        ]),
        const SizedBox(height: 12),
        LocationMap(tileProvider: widget.tileProvider, pins: [
          if (current != null)
            MapPin(current, 'Your current location', Colors.blue),
          if (pickup != null)
            MapPin(pickup, 'Pickup location', Colors.deepOrange),
          if (destination != null)
            MapPin(destination, 'Delivery location', Colors.purple),
        ]),
        Text(
            'Pickup: ${pickup?.label ?? 'No pickup pin saved. Contact the seller.'}'),
        Text(
            'Delivery: ${destination?.label ?? 'No delivery pin saved. Contact the buyer.'}'),
        const SizedBox(height: 12),
        OutlinedButton.icon(
            onPressed: _busy ? null : _locate,
            icon: const Icon(Icons.my_location),
            label: Text(
                _busy ? 'Getting current location…' : 'Refresh my location')),
        if (_failure != null) ...[
          Text(_failure!.message),
          if (_failure!.settingsRequired)
            TextButton(
                onPressed: () async {
                  final opened = await widget.locationService.openSettings();
                  if (!opened && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Open device or browser settings to enable location access, then refresh.')));
                  }
                },
                child: const Text('Open location permissions')),
        ],
        if (_fix != null)
          Text(
              'Location measured ${Formatters.dateTime(_fix!.measuredAt)} • accuracy ±${_fix!.accuracyMeters.round()} m'),
        const SizedBox(height: 16),
        Text('Straight-line distances',
            style: Theme.of(context).textTheme.titleMedium),
        const Text(
            'Estimates, not road distances. Use directions for the driving route.'),
        const SizedBox(height: 8),
        _distance('You → pickup', current, pickup),
        _distance('You → delivery', current, destination),
        _distance('Pickup → delivery', pickup, destination),
        if (current != null &&
            pickup != null &&
            destination != null &&
            entry.line.status == PurchaseStatus.readyForShipping)
          Text(
              'Via pickup total: ${(current.distanceKmTo(pickup) + pickup.distanceKmTo(destination)).toStringAsFixed(2)} km (straight-line legs)'),
        const SizedBox(height: 12),
        FilledButton.icon(
            icon: const Icon(Icons.directions),
            label: const Text('Directions to pickup'),
            onPressed: current != null && pickup != null
                ? () => _directions(
                    directionsUri(origin: current, destination: pickup))
                : null),
        const SizedBox(height: 8),
        FilledButton.icon(
            icon: const Icon(Icons.directions),
            label: const Text('Directions to delivery'),
            onPressed: current != null && destination != null
                ? () => _directions(
                    directionsUri(origin: current, destination: destination))
                : null),
        if (current != null &&
            pickup != null &&
            destination != null &&
            entry.line.status == PurchaseStatus.readyForShipping)
          TextButton(
              onPressed: () => _directions(directionsUri(
                  origin: current, destination: destination, via: pickup)),
              child: const Text('Directions via pickup')),
      ]),
    );
  }

  Widget _legend(String label, Color color) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.location_pin, color: color, size: 20),
        Text(label)
      ]);
}
