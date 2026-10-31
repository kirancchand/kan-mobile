import '../models/map_location.dart';
import '../models/media_attachment.dart';
import 'package:flutter/foundation.dart';
import '../models/book_listing.dart';

class BookRepository {
  BookRepository({Iterable<BookListing> initialItems = const []})
      : _books = List.of(initialItems);
  final _changes = ValueNotifier<int>(0);
  Listenable get changes => _changes;
  void dispose() => _changes.dispose();

  final List<BookListing> _books;

  Future<List<BookListing>> getBooks() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [..._books]..sort((a, b) => b.postedAt.compareTo(a.postedAt));
  }

  Future<BookListing> addBook({
    required String title,
    String? locationId,
    MapLocation? pickupPoint,
    String? ownerId,
    required String author,
    required BookListingType listingType,
    required double price,
    String? rentPerWeek,
    required String ownerName,
    required String ownerPhone,
    required String genre,
    List<MediaAttachment> attachments = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final book = BookListing(
      attachments: List.unmodifiable(attachments),
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      locationId: locationId,
      pickupPoint: pickupPoint,
      ownerId: ownerId,
      author: author,
      listingType: listingType,
      price: price,
      rentPerWeek: rentPerWeek,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      genre: genre,
      postedAt: DateTime.now(),
    );
    _books.insert(0, book);
    _changes.value++;
    return book;
  }
}
