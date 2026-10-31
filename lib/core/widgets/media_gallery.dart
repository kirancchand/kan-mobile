import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../data/models/media_attachment.dart';
import '../services/video/local_video_source.dart';
import '../theme/app_icons.dart';

String mediaSummary(List<MediaAttachment> attachments) {
  final photos =
      attachments.where((item) => item.kind == MediaKind.image).length;
  final videos = attachments.length - photos;
  return [
    if (photos > 0) '$photos ${photos == 1 ? 'image' : 'images'}',
    if (videos > 0) '$videos ${videos == 1 ? 'video' : 'videos'}',
  ].join(' · ');
}

void openMediaGallery(BuildContext context, List<MediaAttachment> attachments,
    {int initialIndex = 0}) {
  if (attachments.isEmpty) return;
  Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Images & videos')),
          body: SafeArea(
              child: MediaGallery(
                  attachments: attachments,
                  initialIndex: initialIndex,
                  expanded: true)),
        ),
      ));
}

/// Shared mixed-media gallery. Only the active fullscreen video gets a player.
class MediaGallery extends StatefulWidget {
  const MediaGallery(
      {super.key,
      required this.attachments,
      this.initialIndex = 0,
      this.expanded = false,
      this.videoLoader = prepareLocalVideo});
  final List<MediaAttachment> attachments;
  final int initialIndex;
  final bool expanded;
  final VideoSourceLoader videoLoader;

  @override
  State<MediaGallery> createState() => _MediaGalleryState();
}

class _MediaGalleryState extends State<MediaGallery> {
  late final PageController _pages;
  late int _index;
  late final ValueNotifier<int> _activeIndex;
  @override
  void initState() {
    super.initState();
    _index = widget.attachments.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, widget.attachments.length - 1);
    _pages = PageController(initialPage: _index);
    _activeIndex = ValueNotifier(_index);
  }

  @override
  void didUpdateWidget(MediaGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.attachments.length) {
      _index = 0;
      _activeIndex.value = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pages.hasClients) _pages.jumpToPage(0);
      });
    }
  }

  @override
  void dispose() {
    _activeIndex.dispose();
    _pages.dispose();
    super.dispose();
  }

  void _select(int index) {
    _pages.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.attachments;
    if (items.isEmpty) return const SizedBox.shrink();
    final viewport = ClipRRect(
      borderRadius: BorderRadius.circular(widget.expanded ? 0 : 20),
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: PageView.builder(
          key: const ValueKey('media-gallery-pages'),
          controller: _pages,
          itemCount: items.length,
          onPageChanged: (index) {
            _activeIndex.value = index;
            setState(() => _index = index);
          },
          itemBuilder: (context, index) {
            final item = items[index];
            if (widget.expanded) {
              if (item.kind == MediaKind.image) {
                return InteractiveViewer(
                    minScale: 1,
                    maxScale: 5,
                    child: Center(child: _MediaImage(item: item)));
              }
              return ValueListenableBuilder<int>(
                valueListenable: _activeIndex,
                builder: (context, active, _) => index == active
                    ? AttachmentVideoPlayer(
                        key: ObjectKey(item),
                        attachment: item,
                        loader: widget.videoLoader)
                    : _VideoTile(item: item),
              );
            }
            return Semantics(
                button: true,
                label: 'Open ${item.name}',
                child: InkWell(
                  onTap: () =>
                      openMediaGallery(context, items, initialIndex: index),
                  child: item.kind == MediaKind.image
                      ? _MediaImage(item: item)
                      : _VideoTile(item: item),
                ));
          },
        ),
      ),
    );
    final controls = Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        IconButton(
            tooltip: 'Previous media',
            onPressed: _index > 0 ? () => _select(_index - 1) : null,
            icon: const Icon(Icons.chevron_left)),
        Expanded(
            child: Semantics(
                liveRegion: true,
                child: Text(
                    '${_index + 1} / ${items.length} · ${mediaSummary(items)}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall))),
        IconButton(
            tooltip: 'Next media',
            onPressed:
                _index < items.length - 1 ? () => _select(_index + 1) : null,
            icon: const Icon(Icons.chevron_right)),
        if (!widget.expanded)
          IconButton(
              tooltip: 'Open full screen',
              onPressed: () =>
                  openMediaGallery(context, items, initialIndex: _index),
              icon: const Icon(Icons.fullscreen)),
      ]),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(items[_index].name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall)),
      if (items.length > 1)
        SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) => Semantics(
                  selected: index == _index,
                  button: true,
                  label: 'Show media ${index + 1}: ${items[index].name}',
                  child: InkWell(
                      onTap: () => _select(index),
                      child: Container(
                        width: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: index == _index ? 3 : 1,
                                color: index == _index
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline)),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: items[index].kind == MediaKind.image
                                ? _MediaImage(
                                    item: items[index], thumbnail: true)
                                : const Icon(AppIcons.playCircle)),
                      ))),
            )),
      const SizedBox(height: 8),
    ]);
    if (widget.expanded) {
      return Column(children: [Expanded(child: viewport), controls]);
    }
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(height: 240, child: viewport),
      controls,
    ]);
  }
}

/// Catalog cover that opens every attachment, with artwork for older entries.
class MediaCover extends StatelessWidget {
  const MediaCover(
      {super.key,
      required this.attachments,
      required this.child,
      required this.height,
      this.width = double.infinity});
  final List<MediaAttachment> attachments;
  final Widget child;
  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return child;
    return SizedBox(
        height: height,
        width: width,
        child: Semantics(
          button: true,
          label: 'View ${mediaSummary(attachments)}',
          child: InkWell(
            onTap: () => openMediaGallery(context, attachments),
            child: Stack(fit: StackFit.expand, children: [
              if (attachments.first.kind == MediaKind.image)
                _MediaImage(item: attachments.first, thumbnail: true)
              else
                ColoredBox(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: const Center(
                        child: Icon(AppIcons.playCircle, size: 48))),
              Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(mediaSummary(attachments),
                        maxLines: 2,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 11)),
                  )),
            ]),
          ),
        ));
  }
}

class _MediaImage extends StatelessWidget {
  const _MediaImage({required this.item, this.thumbnail = false});
  final MediaAttachment item;
  final bool thumbnail;
  @override
  Widget build(BuildContext context) => Image.memory(
        item.bytes,
        fit: thumbnail ? BoxFit.cover : BoxFit.contain,
        cacheWidth: thumbnail ? 320 : 1600,
        semanticLabel: item.name,
        errorBuilder: (_, __, ___) => Center(
            child: thumbnail
                ? const Icon(AppIcons.image)
                : const Text('Image unavailable', textAlign: TextAlign.center)),
      );
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.item});
  final MediaAttachment item;
  @override
  Widget build(BuildContext context) => const Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.playCircle, size: 56),
          SizedBox(height: 8),
          Text('Open video'),
        ],
      ));
}

typedef VideoSourceLoader = Future<LocalVideoSource> Function(MediaAttachment);

class AttachmentVideoPlayer extends StatefulWidget {
  const AttachmentVideoPlayer(
      {super.key, required this.attachment, this.loader = prepareLocalVideo});
  final MediaAttachment attachment;
  final VideoSourceLoader loader;
  @override
  State<AttachmentVideoPlayer> createState() => _AttachmentVideoPlayerState();
}

class _AttachmentVideoPlayerState extends State<AttachmentVideoPlayer>
    with WidgetsBindingObserver {
  LocalVideoSource? _source;
  bool _failed = false;
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    LocalVideoSource? source;
    try {
      source = await widget.loader(widget.attachment);
      if (!mounted || generation != _generation) {
        await source.dispose();
        return;
      }
      _source = source;
      await source.controller.initialize();
      if (mounted && generation == _generation) setState(() {});
    } catch (_) {
      if (mounted && generation == _generation) {
        _source = null;
        if (source != null) await source.dispose();
        if (mounted) setState(() => _failed = true);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _source?.controller.pause();
  }

  @override
  void dispose() {
    _generation++;
    WidgetsBinding.instance.removeObserver(this);
    final source = _source;
    _source = null;
    if (source != null) unawaited(source.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _source?.controller;
    if (_failed) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(AppIcons.playCircle, size: 40),
        const Padding(
            padding: EdgeInsets.all(16),
            child: Text('This video could not be played on this device.',
                textAlign: TextAlign.center)),
        TextButton(
            onPressed: () {
              setState(() => _failed = false);
              _load();
            },
            child: const Text('Retry video')),
      ]));
    }
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading video'));
    }
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.hasError) {
          return const Center(child: Text('Video playback failed.'));
        }
        return Column(children: [
          Expanded(
              child: Center(
                  child: AspectRatio(
                      aspectRatio: value.aspectRatio,
                      child: VideoPlayer(controller)))),
          VideoProgressIndicator(controller,
              allowScrubbing: true, padding: const EdgeInsets.all(12)),
          Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton(
                    tooltip: value.isPlaying ? 'Pause video' : 'Play video',
                    icon:
                        Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () async {
                      if (value.isPlaying) {
                        await controller.pause();
                      } else {
                        if (value.position >= value.duration) {
                          await controller.seekTo(Duration.zero);
                        }
                        await controller.play();
                      }
                    }),
                Text('${_time(value.position)} / ${_time(value.duration)}'),
                IconButton(
                    tooltip: value.volume == 0 ? 'Unmute video' : 'Mute video',
                    onPressed: () =>
                        controller.setVolume(value.volume == 0 ? 1 : 0),
                    icon: Icon(value.volume == 0
                        ? Icons.volume_off
                        : Icons.volume_up)),
              ]),
        ]);
      },
    );
  }

  String _time(Duration value) =>
      '${value.inMinutes}:${(value.inSeconds % 60).toString().padLeft(2, '0')}';
}
