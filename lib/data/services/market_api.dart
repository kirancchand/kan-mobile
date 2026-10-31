import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../models/marketplace_listing.dart';
import '../models/media_attachment.dart';
import '../models/service_type.dart';

/// Village marketplace endpoints (`village/addProduct` and
/// `village/listProduct` in the Postman collection).
class MarketApi {
  MarketApi(
      {http.Client? client,
      this.baseUrl = ApiConfig.villageUrl,
      this.appId = ApiConfig.villageAppId})
      : _client = client ?? http.Client();
  final http.Client _client;
  final String baseUrl;
  final String appId;

  /// The backend accepts at most this many `product_images` per request.
  static const maxImages = 5;

  Future<void> addProduct({
    required String productName,
    required String productDesc,
    required double price,
    required String categoryName,
    required String location,
    MarketListingType type = MarketListingType.sell,
    String? categoryId,
    String? registeredUserId,
    List<MediaAttachment> images = const [],
  }) async {
    final photos = images.where((m) => m.kind == MediaKind.image).toList();
    if (photos.length > maxImages) {
      throw ArgumentError('Attach at most $maxImages photos.');
    }
    final request = http.MultipartRequest(
        'POST', ApiConfig.kanUri('/api/market/add', baseUrl: baseUrl));
    request.headers.addAll({'Accept': 'application/json', 'X-App-Id': appId});
    request.fields.addAll({
      if (categoryId != null) 'category_id': categoryId,
      'category_name': categoryName,
      'product_name': productName,
      'product_desc': productDesc,
      'price': price == price.truncateToDouble()
          ? price.toStringAsFixed(0)
          : '$price',
      'location': location,
      'type': type.name,
      if (registeredUserId != null) 'registered_userid': registeredUserId,
    });
    for (final photo in photos) {
      final extension = photo.name.split('.').last.toLowerCase();
      final subtype = extension == 'jpg' ? 'jpeg' : extension;
      request.files.add(http.MultipartFile.fromBytes(
          'product_images', photo.bytes,
          filename: photo.name, contentType: http.MediaType('image', subtype)));
    }
    final response = await http.Response.fromStream(
        await _client.send(request).timeout(const Duration(seconds: 30)));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Could not post listing (HTTP ${response.statusCode}).');
    }
  }

  Future<dynamic> _post(String path, Map<String, Object?> body) async {
    final response = await _client
        .post(
          ApiConfig.kanUri(path, baseUrl: baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-App-Id': appId
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Market request failed (HTTP ${response.statusCode}).');
    }
    return jsonDecode(response.body);
  }

  Future<List<Map<String, dynamic>>> _rows() async {
    final rows = <Map<String, dynamic>>[];
    final seen = <String>{};
    while (true) {
      final data = await _post('/api/market/list', {
        'start': rows.length,
        'numberofRows': 50,
        'filter': [],
        'sort': [
          {'columnName': 'market_id', 'sortOrder': 'DESC'}
        ],
      });
      if (data is! Map || data['result'] is! List) {
        throw const FormatException('Expected product list.');
      }
      final total = int.tryParse('${data['totalCount']}');
      if (total == null || total < 0) {
        throw const FormatException('Invalid product count.');
      }
      final page = data['result'] as List;
      for (final row in page) {
        if (row is! Map<String, dynamic> ||
            row['market_id'] == null ||
            !seen.add('${row['market_id']}')) {
          throw const FormatException('Invalid or repeated product.');
        }
        rows.add(row);
      }
      if (rows.length >= total) return rows;
      if (page.isEmpty) {
        throw const FormatException('Incomplete product list.');
      }
    }
  }

  /// `images` arrives as a Postgres array literal (`{"14","15"}`) or a list.
  static List<String> _imageIds(Object? value) {
    if (value is List) return value.map((id) => '$id').toList();
    if (value is! String) return const [];
    return RegExp(r'\d+').allMatches(value).map((m) => m[0]!).toList();
  }

  String _image(Object? value) {
    if (value is! String || value.trim().isEmpty) return '';
    final base = Uri.parse(baseUrl);
    var uri = base.resolve(value.trim());
    if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
      uri = uri.replace(scheme: base.scheme, host: base.host, port: base.port);
    }
    return ['http', 'https'].contains(uri.scheme) ? uri.toString() : '';
  }

  /// A missing or failed photo should not hide the listing itself.
  Future<String> _imageUrl(String imageId) async {
    try {
      final data =
          await _post('/api/market/get_product_images', {'image_id': imageId});
      return data is Map ? _image(data['market_image']) : '';
    } catch (_) {
      return '';
    }
  }

  Future<List<MarketplaceListing>> listProducts() async {
    final rows = await _rows();
    final images = await Future.wait(rows.map((row) async =>
        (await Future.wait(_imageIds(row['images']).map(_imageUrl)))
            .where((url) => url.isNotEmpty)
            .toList()));
    const type = ServiceType.buySell;
    return [
      for (final (index, row) in rows.indexed)
        MarketplaceListing(
          id: 'market_${row['market_id']}',
          serviceType: type,
          title: '${row['product_name'] ?? ''}'.trim(),
          description: '${row['product_desc'] ?? ''}'.trim(),
          price: double.tryParse('${row['price']}') ?? 0,
          category: '${row['category_name'] ?? ''}'.trim().isEmpty
              ? 'Other'
              : '${row['category_name']}'.trim(),
          sellerId: row['registered_userid']?.toString(),
          listingType: MarketListingType.parse(row['type']),
          sellerName: 'Village seller',
          sellerPhone: '',
          location: '${row['location'] ?? ''}'.trim(),
          postedAt: DateTime.tryParse('${row['created_at']}') ??
              DateTime.fromMillisecondsSinceEpoch(0),
          imageUrls: List.unmodifiable(images[index]),
          icon: type.icon,
          color: type.color,
        ),
    ];
  }

  void dispose() => _client.close();
}
