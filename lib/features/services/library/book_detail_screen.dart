import '../../../core/widgets/purchase_actions.dart';
import '../../../data/models/cart_item.dart';
import '../../../core/widgets/media_gallery.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/contact_actions.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/book_listing.dart';
import 'library_book_cover.dart';
import 'library_theme.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.book});
  final BookListing book;

  @override
  Widget build(BuildContext context) => LibraryPage(
        title: 'Book Details',
        bottom: (context) => book.listingType == BookListingType.sell
            ? PurchaseActions(
                item: CartItem.book(book),
                contact: TextButton.icon(
                    icon: const Icon(AppIcons.phoneCallBold),
                    label: const Text('Contact Owner'),
                    onPressed: () => showCallSheet(context,
                        name: book.ownerName, phone: book.ownerPhone)))
            : FilledButton.icon(
                icon: const Icon(AppIcons.phoneCallBold),
                label: Text(book.listingType == BookListingType.rent
                    ? 'Contact Owner to Rent'
                    : book.listingType == BookListingType.buy
                        ? 'Contact Buyer'
                        : 'Contact Owner'),
                onPressed: () => showCallSheet(context,
                    name: book.ownerName, phone: book.ownerPhone),
              ),
        body: (context) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            children: [
              MediaGallery(attachments: book.attachments),
              LibraryGlass(
                  child: Column(children: [
                const SizedBox(height: 8),
                if (book.attachments.isEmpty)
                  LibraryBookCover(book: book, width: 158, height: 218),
                const SizedBox(height: 22),
                Text(book.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('by ${book.author}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.tokens.textMuted)),
                const SizedBox(height: 16),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      StatusChip(
                          label: book.listingType.label, tone: AppTone.info),
                      StatusChip(label: book.genre)
                    ]),
                const SizedBox(height: 16),
                Text(
                    book.listingType == BookListingType.rent
                        ? (book.rentPerWeek ?? 'Rent price on request')
                        : book.listingType == BookListingType.buy
                            ? 'Budget ${Formatters.currency(book.price)}'
                            : Formatters.currency(book.price),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary)),
              ])),
              const SizedBox(height: 18),
              LibraryGlass(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                        book.listingType == BookListingType.buy
                            ? 'Looking for this book'
                            : 'Meet the book owner',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 14),
                    Row(children: [
                      const Icon(AppIcons.user),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(book.ownerName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)))
                    ]),
                    const SizedBox(height: 8),
                    Text('Posted ${Formatters.relative(book.postedAt)}',
                        style: TextStyle(
                            color: context.tokens.textMuted, fontSize: 12)),
                    const SizedBox(height: 14),
                    Text(
                        book.listingType == BookListingType.buy
                            ? 'Have a copy? Contact the buyer to discuss its condition and handover.'
                            : 'Contact the owner to arrange availability and handover.',
                        style: const TextStyle(height: 1.5)),
                  ])),
            ]),
      );
}
