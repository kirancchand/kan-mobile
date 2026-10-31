import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/shimmer_list_placeholder.dart';
import '../../../data/models/book_listing.dart';
import '../../../data/repositories/book_repository.dart';
import 'book_detail_screen.dart';
import 'post_book_screen.dart';
import 'library_book_cover.dart';
import 'library_theme.dart';

class LibraryListScreen extends StatefulWidget {
  const LibraryListScreen({super.key});
  @override
  State<LibraryListScreen> createState() => _LibraryListScreenState();
}

class _LibraryListScreenState extends State<LibraryListScreen> {
  late Future<List<BookListing>> _future;
  BookListingType? _filter;
  String _query = '';
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = context.read<BookRepository>().getBooks();
  }

  Future<void> _openPostScreen() async {
    final created = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => const PostBookScreen()));
    if (created == true && mounted) setState(_reload);
  }

  void _open(BookListing book) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)));

  @override
  Widget build(BuildContext context) => LibraryPage(
        title: 'Online Library',
        bottom: (_) => FilledButton.icon(
            onPressed: _openPostScreen,
            icon: const Icon(AppIcons.plusBold),
            label: const Text('List a Book')),
        body: (context) => FutureBuilder<List<BookListing>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ErrorState(onRetry: () => setState(_reload));
            }
            if (!snapshot.hasData) {
              return const ShimmerListPlaceholder();
            }
            final books = snapshot.data!
                .where((book) =>
                    (_filter == null || book.listingType == _filter) &&
                    '${book.title} ${book.author} ${book.genre}'
                        .toLowerCase()
                        .contains(_query))
                .toList();
            return CustomScrollView(slivers: [
              SliverToBoxAdapter(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LibraryGlass(
                                child: Row(children: [
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text('YOUR VILLAGE BOOKSHELF',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1)),
                                    const SizedBox(height: 10),
                                    Text('A new chapter\nstarts here.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 10),
                                    Text('Borrow a story. Share a favourite.',
                                        style: TextStyle(
                                            color: context.tokens.textMuted,
                                            fontSize: 12)),
                                  ])),
                              if (MediaQuery.textScalerOf(context).scale(14) <
                                  20) ...[
                                const SizedBox(width: 12),
                                Icon(AppIcons.bookOpen,
                                    size: 58,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.7)),
                              ],
                            ])),
                            const SizedBox(height: 20),
                            TextField(
                                decoration: const InputDecoration(
                                    hintText: 'Search title, author or genre',
                                    prefixIcon: Icon(AppIcons.magnifyingGlass)),
                                onChanged: (value) => setState(
                                    () => _query = value.trim().toLowerCase())),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(children: [
                                  _chip('All', null),
                                  ...BookListingType.values
                                      .map((type) => _chip(type.label, type)),
                                ])),
                          ]))),
              if (books.isEmpty)
                SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                        icon: AppIcons.bookOpen,
                        tone: AppTone.info,
                        title: 'No matching books',
                        message:
                            'Try another title or listing type, or share a book of your own.',
                        actionLabel: 'List a Book',
                        onAction: _openPostScreen))
              else ...[
                SliverToBoxAdapter(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Fresh on the shelf',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800)))),
                SliverToBoxAdapter(
                    child: SizedBox(
                  height: 286 +
                      (MediaQuery.textScalerOf(context).scale(14) - 14) * 5,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    itemCount: books.length > 5 ? 5 : books.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return SizedBox(
                          width: 152,
                          child: LibraryGlass(
                            key: ValueKey('shelf-${book.id}'),
                            padding: const EdgeInsets.all(12),
                            onTap: () => _open(book),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                      child: LibraryBookCover(
                                          book: book, width: 92, height: 126)),
                                  const SizedBox(height: 12),
                                  Text(book.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(book.author,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: context.tokens.textMuted,
                                          fontSize: 11)),
                                  const Spacer(),
                                  Text(book.listingType.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 11)),
                                ]),
                          ));
                    },
                  ),
                )),
                SliverToBoxAdapter(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                        child: Row(children: [
                          Expanded(
                              child: Text('Community collection',
                                  style:
                                      Theme.of(context).textTheme.titleMedium)),
                          Text('${books.length} books',
                              style: TextStyle(
                                  color: context.tokens.textMuted,
                                  fontSize: 12))
                        ]))),
                SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList.separated(
                      itemCount: books.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return LibraryGlass(
                            key: ValueKey('collection-${book.id}'),
                            onTap: () => _open(book),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (MediaQuery.textScalerOf(context)
                                          .scale(14) <
                                      20) ...[
                                    LibraryBookCover(
                                        book: book, width: 62, height: 88),
                                    const SizedBox(width: 14),
                                  ],
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(book.title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 4),
                                        Text('${book.author} · ${book.genre}',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    context.tokens.textMuted)),
                                        const SizedBox(height: 8),
                                        Text(book.listingType.label,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color:
                                                    context.tokens.textMuted)),
                                        Text(
                                            book.listingType ==
                                                    BookListingType.rent
                                                ? (book.rentPerWeek ??
                                                    'Rent price on request')
                                                : book.listingType ==
                                                        BookListingType.buy
                                                    ? 'Budget ${Formatters.currency(book.price)}'
                                                    : Formatters.currency(
                                                        book.price),
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontWeight: FontWeight.w700)),
                                      ])),
                                ]));
                      },
                    )),
              ],
            ]);
          },
        ),
      );

  Widget _chip(String label, BookListingType? type) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
          label: Text(label),
          selected: _filter == type,
          onSelected: (_) => setState(() => _filter = type)));
}
