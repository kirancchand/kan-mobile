import '../../../core/widgets/media_attachments.dart';
import '../../../data/models/media_attachment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/repositories/video_repository.dart';
import '../../../state/app_state.dart';

class SubmitVideoScreen extends StatefulWidget {
  const SubmitVideoScreen({super.key});

  @override
  State<SubmitVideoScreen> createState() => _SubmitVideoScreenState();
}

class _SubmitVideoScreenState extends State<SubmitVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  bool _isSubmitting = false;
  bool _isPickingMedia = false;
  List<MediaAttachment> _attachments = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
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
      await context.read<VideoRepository>().submitVideo(
            attachments: _attachments,
            videoUrl: _linkController.text.trim().isEmpty
                ? null
                : _linkController.text.trim(),
            title: _titleController.text.trim(),
            submittedBy: user?.name ?? 'You',
            description: _descriptionController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Submitted! Our team will review it before it goes live.')),
      );
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit a Video')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submitted videos are reviewed by the village admin before being featured on the official YouTube channel.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: context.tokens.textMuted),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Video Title'),
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
                controller: _linkController,
                decoration: const InputDecoration(
                    labelText: 'Video Link (YouTube/Drive URL)'),
                validator: (value) {
                  final link = value?.trim() ?? '';
                  if (link.isEmpty) {
                    return _attachments
                            .any((item) => item.kind == MediaKind.video)
                        ? null
                        : 'Add a video or enter a video link';
                  }
                  final uri = Uri.tryParse(link);
                  return uri != null &&
                          (uri.scheme == 'https' || uri.scheme == 'http') &&
                          uri.host.isNotEmpty
                      ? null
                      : 'Enter a valid HTTP or HTTPS video link';
                },
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
                  label: 'Submit for Review',
                  onPressed: _isPickingMedia ? null : _submit,
                  isLoading: _isSubmitting),
            ],
          ),
        ),
      ),
    );
  }
}
