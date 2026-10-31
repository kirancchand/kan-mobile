import '../../../core/widgets/media_gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/semantic_tones.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_list_placeholder.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/video_submission.dart';
import '../../../data/repositories/video_repository.dart';
import 'submit_video_screen.dart';
import '../../../core/theme/app_icons.dart';

class YoutubeScreen extends StatefulWidget {
  const YoutubeScreen({super.key});

  @override
  State<YoutubeScreen> createState() => _YoutubeScreenState();
}

class _YoutubeScreenState extends State<YoutubeScreen> {
  late Future<List<VideoSubmission>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = context.read<VideoRepository>().getVideos();
  }

  Future<void> _openSubmitScreen() async {
    final submitted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SubmitVideoScreen()),
    );
    if (submitted == true) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Village YouTube')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSubmitScreen,
        icon: const Icon(AppIcons.uploadSimpleBold),
        label: const Text('Submit Video'),
      ),
      body: FutureBuilder<List<VideoSubmission>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(onRetry: () => setState(_reload));
          }
          if (!snapshot.hasData) return const ShimmerListPlaceholder();
          final videos = snapshot.data!;
          if (videos.isEmpty) {
            return EmptyState(
              icon: AppIcons.playCircle,
              tone: AppTone.accent,
              title: 'No videos submitted yet',
              message:
                  'Share village moments — approved videos are featured on the official channel.',
              actionLabel: 'Submit Video',
              onAction: _openSubmitScreen,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.ms,
                AppSpacing.md, AppSpacing.fabClearance),
            itemCount: videos.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.ms),
            itemBuilder: (context, index) {
              final video = videos[index];
              return AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.ms),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MediaGallery(attachments: video.attachments),
                      if (video.videoUrl != null)
                        SelectableText(video.videoUrl!),
                      if (video.attachments.isEmpty)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            AppNetworkImage(
                              url: video.thumbnailUrl,
                              height: 160,
                              width: double.infinity,
                              borderRadius: AppRadius.md,
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color:
                                    AppColors.midnight.withValues(alpha: 0.2),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            const Icon(AppIcons.playCircleFill,
                                color: AppColors.white,
                                size: 48,
                                semanticLabel: 'Play video'),
                          ],
                        ),
                      const SizedBox(height: AppSpacing.ms),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(video.title,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            StatusChip(
                                label: video.status.label,
                                tone: video.status.tone),
                          ]),
                      const SizedBox(height: AppSpacing.xs),
                      Text(video.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: context.tokens.textMuted)),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(spacing: 12, runSpacing: 8, children: [
                        Text('By ${video.submittedBy}',
                            style: Theme.of(context).textTheme.bodySmall),
                        if (video.views > 0)
                          Text('${video.views} views',
                              style: Theme.of(context).textTheme.bodySmall),
                        Text(Formatters.relative(video.submittedAt),
                            style: Theme.of(context).textTheme.bodySmall),
                      ]),
                    ],
                  ),
                ),
              )
                  .animate(delay: (index * 40).ms)
                  .fadeIn(duration: 250.ms)
                  .slideY(begin: 0.06, end: 0, curve: Curves.easeOut);
            },
          );
        },
      ),
    );
  }
}
