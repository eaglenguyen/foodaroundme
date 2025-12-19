import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodaroundme/resources/place_filter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
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

  // fetch restaurant api
  late GooglePlace _places;
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
    const apiKey = String.fromEnvironment("GOOGLE_MAPS_API_KEY");
    _places = GooglePlace(apiKey);
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
      Location(lat: center.latitude, lng: center.longitude),
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

  // Restaurant detailScreen
/*  Future<void> openTikTok(String restaurantName) async {
    final query = Uri.encodeComponent(restaurantName);
    final url = 'https://www.tiktok.com/tag/$query';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open TikTok';
    }
  }

  Future<void> openInstagramTag(String tag) async {
    final encodedTag = Uri.encodeComponent(tag);
    final url = 'https://www.instagram.com/explore/tags/$encodedTag/';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open Instagram tag';
    }
  }*/



}
