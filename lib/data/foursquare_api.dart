import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FoursquareApi {
  static const _baseUrl = 'https://places-api.foursquare.com/places/search';
  final String apiKey;

  FoursquareApi({required this.apiKey});

  Future<List<Map< String, dynamic>>> searchNearBy({
    required double lat,
    required double lng,
    required int radius,
    String? categoryId,
}) async {

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'll': '$lat,$lng',
        'radius': radius.toString(),
        'limit': '25',
        if (categoryId != null) 'fsq_category_ids': categoryId,
      },
    );
    final response = await http.get(
      uri,
        headers: {
          'authorization': 'Bearer $apiKey',
          'X-Places-Api-Version': '2025-06-17',
          'accept': 'application/json',
      },
    );
    debugPrint('FSQ status: ${response.statusCode}');
    debugPrint('FSQ body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Foursquare error: ${response.body}');
  }

    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);

}
}

