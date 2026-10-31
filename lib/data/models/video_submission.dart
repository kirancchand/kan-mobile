import 'media_attachment.dart';

enum VideoStatus { pending, approved, featured, rejected }

extension VideoStatusLabel on VideoStatus {
  String get label {
    switch (this) {
      case VideoStatus.pending:
        return 'Pending Review';
      case VideoStatus.approved:
        return 'Approved';
      case VideoStatus.featured:
        return 'Featured';
      case VideoStatus.rejected:
        return 'Rejected';
    }
  }
}

class VideoSubmission {
  final List<MediaAttachment> attachments;
  final String id;
  final String title;
  final String submittedBy;
  final String description;
  final String? videoUrl;
  final VideoStatus status;
  final int views;
  final DateTime submittedAt;

  const VideoSubmission({
    required this.id,
    this.attachments = const [],
    required this.title,
    required this.submittedBy,
    required this.description,
    this.videoUrl,
    required this.status,
    this.views = 0,
    required this.submittedAt,
  });

  /// Only real media is shown; missing media uses a neutral placeholder.
  String get thumbnailUrl => '';
}
