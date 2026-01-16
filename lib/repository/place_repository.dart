import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as gmw;
import 'package:google_place/google_place.dart' as gp;
import 'package:http/http.dart' as http;
import '../model/place.dart';
import '../model/places_new_v1.dart';
import '../viewmodel/mapViewModel.dart';



class PlacesRepository {
  final gp.GooglePlace _places;
  final gmw.GoogleMapsPlaces _detailsApi;


  // Constructor
  PlacesRepository({
    required String apiKey,
  })  : _places = gp.GooglePlace(apiKey),
        _detailsApi = gmw.GoogleMapsPlaces(apiKey: apiKey);

  // Api call to fetch nearby restaurants
  Future<List<Place>> getNearbyPlaces({
    required LatLng center,
    required String type,
    required int radius,
  }) async {
  final result = await _places.search.getNearBySearch(
    gp.Location (
      lat: center.latitude,
      lng: center.longitude,
  ),
      radius.toInt(),
      type: type,
  );

  if (result == null || result.results == null) return [];

  return result.results! // Convert API results to Place models
      .map( (pr) => Place.fromSearchResult(pr) )
      .whereType<Place>()
      .toList();
  }

  // Api call to fetch place detail info
  Future<gmw.PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final response = await _detailsApi.getDetailsByPlaceId(
        placeId,
        fields: [
          'place_id',
          'name',
          'formatted_address',
          'website',
          'formatted_phone_number',
          'url',
          'photos'
        ],
      );
      if (!response.isOkay) return null;

      return response.result;
    } catch (_) {
      return null;
    }
  }

  // REST Api call for getting Place Types (New). Needed for food cuisine types
  static const _baseUrl = 'https://places.googleapis.com/v1/places';

  Future<PlaceDetailsV1?> getPlaceDetailsV1 (String placeId) async {
    final uri = Uri.parse('$_baseUrl/$placeId');

    final response = await http.get(
      uri,
      headers: {
        'X-Goog-Api-Key': MapViewModel.apiKey,
        'X-Goog-FieldMask': 'types',
      },
    );

    if (response.statusCode != 200) {
      debugPrint('Error getting placeV1 details: ${response.body}');
      return null;
    }

    final json = jsonDecode(response.body);
    return PlaceDetailsV1.fromJson(json);
        }
}