import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodaroundme/resources/place_filter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as gmw;
import 'package:google_place/google_place.dart' as gp;
import '../model/place.dart';
import '../service/locationService.dart';

class MapViewModel extends ChangeNotifier {


  // current layout is state variables -> methods/functions
  // state (in android) is value that changes over time
  final LocationService _locationService = LocationService();
  bool isLoading = false;
  LatLng center = const LatLng(42.3104, -71.0575);
  List<bool> selectedButtons = [true, false, false];
  GoogleMapController? mapController;
  static const apiKey = String.fromEnvironment("GOOGLE_MAPS_API_KEY");

  // fetch restaurant api
  late gp.GooglePlace _places;
  final placesApi = gmw.GoogleMapsPlaces(apiKey: apiKey);

  Set<Marker> markers = {};

  //
  List<Place> allPlaces = [];
  List<Place> filteredPlaces = [];

  Timer? _debounce;



  // init block via flutter
  MapViewModel() {
    initPlaces();
  }

  void initPlaces() {
    _places = gp.GooglePlace(apiKey);
  }

  // --- Convert Places p into markers and notify UI ---
  void updateMarkers() {
    markers = filteredPlaces.map(
            (p) {
          return Marker(
            markerId: MarkerId(p.name),
            position: p.location,
            infoWindow: InfoWindow(title: p.name),
          );
        }).toSet();

    notifyListeners();
  }

  // Api call to fetch nearby restaurants
  Future<void> loadNearbyRestaurants(String filter) async {
    final result = await _places.search.getNearBySearch(
      gp.Location(lat: center.latitude, lng: center.longitude),
      800, // radius meters, half a mile
      type: filter,
    );

    if (result == null || result.results == null) return;



    // Convert all API results → Place models
    allPlaces = result.results!
        .map( (pr) => Place.fromSearchResult(pr) )
        .whereType<Place>()
        .toList();

    // default: show all restaurants
    filteredPlaces = List.from(allPlaces);

    // convert filteredPlaces → markers
    updateMarkers();


  }

  Future<gmw.PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final response = await placesApi.getDetailsByPlaceId(
        placeId,
        fields: [
          'place_id',
          'name',
          'formatted_address',
          'website',
          'formatted_phone_number',
          'url',
        ],
      );

      if (!response.isOkay) {
        debugPrint('PlaceDetails error: ${response.errorMessage}');
        return null;
      }

      return response.result;
    } catch (e) {
      debugPrint('PlaceDetails exception: $e');
      return null;
    }
  }

  void filterBySearchQuery(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        filteredPlaces = List.from(allPlaces);
      } else {

        final q = query.toLowerCase();
        filteredPlaces = allPlaces.where((place) {
          return place.name.toLowerCase().contains(q);
        }).toList();
      }
      notifyListeners();
    });
  }


  void toggleButton(int index) {
    for (int i = 0; i < selectedButtons.length; i++) {
      selectedButtons[i] = i == index;
    }
    notifyListeners();
  }

  Future<void> applyFilter(PlaceFilter filter) async {
    switch(filter) {
      case PlaceFilter.restaurant:
        await loadNearbyRestaurants("restaurant");
        break;
      case PlaceFilter.cafe:
        await loadNearbyRestaurants("cafe");
        break;
      case PlaceFilter.bar:
        await loadNearbyRestaurants("bar");
        break;
      case PlaceFilter.popular:
        await loadNearbyRestaurants("popular");
        break;
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    isLoading = true;
    notifyListeners();

    final position = await _locationService.getCurrentPosition();
    if (position == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    center = LatLng(position.latitude, position.longitude);
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: center, zoom: 15)),
    );

    isLoading = false;
    notifyListeners();
  }


}
