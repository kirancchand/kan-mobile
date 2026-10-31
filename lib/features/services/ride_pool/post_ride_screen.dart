import '../../../core/widgets/media_attachments.dart';
import '../../../data/models/media_attachment.dart';
import 'ride_pool_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/vehicle_type.dart';
import '../../../data/repositories/ride_repository.dart';
import '../../../state/app_state.dart';
import '../../../core/theme/app_icons.dart';

class PostRideScreen extends StatefulWidget {
  final VehicleType? initialVehicleType;

  const PostRideScreen({super.key, this.initialVehicleType});

  @override
  State<PostRideScreen> createState() => _PostRideScreenState();
}

class _PostRideScreenState extends State<PostRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _seatsController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  final _vehicleController = TextEditingController();
  DateTime _departureTime = DateTime.now().add(const Duration(hours: 2));
  bool _isSubmitting = false;
  bool _isPickingMedia = false;
  List<MediaAttachment> _attachments = [];
  late VehicleType _vehicleType;

  @override
  void initState() {
    super.initState();
    _vehicleType = widget.initialVehicleType ?? VehicleType.car;
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _seatsController.dispose();
    _priceController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(BuildContext themedContext) async {
    final date = await showDatePicker(
      context: themedContext,
      initialDate: _departureTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null || !mounted || !themedContext.mounted) return;
    final time = await showTimePicker(
        context: themedContext,
        initialTime: TimeOfDay.fromDateTime(_departureTime));
    if (time == null || !mounted) return;
    setState(() {
      _departureTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting ||
        _isPickingMedia ||
        !_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSubmitting = true);
    final user = context.read<AppState>().currentUser;
    try {
      await context.read<RideRepository>().postRide(
            attachments: _attachments,
            vehicleType: _vehicleType,
            driverName: user?.name ?? 'You',
            driverPhone: user?.phone ?? '',
            from: _fromController.text.trim(),
            to: _toController.text.trim(),
            departureTime: _departureTime,
            seatsAvailable: int.tryParse(_seatsController.text.trim()) ?? 1,
            pricePerSeat: double.tryParse(_priceController.text.trim()) ?? 0,
            vehicleInfo: _vehicleController.text.trim(),
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RidePoolTheme(child: Builder(builder: (context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Offer a Ride')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: RidePoolGlass(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<VehicleType>(
                      initialValue: _vehicleType,
                      decoration:
                          const InputDecoration(labelText: 'Vehicle type'),
                      items: VehicleType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.label),
                              ))
                          .toList(),
                      onChanged: (type) {
                        if (type != null) setState(() => _vehicleType = type);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _fromController,
                      decoration: const InputDecoration(labelText: 'From'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter starting point'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _toController,
                      decoration: const InputDecoration(labelText: 'To'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter destination'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Departure',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.sm),
                    InkWell(
                      onTap: () => _pickDateTime(context),
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      child: InputDecorator(
                        decoration: const InputDecoration(),
                        child: Row(
                          children: [
                            const Icon(AppIcons.clock),
                            const SizedBox(width: AppSpacing.ms),
                            Expanded(
                                child:
                                    Text(Formatters.dateTime(_departureTime))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _seatsController,
                            decoration: const InputDecoration(
                                labelText: 'Seats Available'),
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                (v == null || int.tryParse(v.trim()) == null)
                                    ? 'Enter a number'
                                    : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.ms),
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                                labelText: 'Price/seat (₹)', prefixText: '₹ '),
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                (v == null || double.tryParse(v.trim()) == null)
                                    ? 'Enter a valid amount'
                                    : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _vehicleController,
                      decoration: InputDecoration(
                          labelText: _vehicleType == VehicleType.car
                              ? 'Car (make, color, number)'
                              : 'Bike (make, number)'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter vehicle details'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    MediaAttachmentField(
                      attachments: _attachments,
                      enabled: !_isSubmitting,
                      onChanged: (value) =>
                          setState(() => _attachments = value),
                      onBusyChanged: (value) =>
                          setState(() => _isPickingMedia = value),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                        label: 'Post Ride',
                        onPressed: _isPickingMedia ? null : _submit,
                        isLoading: _isSubmitting),
                  ],
                ),
              )),
        ),
      );
    }));
  }
}
