

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodaroundme/model/place.dart';
import 'package:foodaroundme/repository/PlacesRepository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FoursquareRepoImpl  implements PlacesRepository{

  final Dio _dio;

  FoursquareRepoImpl(String apiKey)
  : _dio = Dio(BaseOptions(
      baseUrl: 'https://places-api.foursquare.com',
      headers: {
        'Accept': 'application/json',
        'Authorization': apiKey,
      },
    ));



  @override
  Future<List<Place>> getNearbyPlaces({
    required LatLng center,
    required int radius,
    required String category, // optional
  }) async {
    final response = await _dio.get(
      '/places/search',
      queryParameters: {
        'll': '40.7128,-74.0060', // NYC
        'radius': 500,
        'fsq_category_ids': '4d4b7105d754a06374d81259',
        'limit': 5,
      },
    );

    debugPrint('FSQ TEST RESULTS: ${response.data}');


    final List results = response.data['results'];

    return results.map((r) {
      return Place(
        id: r['fsq_id'],
        name: r['name'],
        address: r['location']['formatted_address'] ?? '',
        location: LatLng(
          r['geocodes']['main']['latitude'],
          r['geocodes']['main']['longitude'],
        ),
        categories: (r['categories'] as List)
            .map((c) => c['name'] as String)
            .toList(),
      );
    }).toList();
  }


  @override
  Future<Place?> getPlaceDetails(String placeId) {
    // TODO: implement getPlaceDetails
    throw UnimplementedError();
  }

  @override
  Future<List<Place>> searchPlaces({required String query, required String category, LatLng? center, int radius = 500}) {
    // TODO: implement searchPlaces
    throw UnimplementedError();
  }



  @override
  Future<Place?> getCacheDetails(String placeId) {
    // TODO: implement getCacheDetails
    throw UnimplementedError();
  }

}
