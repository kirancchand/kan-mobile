import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/paper_banner.dart';

class VillageMark extends StatelessWidget {
  const VillageMark({super.key, this.onLight = false});
  final bool onLight;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: onLight ? PaperBanner.teal : PaperBanner.mustard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: Icon(AppIcons.house,
            size: 48, color: onLight ? PaperBanner.mustard : PaperBanner.teal),
      );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onComplete});
  final VoidCallback onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1400), widget.onComplete);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: PaperBanner.teal,
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const VillageMark(),
            const SizedBox(height: 24),
            Text('Village Connect',
                textAlign: TextAlign.center,
                style: text.headlineLarge?.copyWith(color: Colors.white)),
            const SizedBox(height: 12),
            Text('Your village. Closer together.',
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(color: Colors.white)),
            const SizedBox(height: 48),
            const SizedBox(
                width: 100,
                child: LinearProgressIndicator(
                  color: PaperBanner.mustard,
                  backgroundColor: Colors.white24,
                  semanticsLabel: 'Opening Village Connect',
                )),
          ]),
        ),
      )),
    );
  }
}
