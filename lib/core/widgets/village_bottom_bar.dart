import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/app_icons.dart';
import '../theme/app_tokens.dart';

/// Curved bottom navigation (samples/bottom.gif): the selected tab's icon
/// floats in a circle above a notch cut into the bar, and both slide to the
/// newly selected tab.
class VillageBottomBar extends StatefulWidget {
  const VillageBottomBar(
      {super.key, required this.selectedIndex, required this.onSelected});
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<VillageBottomBar> createState() => _VillageBottomBarState();
}

class _VillageBottomBarState extends State<VillageBottomBar>
    with SingleTickerProviderStateMixin {
  static const _labels = ['Home', 'Services', 'Profile', 'Admin'];
  static const _icons = [
    AppIcons.house,
    AppIcons.gridFour,
    AppIcons.user,
    AppIcons.shieldCheck
  ];
  static const _selectedIcons = [
    AppIcons.houseFill,
    AppIcons.gridFourFill,
    AppIcons.userFill,
    AppIcons.shieldCheckFill
  ];

  static const _circleRadius = 26.0;
  static const _notchRadius = 32.0;

  /// How far the circle dips into the bar mid-slide.
  static const _dip = 14.0;

  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300));
  late double _from = widget.selectedIndex.toDouble();

  @override
  void didUpdateWidget(VillageBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex == widget.selectedIndex) return;
    _from = _positionFor(oldWidget.selectedIndex);
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Current notch position, given the index it is travelling towards.
  double _positionFor(int target) {
    final t = _controller.isAnimating
        ? Curves.easeOutCubic.transform(_controller.value)
        : 1.0;
    return _from + (target - _from) * t;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = context.tokens;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final labelStyle = theme.textTheme.labelSmall;
    final labelHeight =
        MediaQuery.textScalerOf(context).scale(labelStyle?.fontSize ?? 12) *
            1.3;
    // The selected label sits below the notch; inactive slots stack an icon
    // above their label in the same height.
    final barHeight = _notchRadius + 14 + labelHeight;
    const lift = _circleRadius + 4;

    return SizedBox(
      height: lift + barHeight + bottomInset,
      child: LayoutBuilder(builder: (context, constraints) {
        final slot = constraints.maxWidth / _labels.length;
        final rtl = Directionality.of(context) == TextDirection.rtl;
        double centerOf(double position) {
          final x = slot * position + slot / 2;
          return rtl ? constraints.maxWidth - x : x;
        }

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final cx = centerOf(_positionFor(widget.selectedIndex));
            final sink = _controller.isAnimating
                ? math.sin(math.pi * _controller.value) * _dip
                : 0.0;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  top: lift,
                  child: CustomPaint(
                    painter: _NotchedBarPainter(
                      notchCenter: cx,
                      notchRadius: _notchRadius,
                      color: scheme.surface,
                      borderColor: tokens.border,
                      shadowColor: scheme.shadow,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomInset),
                      child: Row(
                        children: List.generate(_labels.length, (index) {
                          final selected = widget.selectedIndex == index;
                          final color =
                              selected ? scheme.primary : tokens.textMuted;
                          return Expanded(
                            child: Semantics(
                              label: _labels[index],
                              button: true,
                              selected: selected,
                              excludeSemantics: true,
                              child: InkWell(
                                onTap: () => widget.onSelected(index),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(2, 6, 2, 6),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      AnimatedOpacity(
                                        opacity: selected ? 0 : 1,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: Icon(_icons[index],
                                            color: color, size: 24),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(_labels[index],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: labelStyle?.copyWith(
                                              color: color,
                                              fontWeight: selected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: cx - _circleRadius,
                  top: lift - _circleRadius + sink,
                  child: ExcludeSemantics(
                    child: GestureDetector(
                      onTap: () => widget.onSelected(widget.selectedIndex),
                      child: Container(
                        width: _circleRadius * 2,
                        height: _circleRadius * 2,
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: tokens.border),
                          boxShadow: tokens.cardShadow,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) =>
                              RotationTransition(
                            turns:
                                Tween(begin: -0.25, end: 0.0).animate(animation),
                            child:
                                ScaleTransition(scale: animation, child: child),
                          ),
                          child: Icon(_selectedIcons[widget.selectedIndex],
                              key: ValueKey(widget.selectedIndex),
                              color: scheme.primary,
                              size: 26),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}

/// Bar surface with a smooth notch centred on [notchCenter].
class _NotchedBarPainter extends CustomPainter {
  const _NotchedBarPainter({
    required this.notchCenter,
    required this.notchRadius,
    required this.color,
    required this.borderColor,
    required this.shadowColor,
  });

  final double notchCenter;
  final double notchRadius;
  final Color color;
  final Color borderColor;
  final Color shadowColor;

  Path _topEdge(Size size) {
    final r = notchRadius;
    final shoulder = r * 0.45;
    final cx = notchCenter;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(cx - r - shoulder, 0)
      ..cubicTo(cx - r + shoulder * 0.3, 0, cx - r * 0.8, r, cx, r)
      ..cubicTo(
          cx + r * 0.8, r, cx + r - shoulder * 0.3, 0, cx + r + shoulder, 0)
      ..lineTo(size.width, 0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final edge = _topEdge(size);
    final body = Path.from(edge)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawShadow(body, shadowColor.withValues(alpha: 0.25), 4, false);
    canvas.drawPath(body, Paint()..color = color);
    canvas.drawPath(
        edge,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(_NotchedBarPainter old) =>
      old.notchCenter != notchCenter ||
      old.color != color ||
      old.borderColor != borderColor ||
      old.shadowColor != shadowColor;
}
