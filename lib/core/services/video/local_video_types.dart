import 'package:video_player/video_player.dart';

class LocalVideoSource {
  LocalVideoSource(this.controller, this.release);
  final VideoPlayerController controller;
  final Future<void> Function() release;

  Future<void> dispose() async {
    try {
      await controller.dispose();
    } finally {
      await release();
    }
  }
}
