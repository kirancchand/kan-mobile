import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../models/advertisement.dart';
import '../models/village_event.dart';

class AdvertisementType {
  const AdvertisementType({required this.id, required this.label});
  final String id;
  final String label;
}

class AdvertisementFeed {
  const AdvertisementFeed(
      {required this.events, required this.ads, required this.types});
  final List<VillageEvent> events;
  final List<Advertisement> ads;
  final List<AdvertisementType> types;
}

class AdvertisementsApi {
  AdvertisementsApi(
      {http.Client? client,
      this.baseUrl = ApiConfig.villageUrl,
      this.appId = ApiConfig.villageAppId})
      : _client = client ?? http.Client();
  final http.Client _client;
  final String baseUrl;
  final String appId;

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
      throw StateError(
          'Advertisements request failed (HTTP ${response.statusCode}).');
    }
    return jsonDecode(response.body);
  }

  Future<List<AdvertisementType>> _types() async {
    final data =
        await _post('/api/keyValue', {'requestName': 'getAll_AdvType'});
    if (data is! List) {
      throw const FormatException('Expected advertisement types.');
    }
    return data.map((row) {
      if (row is! Map ||
          row['value'] == null ||
          row['label'] is! String ||
          (row['label'] as String).trim().isEmpty) {
        throw const FormatException('Invalid advertisement type.');
      }
      return AdvertisementType(
          id: row['value'].toString(), label: (row['label'] as String).trim());
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _rows() async {
    final villageId = int.tryParse(appId);
    if (villageId == null) {
      throw const FormatException('Invalid village app ID.');
    }
    final rows = <Map<String, dynamic>>[];
    final seen = <String>{};
    while (true) {
      final data = await _post('/api/advertisements/list', {
        'start': rows.length,
        'numberofRows': 50,
        'filter': [
          {'columnName': 'f_villageapp_id', 'value': villageId}
        ],
        'sort': [
          {'columnName': 'villageadvertisement_id', 'sortOrder': 'DESC'}
        ],
      });
      if (data is! Map || data['result'] is! List) {
        throw const FormatException('Expected advertisement list.');
      }
      final total = int.tryParse('${data['totalCount']}');
      if (total == null || total < 0) {
        throw const FormatException('Invalid advertisement count.');
      }
      final page = data['result'] as List;
      for (final row in page) {
        if (row is! Map<String, dynamic> ||
            row['villageadvertisement_id'] == null ||
            !seen.add('${row['villageadvertisement_id']}')) {
          throw const FormatException('Invalid or repeated advertisement.');
        }
        rows.add(row);
      }
      if (rows.length >= total) return rows;
      if (page.isEmpty) {
        throw const FormatException('Incomplete advertisement list.');
      }
    }
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

  Future<AdvertisementFeed> fetch() async {
    final results = await Future.wait<Object>([_rows(), _types()]);
    final rows = results[0] as List<Map<String, dynamic>>;
    final types = results[1] as List<AdvertisementType>;
    final labels = {for (final type in types) type.id: type.label};
    final events = <VillageEvent>[];
    final ads = <Advertisement>[];
    for (final row in rows) {
      final rawType = row['adv_type'];
      final typeId =
          '${row['f_adv_type_id'] ?? (rawType is Map ? rawType['value'] : '')}';
      final typeLabel =
          (rawType is Map ? rawType['label'] : rawType)?.toString().trim();
      final label = typeLabel?.isNotEmpty == true
          ? typeLabel!
          : labels[typeId] ?? 'Uncategorised';
      final id = '${row['villageadvertisement_id']}';
      final name = '${row['advertisement_name'] ?? ''}'.trim();
      if (name.isEmpty) {
        throw const FormatException('Advertisement name is missing.');
      }
      final description = '${row['advertisement_desc'] ?? ''}'.trim();
      final organisation = '${row['organisation_name'] ?? ''}'.trim();
      final image = _image(row['advertisement_image']);
      events.add(VillageEvent(
        id: id,
        title: name,
        description: description,
        category: label.toLowerCase() == 'event'
            ? EventCategory.event
            : label.toLowerCase() == 'announcement'
                ? EventCategory.announcement
                : EventCategory.update,
        dateTime: DateTime.tryParse('${row['start_date'] ?? ''}'),
        location: organisation,
        typeId: typeId,
        typeLabel: label,
        imageUrl: image,
      ));
      if (label.toLowerCase() == 'advertisment' ||
          label.toLowerCase() == 'advertisement') {
        ads.add(Advertisement(
            id: id,
            title: name,
            subtitle: description,
            sponsor: organisation,
            color: Colors.blue,
            icon: Icons.campaign_outlined,
            imageUrl: image));
      }
    }
    return AdvertisementFeed(events: events, ads: ads, types: types);
  }

  void dispose() => _client.close();
}
