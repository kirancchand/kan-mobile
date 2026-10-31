import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import '../../data/models/map_location.dart';
import '../services/location_service.dart';
import 'location_map.dart';

class MapLocationField extends StatelessWidget {
  const MapLocationField(
      {super.key,
      required this.label,
      required this.value,
      required this.onChanged,
      this.enabled = true});
  final String label;
  final MapLocation? value;
  final ValueChanged<MapLocation?> onChanged;
  final bool enabled;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (value != null) Text('$label: ${value!.label}'),
        OutlinedButton.icon(
            icon: const Icon(Icons.map_outlined),
            label: Text(value == null ? 'Set $label' : 'Change $label'),
            onPressed: !enabled
                ? null
                : () async {
                    final point = await Navigator.of(context).push<MapLocation>(
                        MaterialPageRoute(
                            builder: (_) => MapLocationPicker(
                                title: label, initial: value)));
                    if (context.mounted && point != null) onChanged(point);
                  }),
        if (value != null)
          TextButton(
              onPressed: enabled ? () => onChanged(null) : null,
              child: Text('Remove $label')),
      ]);
}

class MapLocationPicker extends StatefulWidget {
  const MapLocationPicker(
      {super.key,
      required this.title,
      this.initial,
      this.tileProvider,
      this.locationService = const LocationService()});
  final String title;
  final MapLocation? initial;
  final TileProvider? tileProvider;
  final LocationService locationService;
  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  final _form = GlobalKey<FormState>();
  late final _latitude =
      TextEditingController(text: widget.initial?.latitude.toString() ?? '');
  late final _longitude =
      TextEditingController(text: widget.initial?.longitude.toString() ?? '');
  late final _address =
      TextEditingController(text: widget.initial?.address ?? '');
  late MapLocation? _point = widget.initial;
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _latitude.dispose();
    _longitude.dispose();
    _address.dispose();
    super.dispose();
  }

  void _select(MapLocation point) => setState(() {
        _point = point;
        _latitude.text = point.latitude.toString();
        _longitude.text = point.longitude.toString();
        _error = null;
      });
  Future<void> _locate() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final fix = await widget.locationService.current();
      if (mounted) _select(fix.point);
    } on LocationFailure catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _validate(String? value, double limit) {
    final number = double.tryParse(value?.trim() ?? '');
    return number == null || !number.isFinite || number.abs() > limit
        ? 'Enter a value between -$limit and $limit'
        : null;
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(
        context,
        MapLocation(
            latitude: double.parse(_latitude.text.trim()),
            longitude: double.parse(_longitude.text.trim()),
            address: _address.text));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          const Text(
              'Tap the map to set the exact point, use your current location, or enter coordinates. Add an address or landmark for the delivery user.'),
          const SizedBox(height: 12),
          LocationMap(
              tileProvider: widget.tileProvider,
              pins: [
                if (_point != null)
                  MapPin(_point!, widget.title, Colors.deepOrange)
              ],
              onTap: _select),
          OutlinedButton.icon(
              onPressed: _busy ? null : _locate,
              icon: const Icon(Icons.my_location),
              label: Text(_busy ? 'Locating…' : 'Use my current location')),
          if (_error != null) Text(_error!),
          Form(
              key: _form,
              child: Column(children: [
                TextFormField(
                    controller: _address,
                    decoration: const InputDecoration(
                        labelText: 'Address / landmark (optional)')),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _latitude,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    validator: (v) => _validate(v, 90)),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _longitude,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    validator: (v) => _validate(v, 180)),
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: _busy ? null : _save,
                    child: const Text('Save location')),
              ])),
        ]),
      );
}
