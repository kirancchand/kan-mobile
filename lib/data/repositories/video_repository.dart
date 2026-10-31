import '../models/media_attachment.dart';
import 'package:flutter/foundation.dart';
import '../models/video_submission.dart';

class VideoRepository {
  VideoRepository({Iterable<VideoSubmission> initialItems = const []})
      : _videos = List.of(initialItems);
  final _changes = ValueNotifier<int>(0);
  Listenable get changes => _changes;
  void dispose() => _changes.dispose();

  final List<VideoSubmission> _videos;

  Future<List<VideoSubmission>> getVideos() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [..._videos]..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  Future<VideoSubmission> submitVideo({
    required String title,
    required String submittedBy,
    required String description,
    String? videoUrl,
    List<MediaAttachment> attachments = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final video = VideoSubmission(
      attachments: List.unmodifiable(attachments),
      id: 'vid_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      submittedBy: submittedBy,
      description: description,
      videoUrl: videoUrl,
      status: VideoStatus.pending,
      submittedAt: DateTime.now(),
    );
    _videos.insert(0, video);
    _changes.value++;
    return video;
  }
}
