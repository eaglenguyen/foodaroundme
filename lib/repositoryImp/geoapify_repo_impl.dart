import 'package:dio/dio.dart';
import 'package:foodaroundme/model/place.dart';
import 'package:foodaroundme/repository/PlacesRepository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeoapifyRepoImpl implements PlacesRepository{

  final Dio dio;
  final String apiKey;

  GeoapifyRepoImpl(this.apiKey)
      : dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.geoapify.com/v2',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  @override
  Future<List<Place>> getNearbyPlaces({required LatLng center, required int radius, required String category,}) async {
    // TODO: implement getNearbyPlaces
    final response = await dio.get(
      '/places',
      queryParameters: {
        'categories': category,
        'filter': 'circle:${center.longitude},${center.latitude},$radius',
        'limit': 20,
        'apiKey': apiKey,
      },
    );

    final features = response.data['features'] as List;

    return features.map((json) {
      final props = json['properties'];

      return Place(
        id: props['place_id'],
        name: props['name'] ?? 'Unnamed',
        address: props['formatted'] ?? '',
        location: LatLng(
          props['lat'],
          props['lon'],
        ), categories: [],
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

}

class GeoapifyCategories {
  static const restaurant = 'catering.restaurant';
  static const cafe = 'catering.cafe';
  static const bar = 'catering.bar';
  static const fastFood = 'catering.fast_food';
}