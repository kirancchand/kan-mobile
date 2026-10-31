import '../../../core/widgets/map_location_field.dart';
import '../../../data/models/map_location.dart';
import '../../../core/widgets/media_attachments.dart';
import '../../../data/models/media_attachment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/marketplace_listing.dart';
import '../../../data/models/service_type.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../../../state/app_state.dart';

class MarketplacePostScreen extends StatefulWidget {
  final ServiceType serviceType;
  final Widget Function(Widget child)? formWrapper;

  const MarketplacePostScreen(
      {super.key, required this.serviceType, this.formWrapper});

  @override
  State<MarketplacePostScreen> createState() => _MarketplacePostScreenState();
}

class _MarketplacePostScreenState extends State<MarketplacePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  ListingCondition _condition = ListingCondition.good;
  MarketListingType _listingType = MarketListingType.sell;
  MapLocation? _pickupPoint;
  bool _isSubmitting = false;
  bool _isPickingMedia = false;
  List<MediaAttachment> _attachments = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
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
      await context.read<MarketplaceRepository>().createListing(
            attachments: _attachments,
            sellerId: user?.id,
            locationId: user?.locationId,
            pickupPoint: _pickupPoint,
            type: widget.serviceType,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            price: double.tryParse(_priceController.text.trim()) ?? 0,
            category: _categoryController.text.trim(),
            condition: _condition,
            listingType:
                widget.serviceType == ServiceType.buySell ? _listingType : null,
            sellerName: user?.name ?? 'You',
            sellerPhone: user?.phone ?? '',
            location: 'Your Village',
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error is ArgumentError
              ? '${error.message}'
              : 'Could not post listing. Please try again.')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.serviceType;
    return Scaffold(
      appBar: AppBar(title: Text('Post in ${type.label}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Builder(builder: (context) {
          final form = Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (type == ServiceType.buySell) ...[
                  Text('I want to',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  SegmentedButton<MarketListingType>(
                    segments: [
                      for (final value in MarketListingType.values.reversed)
                        ButtonSegment(value: value, label: Text(value.label)),
                    ],
                    selected: {_listingType},
                    onSelectionChanged: _isSubmitting
                        ? null
                        : (value) =>
                            setState(() => _listingType = value.single),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter a description'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter a category'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                      labelText: 'Price (₹)', prefixText: '₹ '),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter a price';
                    if (double.tryParse(v.trim()) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Condition',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: ListingCondition.values.map((c) {
                    return ChoiceChip(
                      label: Text(c.label),
                      selected: _condition == c,
                      onSelected: (_) => setState(() => _condition = c),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),
                MapLocationField(
                    label: 'pickup location',
                    value: _pickupPoint,
                    enabled: !_isSubmitting,
                    onChanged: (point) => setState(() => _pickupPoint = point)),
                const SizedBox(height: 16),
                MediaAttachmentField(
                  attachments: _attachments,
                  enabled: !_isSubmitting,
                  onChanged: (value) => setState(() => _attachments = value),
                  onBusyChanged: (value) =>
                      setState(() => _isPickingMedia = value),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                    label: 'Post Listing',
                    onPressed: _isPickingMedia ? null : _submit,
                    isLoading: _isSubmitting),
              ],
            ),
          );
          return widget.formWrapper?.call(form) ?? form;
        }),
      ),
    );
  }
}
