import '../../../core/widgets/map_location_field.dart';
import '../../../data/models/map_location.dart';
import '../../../core/widgets/media_attachments.dart';
import '../../../data/models/media_attachment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/book_listing.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../state/app_state.dart';
import 'library_theme.dart';

class PostBookScreen extends StatefulWidget {
  const PostBookScreen({super.key});

  @override
  State<PostBookScreen> createState() => _PostBookScreenState();
}

class _PostBookScreenState extends State<PostBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController();
  final _priceController = TextEditingController();
  BookListingType _listingType = BookListingType.rent;
  MapLocation? _pickupPoint;
  bool _isSubmitting = false;
  bool _isPickingMedia = false;
  List<MediaAttachment> _attachments = [];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _priceController.dispose();
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
      await context.read<BookRepository>().addBook(
            attachments: _attachments,
            ownerId: user?.id,
            locationId: user?.locationId,
            pickupPoint: _pickupPoint,
            title: _titleController.text.trim(),
            author: _authorController.text.trim(),
            listingType: _listingType,
            price: _listingType == BookListingType.rent
                ? 0
                : (double.tryParse(_priceController.text.trim()) ?? 0),
            rentPerWeek: _listingType == BookListingType.rent
                ? '₹${_priceController.text.trim()}/week'
                : null,
            ownerName: user?.name ?? 'You',
            ownerPhone: user?.phone ?? '',
            genre: _genreController.text.trim(),
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LibraryPage(
      title: 'List a Book',
      body: (context) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: LibraryGlass(
            child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Listing Type',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: BookListingType.values.map((t) {
                  return ChoiceChip(
                    label: Text(t.label),
                    selected: _listingType == t,
                    onSelected: (_) => setState(() => _listingType = t),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Book Title'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter the title' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter the author' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(labelText: 'Genre'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a genre' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: _listingType == BookListingType.rent
                      ? 'Rent per week (₹)'
                      : 'Price (₹)',
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter an amount';
                  if (double.tryParse(v.trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
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
                  label: 'List Book',
                  onPressed: _isPickingMedia ? null : _submit,
                  isLoading: _isSubmitting),
            ],
          ),
        )),
      ),
    );
  }
}
