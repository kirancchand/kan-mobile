import 'media_gallery.dart';
import 'package:flutter/material.dart';
import '../../data/models/media_attachment.dart';
import '../services/media_picker.dart';
import '../theme/app_icons.dart';

/// Shared selection UI used by all eight service entry forms.
class MediaAttachmentField extends StatefulWidget {
  const MediaAttachmentField(
      {super.key,
      required this.attachments,
      required this.onChanged,
      required this.onBusyChanged,
      this.enabled = true,
      this.picker});
  final List<MediaAttachment> attachments;
  final ValueChanged<List<MediaAttachment>> onChanged;
  final ValueChanged<bool> onBusyChanged;
  final bool enabled;
  final MediaPicker? picker;

  @override
  State<MediaAttachmentField> createState() => _MediaAttachmentFieldState();
}

class _MediaAttachmentFieldState extends State<MediaAttachmentField> {
  bool _busy = false;
  String? _error;

  Future<void> _pick(MediaKind kind) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    widget.onBusyChanged(true);
    try {
      final used =
          widget.attachments.fold<int>(0, (sum, item) => sum + item.size);
      final item = await (widget.picker ?? MediaPicker())
          .pick(kind, remainingBytes: MediaPicker.maxTotalBytes - used);
      if (!mounted) return;
      if (item != null) widget.onChanged([...widget.attachments, item]);
    } on FormatException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not read that file. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        widget.onBusyChanged(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = widget.enabled &&
        !_busy &&
        widget.attachments.length < MediaPicker.maxFiles;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Images & videos', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6),
      const Text('Up to 5 files · 20 MB each · 50 MB total',
          style: TextStyle(fontSize: 12)),
      const SizedBox(height: 6),
      const Text('Images: JPG, PNG, WebP, GIF. Videos: MP4, MOV, WebM.',
          style: TextStyle(fontSize: 12)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        OutlinedButton.icon(
            onPressed: canAdd ? () => _pick(MediaKind.image) : null,
            icon: const Icon(AppIcons.image),
            label: const Text('Add image')),
        OutlinedButton.icon(
            onPressed: canAdd ? () => _pick(MediaKind.video) : null,
            icon: const Icon(AppIcons.playCircle),
            label: const Text('Add video')),
      ]),
      if (_busy)
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child:
                LinearProgressIndicator(semanticsLabel: 'Reading attachment')),
      if (_error != null)
        Semantics(
            liveRegion: true,
            child: Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error))),
      MediaAttachmentList(
          attachments: widget.attachments,
          onRemove: widget.enabled && !_busy
              ? (index) {
                  final next = [...widget.attachments]..removeAt(index);
                  widget.onChanged(next);
                }
              : null),
    ]);
  }
}

/// Editable selection rows open the shared mixed-media viewer.
class MediaAttachmentList extends StatelessWidget {
  const MediaAttachmentList(
      {super.key, required this.attachments, this.onRemove});
  final List<MediaAttachment> attachments;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) => Column(
        children: List.generate(attachments.length, (index) {
          final item = attachments[index];
          final image = item.kind == MediaKind.image;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              if (image)
                Semantics(
                    button: true,
                    label: 'Preview ${item.name}',
                    child: InkWell(
                      onTap: () => openMediaGallery(context, attachments,
                          initialIndex: index),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(item.bytes,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              cacheWidth: 160,
                              errorBuilder: (_, __, ___) => const SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: Icon(AppIcons.image)))),
                    ))
              else
                IconButton(
                    tooltip: 'Preview ${item.name}',
                    onPressed: () => openMediaGallery(context, attachments,
                        initialIndex: index),
                    icon: const Icon(AppIcons.playCircle)),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(item.name,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(
                        '${image ? 'Image' : 'Video'} · ${(item.size / (1024 * 1024)).toStringAsFixed(1)} MB',
                        style: Theme.of(context).textTheme.bodySmall),
                  ])),
              if (onRemove != null)
                IconButton(
                    tooltip: 'Remove ${item.name}',
                    onPressed: () => onRemove!(index),
                    icon: const Icon(Icons.close)),
            ]),
          );
        }),
      );
}
