import 'package:foodaroundme/model/place_foursquare.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/foursquare_api.dart';

class PlacesFourSquareRepository {
  final FoursquareApi api;

  PlacesFourSquareRepository(this.api);

  Future<List<PlaceFoursquare>> searchNearby({
    required LatLng center,
    required int radius,
    String? category,
  }) async {
    final results = await api.searchNearBy(
      lat: center.latitude,
      lng: center.longitude,
      radius: radius,
      category: category,
    );

    return results
        .map((json) => PlaceFoursquare.fromFoursquare(json))
        .toList();
  }
}
