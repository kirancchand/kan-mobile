import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../models/village_carousel_item.dart';

class VillageCarouselApi {
  VillageCarouselApi(
      {http.Client? client,
      this.baseUrl = ApiConfig.villageUrl,
      this.appId = ApiConfig.villageAppId})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final String appId;

  Future<List<VillageCarouselItem>> fetch() async {
    final response = await _client
        .post(
          ApiConfig.kanUri('/api/carousel/getVillageMobCarousel',
              baseUrl: baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-App-Id': appId
          },
          body: '{}',
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Carousel request failed.');
    }
    final rows = jsonDecode(response.body);
    if (rows is! List) {
      throw const FormatException('Expected a carousel list.');
    }
    final items = rows
        .cast<Map<String, dynamic>>()
        .where((row) => row['isenabled'] != false && row['ismobile'] != false)
        .map((row) => VillageCarouselItem.fromJson(row, Uri.parse(baseUrl)))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    return items;
  }

  void dispose() => _client.close();
}
