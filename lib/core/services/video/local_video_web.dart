import 'package:video_player/video_player.dart';
import '../../../data/models/media_attachment.dart';
import 'local_video_types.dart';

Future<LocalVideoSource> prepareLocalVideo(MediaAttachment item) async {
  final mime = switch (item.name.split('.').last.toLowerCase()) {
    'webm' => 'video/webm',
    'mov' => 'video/quicktime',
    _ => 'video/mp4',
  };
  // No filesystem access or network upload: the browser reads selected bytes.
  final uri = Uri.dataFromBytes(item.bytes, mimeType: mime);
  return LocalVideoSource(VideoPlayerController.networkUrl(uri), () async {});
}
