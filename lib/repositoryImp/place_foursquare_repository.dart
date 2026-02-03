import 'package:foodaroundme/model/place_foursquare.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/foursquare_api.dart';

class PlacesFourSquareRepository {
  final FoursquareApi api;

  PlacesFourSquareRepository(this.api);

  Future<List<PlaceFoursquare>> searchNearby({
    required LatLng center,
    required int radius,
    String? categoryId,
  }) async {
    final results = await api.searchNearBy(
      lat: center.latitude,
      lng: center.longitude,
      radius: radius,
      categoryId: categoryId,
    );

    return results
        .map((json) {
      try {
        return PlaceFoursquare.fromFoursquare(json);
      } catch (_) {
        return null;
      }
    })
        .whereType<PlaceFoursquare>()
        .toList();
  }
}
