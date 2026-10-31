import '../../../core/widgets/media_gallery.dart';
import 'package:flutter/material.dart';
import '../../../data/models/book_listing.dart';

/// Original typographic placeholder cover, built from listing metadata.
class LibraryBookCover extends StatelessWidget {
  const LibraryBookCover(
      {super.key, required this.book, this.width = 104, this.height = 150});
  final BookListing book;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (book.attachments.isNotEmpty) {
      return MediaCover(
          attachments: book.attachments,
          height: height,
          width: width,
          child: const SizedBox.shrink());
    }
    final index =
        book.id.codeUnits.fold<int>(0, (sum, value) => sum + value) % 3;
    final colors = [
      [const Color(0xFFB4EBEA), const Color(0xFF61C5D6)],
      [const Color(0xFFFFD9DF), const Color(0xFFF0A4BA)],
      [const Color(0xFFD7DEFA), const Color(0xFFA9BCEB)],
    ][index];
    return Semantics(
        label: '${book.title}, illustrated cover',
        image: true,
        child: ExcludeSemantics(
            child: Container(
          width: width,
          height: height,
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(6), boxShadow: [
            BoxShadow(
                color: const Color(0xFF254557).withValues(alpha: 0.16),
                blurRadius: 10,
                offset: const Offset(3, 6))
          ]),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(children: [
                Positioned.fill(
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: colors)))),
                Positioned(
                    right: -width * 0.27,
                    top: height * 0.42,
                    child: Container(
                        width: width,
                        height: width,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.45),
                                width: width * 0.17)))),
                Positioned(
                    left: width * 0.14,
                    bottom: height * 0.17,
                    child: Transform.rotate(
                        angle: -0.6,
                        child: Container(
                            width: width * 0.24,
                            height: width * 0.24,
                            color: Colors.white.withValues(alpha: 0.35)))),
                Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 5,
                    child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.08))),
                Padding(
                    padding: EdgeInsets.all(width * 0.12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.genre.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textScaler: TextScaler.noScaling,
                              style: TextStyle(
                                  fontSize: width * 0.06,
                                  color: const Color(0xFF294656),
                                  letterSpacing: 0.6)),
                          SizedBox(height: height * 0.09),
                          Text(book.title,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              textScaler: TextScaler.noScaling,
                              style: TextStyle(
                                  fontSize: width * 0.12,
                                  height: 1.2,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF213E4D))),
                          const Spacer(),
                          Text(book.author,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textScaler: TextScaler.noScaling,
                              style: TextStyle(
                                  fontSize: width * 0.065,
                                  color: const Color(0xFF294656))),
                        ])),
              ])),
        )));
  }
}
