import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodaroundme/domain/search_intent_resolver.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../local/app_database.dart' as d;
import '../model/place.dart';
import '../repository/PlacesRepository.dart';


class GeoapifyRepoImpl implements PlacesRepository{

  final Dio dio;
  final String apiKey;
  final d.AppDatabase db;

  GeoapifyRepoImpl(this.apiKey, this.db)
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

    debugPrint('🔵 Fetching places from API');

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


    final places =  features.map((json) {
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

    return places;
  }

  @override
  Future<Place?> getPlaceDetails(String placeId) async {

    final cached = await db.getCachedDetails(placeId);

    if (cached != null) {
      debugPrint('🟢 Place details from CACHE');
      return cached;
    }

    debugPrint('🔵 Place details from API');

    final response = await dio.get(
      '/place-details',
      queryParameters: {
        'id': placeId,
        'apiKey': apiKey,
      },
    );

    final features = response.data['features'] as List?;
    if (features == null || features.isEmpty) return null;

    // Returns a dynamic
    final props = features.first['properties'];
    final cuisineTags = parseCuisine(props['catering']?['cuisine']);

    // converts dynamic to Place
    final place =  Place(
      id: props['place_id'],
      name: props['name'] ?? 'Unnamed',
      address: props['formatted'] ?? '',
      location: LatLng(
        props['lat'],
        props['lon'],
      ),
      categories: (props['categories'] as List?)?.cast<String>() ?? [],
      website: props['website'] ?? '',
      phone: props['contact']?['phone'] ?? '',
      openingHours: props['opening_hours'] ?? '',

      // “Try to get phone from contact.
      // If contact doesn’t exist, stop and return null.
      // If the result is still null, use an empty string instead.”
    );

    db.upsertPlaceDetails(place);

    return place;
  }


  @override
  Future<List<Place>> searchPlaces({required String query, LatLng? center, int radius = 500}) async {
    final category = SearchIntentResolver.resolveCategory(query) ?? GeoapifyCategories.restaurant;

    return getNearbyPlaces(
        center: center ?? LatLng(0, 0),
        radius: radius,
        category: category
    );


  }


}

class GeoapifyCategories {
  static const restaurant = 'catering.restaurant';
  static const cafe = 'catering.cafe';
  static const dessert = 'catering.cafe.dessert';
  static const bar = 'catering.bar';

  static const fastFood = 'catering.fast_food';
}

List<String> parseCuisine(dynamic value) {
  if (value == null) return const [];

  // If API ever returns list
  if (value is List) {
    return value
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // Most common: "burger" or "vietnamese;dessert"
  final s = value.toString().trim();
  if (s.isEmpty) return const [];

  return s
      .split(';')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}