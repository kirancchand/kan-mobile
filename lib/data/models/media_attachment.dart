import 'dart:typed_data';

enum MediaKind { image, video }

/// Selected file bytes retained by the session repositories for this session.
class MediaAttachment {
  MediaAttachment(
      {required this.name, required this.kind, required Uint8List bytes})
      : bytes = Uint8List.fromList(bytes).asUnmodifiableView();

  final String name;
  final MediaKind kind;
  final Uint8List bytes;
  int get size => bytes.length;
}
