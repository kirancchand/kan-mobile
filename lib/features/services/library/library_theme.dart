import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_tokens.dart';

/// Aqua and pastel library palette inspired by samples/book.jpg.
class LibraryPage extends StatelessWidget {
  const LibraryPage(
      {super.key, required this.title, required this.body, this.bottom});
  final String title;
  final WidgetBuilder body;
  final WidgetBuilder? bottom;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final dark = base.brightness == Brightness.dark;
    final primary = dark ? const Color(0xFF91DAEE) : const Color(0xFF176887);
    final surface = dark ? const Color(0xFF203746) : const Color(0xFFF8FDFF);
    final soft = dark ? const Color(0xFF284957) : const Color(0xFFDDF3F9);
    final ink = dark ? const Color(0xFFEAF8FD) : const Color(0xFF203845);
    final muted = dark ? const Color(0xFFB4CEDB) : const Color(0xFF536E7C);
    final border = dark ? const Color(0xFF527281) : const Color(0xFFC8E5ED);
    final textTheme = base.textTheme.apply(bodyColor: ink, displayColor: ink);
    final scheme = base.colorScheme.copyWith(
      primary: primary,
      onPrimary: dark ? const Color(0xFF122A37) : Colors.white,
      primaryContainer: soft,
      onPrimaryContainer: primary,
      secondary: primary,
      secondaryContainer: soft,
      onSecondaryContainer: ink,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: muted,
      surfaceContainerHighest: soft,
      outline: border,
      outlineVariant: border,
    );
    final outline = OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: border));
    final theme = base.copyWith(
      colorScheme: scheme,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: primary),
      extensions: [
        context.tokens.copyWith(
          brand: primary,
          textMuted: muted,
          border: border,
          skeletonBase: soft,
          skeletonHighlight: surface,
          toneInk: {
            ...context.tokens.toneInk,
            AppTone.info: primary,
            AppTone.brand: primary,
            AppTone.neutral: muted
          },
          toneSoft: {
            ...context.tokens.toneSoft,
            AppTone.info: soft,
            AppTone.brand: soft,
            AppTone.neutral: surface
          },
        )
      ],
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle:
            textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: scheme.onPrimary,
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      )),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: surface.withValues(alpha: 0.72),
        border: outline,
        enabledBorder: outline,
        focusedBorder:
            outline.copyWith(borderSide: BorderSide(color: primary, width: 2)),
        prefixIconColor: muted,
        labelStyle: TextStyle(color: muted),
        hintStyle: TextStyle(color: muted),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surface.withValues(alpha: 0.65),
        selectedColor: soft,
        labelStyle: TextStyle(color: ink),
        checkmarkColor: primary,
        side: BorderSide(color: border),
      ),
      bottomSheetTheme:
          base.bottomSheetTheme.copyWith(backgroundColor: surface),
    );
    return Theme(
        data: theme,
        child: Builder(
            builder: (context) => BackdropGroup(
                    child: Stack(children: [
                  Positioned.fill(
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: dark
                        ? [
                            const Color(0xFF152834),
                            const Color(0xFF193E49),
                            const Color(0xFF252B42)
                          ]
                        : [
                            const Color(0xFFF5FCFF),
                            const Color(0xFFD9F5F6),
                            const Color(0xFFECEBFA)
                          ],
                  )))),
                  Positioned(
                      top: 110,
                      right: -85,
                      child: _Glow(
                          color: dark
                              ? const Color(0xFF326B84)
                              : const Color(0xFF8CDEE7))),
                  Positioned(
                      bottom: 100,
                      left: -100,
                      child: _Glow(
                          color: dark
                              ? const Color(0xFF69495C)
                              : const Color(0xFFF5BFCF))),
                  Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(title: Text(title)),
                    body: body(context),
                    bottomNavigationBar: bottom == null
                        ? null
                        : SafeArea(
                            child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            child: LibraryGlass(
                                padding: const EdgeInsets.all(8),
                                child: bottom!(context)),
                          )),
                  ),
                ]))));
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => IgnorePointer(
          child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              color.withValues(alpha: 0.65),
              color.withValues(alpha: 0)
            ])),
      ));
}

/// Clip before blurring; grouped filters reuse the backdrop for separate cards.
class LibraryGlass extends StatelessWidget {
  const LibraryGlass(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(18),
      this.onTap});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(24);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: [
        BoxShadow(
            color:
                const Color(0xFF25617A).withValues(alpha: dark ? 0.05 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8))
      ]),
      child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter.grouped(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Material(
              color: (dark ? const Color(0xFF203746) : Colors.white)
                  .withValues(alpha: dark ? 0.76 : 0.64),
              shape: RoundedRectangleBorder(
                  borderRadius: radius,
                  side: BorderSide(
                      color:
                          Colors.white.withValues(alpha: dark ? 0.18 : 0.85))),
              child: InkWell(
                  onTap: onTap, child: Padding(padding: padding, child: child)),
            ),
          )),
    );
  }
}
