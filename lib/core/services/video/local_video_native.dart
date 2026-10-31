import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../../../data/models/media_attachment.dart';
import 'local_video_types.dart';

Future<LocalVideoSource> prepareLocalVideo(MediaAttachment item) async {
  final root = await getTemporaryDirectory();
  final directory = await root.createTemp('mv_media_');
  try {
    final extension = item.name.split('.').last.toLowerCase();
    final safeExtension =
        ['mp4', 'mov', 'webm'].contains(extension) ? extension : 'mp4';
    final file = File('${directory.path}/video.$safeExtension');
    await file.writeAsBytes(item.bytes, flush: true);
    return LocalVideoSource(VideoPlayerController.file(file), () async {
      if (await directory.exists()) await directory.delete(recursive: true);
    });
  } catch (_) {
    await directory.delete(recursive: true);
    rethrow;
  }
}
