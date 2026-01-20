import 'dart:convert';

import 'package:http/http.dart' as http;

class FoursquareApi {
  static const _baseUrl = 'https://api.foursquare.com/v3/places/search';
  final String apiKey;

  FoursquareApi({required this.apiKey});

  Future<List<Map< String, dynamic>>> searchNearBy({
    required double lat,
    required double lng,
    required int radius,
    String? category,
}) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'll': '$lat,$lng',
        'radius': radius.toString(),
        'limit': '50',
        if (category != null) 'categories': category,
      },
    );
    final response = await http.get(
      uri,
        headers: {
        'Accept': 'application/json',
        'Authorization': apiKey,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Foursquare error: ${response.body}');
  }

    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);

}
}

