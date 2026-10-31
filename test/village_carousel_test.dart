import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mv_app/core/widgets/village_carousel.dart';
import 'package:mv_app/data/services/village_carousel_api.dart';

void main() {
  test('Posts app header, sorts mobile images and resolves image host',
      () async {
    final api = VillageCarouselApi(
      baseUrl: 'http://10.0.2.2:5001',
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/carousel/getVillageMobCarousel');
        expect(request.headers['X-App-Id'], '1');
        expect(jsonDecode(request.body), isEmpty);
        return http.Response(
            jsonEncode([
              {'carousel_image': '/uploads/b.png', 'carousel_position': 2},
              {
                'carousel_image': 'http://localhost:5001/uploads/a.png',
                'carousel_position': 1,
                'carousel_name': 'Nature'
              },
              {'carousel_image': '/uploads/hidden.png', 'isenabled': false},
            ]),
            200);
      }),
    );
    addTearDown(api.dispose);
    final items = await api.fetch();
    expect(items.length, 2);
    expect(items.first.name, 'Nature');
    expect(items.first.imageUrl, 'http://10.0.2.2:5001/uploads/a.png');
  });

  testWidgets('Failed carousel can retry to an empty state', (tester) async {
    var calls = 0;
    final api = VillageCarouselApi(
        client: MockClient((_) async =>
            ++calls == 1 ? http.Response('', 503) : http.Response('[]', 200)));
    addTearDown(api.dispose);
    await tester.pumpWidget(MaterialApp(home: VillageCarousel(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('Retry village images'), findsOneWidget);
    await tester.tap(find.text('Retry village images'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.byType(PageView), findsNothing);
    expect(find.text('Retry village images'), findsNothing);
  });
}
