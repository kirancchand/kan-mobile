import '../../../core/widgets/media_attachments.dart';
import '../../../data/models/media_attachment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/repositories/delivery_repository.dart';
import '../../../state/app_state.dart';
import '../../../core/theme/app_icons.dart';

class RequestDeliveryScreen extends StatefulWidget {
  const RequestDeliveryScreen({super.key});

  @override
  State<RequestDeliveryScreen> createState() => _RequestDeliveryScreenState();
}

class _RequestDeliveryScreenState extends State<RequestDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  bool _isSubmitting = false;
  bool _isPickingMedia = false;
  List<MediaAttachment> _attachments = [];

  static const double _fee = 25;

  @override
  void dispose() {
    _itemController.dispose();
    _pickupController.dispose();
    _dropController.dispose();
    super.dispose();
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
      await context.read<DeliveryRepository>().requestDelivery(
            attachments: _attachments,
            itemDescription: _itemController.text.trim(),
            pickupAddress: _pickupController.text.trim(),
            dropAddress: _dropController.text.trim(),
            requestedBy: user?.name ?? 'You',
            fee: _fee,
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Delivery')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _itemController,
                decoration: const InputDecoration(
                    labelText: 'What needs to be delivered?'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Describe the item'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _pickupController,
                decoration: const InputDecoration(labelText: 'Pickup Address'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter pickup address'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _dropController,
                decoration: const InputDecoration(labelText: 'Drop Address'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter drop address'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.tokens.soft(AppTone.accent),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(AppIcons.info,
                        color: context.tokens.ink(AppTone.accent)),
                    const SizedBox(width: AppSpacing.ms),
                    const Expanded(
                        child:
                            Text('Flat delivery fee: ₹25 (cash on delivery)')),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              MediaAttachmentField(
                attachments: _attachments,
                enabled: !_isSubmitting,
                onChanged: (value) => setState(() => _attachments = value),
                onBusyChanged: (value) =>
                    setState(() => _isPickingMedia = value),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                  label: 'Request Delivery',
                  onPressed: _isPickingMedia ? null : _submit,
                  isLoading: _isSubmitting),
            ],
          ),
        ),
      ),
    );
  }
}
