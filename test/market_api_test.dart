import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mv_app/data/models/marketplace_listing.dart';
import 'package:mv_app/data/models/media_attachment.dart';
import 'package:mv_app/data/models/service_type.dart';
import 'package:mv_app/data/repositories/marketplace_repository.dart';
import 'package:mv_app/data/services/market_api.dart';

MediaAttachment photo(String name) => MediaAttachment(
    name: name, kind: MediaKind.image, bytes: Uint8List.fromList([1, 2, 3]));

void main() {
  test('Buy & Sell post sends the addProduct multipart request', () async {
    late http.Request sent;
    final api = MarketApi(
        baseUrl: 'http://village.test',
        client: MockClient((request) async {
          sent = request;
          return http.Response(jsonEncode('Inserted Successfully'), 200);
        }));
    final repository = MarketplaceRepository(marketApi: api);
    addTearDown(repository.dispose);

    await repository.createListing(
      type: ServiceType.buySell,
      title: 'pd1',
      description: 'pd1 desc',
      price: 1000,
      category: 'vehicle',
      condition: ListingCondition.good,
      sellerId: '7',
      sellerName: 'Seller',
      sellerPhone: '',
      location: 'tvm',
      attachments: [photo('a.jpg'), photo('b.png')],
    );

    expect(sent.method, 'POST');
    expect(sent.url.toString(), 'http://village.test/api/market/add');
    expect(sent.headers['X-App-Id'], '1');
    expect(sent.headers['content-type'], startsWith('multipart/form-data'));
    final body = latin1.decode(sent.bodyBytes);
    for (final field in {
      'category_name': 'vehicle',
      'product_name': 'pd1',
      'product_desc': 'pd1 desc',
      'price': '1000',
      'location': 'tvm',
      'type': 'sell',
      'registered_userid': '7',
    }.entries) {
      expect(body, contains('name="${field.key}"\r\n\r\n${field.value}\r\n'));
    }
    expect('name="product_images"'.allMatches(body), hasLength(2));
    expect(body, contains('content-type: image/jpeg'));
  });

  test('Buy & Sell list reads listProduct pages and resolves photos', () async {
    final listBodies = <Map<String, dynamic>>[];
    final rows = [
      {
        'market_id': '17',
        'category_name': 'Vehicles',
        'product_name': 'Scooter',
        'product_desc': 'Runs well',
        'images': '{"19","20"}',
        'price': 433,
        'location': 'tvm',
        'type': 'Sell',
        'registered_userid': '5',
      },
      {
        'market_id': '14',
        'category_name': null,
        'product_name': 'Chair',
        'product_desc': '',
        'images': '{}',
        'price': '654',
        'location': null,
        'type': 'buy',
        'registered_userid': null,
      },
    ];
    final repository = MarketplaceRepository(
        marketApi: MarketApi(
            baseUrl: 'http://10.0.2.2:5001',
            client: MockClient((request) async {
              expect(request.headers['X-App-Id'], '1');
              final body = jsonDecode(request.body) as Map<String, dynamic>;
              if (request.url.path == '/api/market/list') {
                listBodies.add(body);
                final start = body['start'] as int;
                return http.Response(
                    jsonEncode({
                      'totalCount': rows.length,
                      'result': rows.skip(start).take(1).toList(),
                    }),
                    200);
              }
              expect(request.url.path, '/api/market/get_product_images');
              if (body['image_id'] == '20') return http.Response('{}', 500);
              return http.Response(
                  jsonEncode({
                    'market_image_id': body['image_id'],
                    'market_image':
                        'http://localhost:5001/uploads/${body['image_id']}.png',
                  }),
                  200);
            })));
    addTearDown(repository.dispose);

    final listings = await repository.getListings(ServiceType.buySell);

    expect(listBodies.map((b) => b['start']), [0, 1]);
    expect(listings.map((l) => l.id), ['market_17', 'market_14']);
    final scooter = listings.first;
    expect(scooter.title, 'Scooter');
    expect(scooter.price, 433);
    expect(scooter.category, 'Vehicles');
    expect(scooter.sellerId, '5');
    expect(scooter.condition, isNull);
    expect(scooter.listingType, MarketListingType.sell);
    expect(listings.last.listingType, MarketListingType.buy);
    expect(scooter.hasPostedDate, isFalse);
    expect(scooter.imageUrls, ['http://10.0.2.2:5001/uploads/19.png']);
    expect(listings.last.category, 'Other');
    expect(listings.last.price, 654);
    expect(listings.last.imageUrls, isEmpty);
  });

  test('Buy & Sell list surfaces listProduct failures', () async {
    final repository = MarketplaceRepository(
        marketApi: MarketApi(
            baseUrl: 'http://village.test',
            client: MockClient((_) async => http.Response('{}', 500))));
    addTearDown(repository.dispose);
    await expectLater(
        repository.getListings(ServiceType.buySell), throwsStateError);
  });

  test('failed addProduct does not add a local listing', () async {
    final repository = MarketplaceRepository(
        marketApi: MarketApi(
            baseUrl: 'http://village.test',
            client: MockClient((_) async => http.Response('{}', 500))));
    addTearDown(repository.dispose);
    var changes = 0;
    repository.changes.addListener(() => changes++);

    await expectLater(
        repository.createListing(
          type: ServiceType.buySell,
          title: 'x',
          description: 'x',
          price: 1,
          category: 'x',
          condition: ListingCondition.good,
          sellerName: 'x',
          sellerPhone: '',
          location: 'x',
        ),
        throwsStateError);
    expect(changes, 0);
  });
}
