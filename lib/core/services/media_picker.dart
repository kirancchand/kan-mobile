import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import '../../data/models/media_attachment.dart';

class MediaPicker {
  static const maxFiles = 5;
  static const maxFileBytes = 20 * 1024 * 1024;
  static const maxTotalBytes = 50 * 1024 * 1024;
  static const imageExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
  static const videoExtensions = ['mp4', 'mov', 'webm'];

  Future<MediaAttachment?> pick(MediaKind kind,
      {required int remainingBytes}) async {
    final image = kind == MediaKind.image;
    final file = await openFile(acceptedTypeGroups: [
      XTypeGroup(
        label: image ? 'Images' : 'Videos',
        extensions: image ? imageExtensions : videoExtensions,
        uniformTypeIdentifiers: image
            ? [
                'public.jpeg',
                'public.png',
                'org.webmproject.webp',
                'com.compuserve.gif'
              ]
            : [
                'public.mpeg-4',
                'com.apple.quicktime-movie',
                'org.webmproject.webm'
              ],
      ),
    ]);
    if (file == null) return null;
    return readFile(file, kind, remainingBytes: remainingBytes);
  }

  Future<MediaAttachment> readFile(XFile file, MediaKind kind,
      {required int remainingBytes}) async {
    final extension = file.name.split('.').last.toLowerCase();
    final allowed = kind == MediaKind.image ? imageExtensions : videoExtensions;
    if (!allowed.contains(extension)) {
      throw const FormatException('Choose a supported image or video format.');
    }
    final size = await file.length();
    void validateSize(int value) {
      if (value == 0) throw const FormatException('This file is empty.');
      if (value > maxFileBytes) {
        throw const FormatException('Choose a file smaller than 20 MB.');
      }
      if (value > remainingBytes) {
        throw const FormatException('Attachments must total 50 MB or less.');
      }
    }

    validateSize(size);
    // Limit the read too, in case the source file changes after its size check.
    final builder = BytesBuilder(copy: false);
    await for (final chunk in file.openRead()) {
      validateSize(builder.length + chunk.length);
      builder.add(chunk);
    }
    validateSize(builder.length);
    return MediaAttachment(
        name: file.name, kind: kind, bytes: builder.takeBytes());
  }
}
