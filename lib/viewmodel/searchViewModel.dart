import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/place.dart';
import '../repository/place_repository.dart';

class SearchViewModel extends ChangeNotifier {
  final PlacesRepository placesRepository;

  SearchViewModel({
    required this.placesRepository,
  }) {    // init block via flutter
  }

  List<Place> oldPlaces = [];
  List<Place> newPlaces = [];
  LatLng cameraCenter = const LatLng(42.3104, -71.0575);
  Timer? _debounce;



  static const double searchRadius = 800;


  Future<void> fetchPlacesByTextSearch(String query) async {
    final places = await placesRepository.searchPlacesByName(
        center: cameraCenter,
        radius: searchRadius.toInt(),
        query: query
    );

        oldPlaces = places;
        newPlaces = List.from(places);

        notifyListeners();
  }

  void filterPlacesLocally(String query) { // Should be in separate VM class
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        newPlaces;
      } else {
        final q = query.toLowerCase();
        newPlaces = oldPlaces.where((place) {
          return place.name.toLowerCase().contains(q);
        }
        ).toList();
      }
      notifyListeners();
    });
  }

  Future<void> searchPlaces(String query) async {
    // If query is short, don't hit the API
    if (query.trim().length < 2) {
      newPlaces = oldPlaces;
      notifyListeners();
      return;
    }

    await fetchPlacesByTextSearch(query);
  }

}