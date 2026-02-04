import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/place.dart';

// Interface
abstract class PlacesRepository {

  Future<List<Place>> getNearbyPlaces({
    required LatLng center,
    required int radius,
    required String category,
});

  Future<List<Place>> searchPlaces({
    required String query,
    required String category,
    LatLng? center,
    int radius = 500,
});

  Future<Place?> getPlaceDetails(String placeId);

}