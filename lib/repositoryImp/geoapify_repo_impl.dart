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
      connectTimeout: const Duration(seconds: 10), // Maximum time allowed to establish a connection to the server.
      receiveTimeout: const Duration(seconds: 10), // Maximum time to wait for data after the connection is established.
    ),
  );

  // async = this will take time, WAIT
  // await = pause here until its done, does not freeze app. Can still render UI, handle taps, animate maps
  @override
  Future<List<Place>> getNearbyPlaces({required LatLng center, required int radius, required String category,}) async {
    final response = await dio.get(
      '/places',
      queryParameters: {
        'categories': category,
        'filter': 'circle:${center.longitude},${center.latitude},$radius',
        'limit': 20,
        'apiKey': apiKey,
      },
    );

    // Error handling
    if (response.statusCode != 200) {
      return [];
    }

    final data = response.data;
    if (data == null || data['features'] == null) {
      return [];
    }


    final features = data['features'] as List;

    return features.map((json) {
      final props = json['properties'];

      return Place(
        id: props['place_id'],
        name: props['name'] ?? 'Unnamed',
        address: props['formatted'] ?? '',
        location: LatLng(
          props['lat'],
          props['lon'],
        ),

        categories: (props['categories'] as List?)?.cast<String>() ?? [],
      );
    }).toList();
  }

  @override
  Future<Place?> getPlaceDetails(String placeId) async {
    final response = await dio.get(
      '/place-details',
      queryParameters: {
        'id': placeId,
        'apiKey': apiKey,
      },
    );

    final features = response.data['features'] as List?;
    if (features == null || features.isEmpty) return null;

    final props = features.first['properties'];

    return Place(
      id: props['place_id'],
      name: props['name'] ?? 'Unnamed',
      address: props['formatted'] ?? '',
      location: LatLng(
        props['lat'],
        props['lon'],
      ),
      categories: (props['categories'] as List?)?.cast<String>() ?? [],
      cuisine: props['cuisine'] ?? 'Food',
      website: props['website'] ?? '',
      phone: props['contact']['phone'] ?? '',
    );

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

