import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as gmw;
import 'package:google_place/google_place.dart' as gp;
import 'package:http/http.dart' as http;
import '../model/place.dart';



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
    required int radius,
    required String type,
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

  // Api call to fetch places by name
  Future<List<Place>> searchPlacesByName({
    required String query,
    String? type,
    LatLng? center,
    int radius = 500,
  }) async {

    final effectiveQuery = type != null ? '$query $type' : query;

    final result = await _places.search.getTextSearch(
      effectiveQuery,
      location: center != null
          ? gp.Location(
        lat: center.latitude,
        lng: center.longitude,
      )
          : null,
      radius: center != null ? radius : null,

    );

    if (result == null || result.results == null) return [];

    return result.results!
        .map((pr) => Place.fromSearchResult(pr))
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


}