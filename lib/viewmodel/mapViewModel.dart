import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodaroundme/repositoryImp/geoapify_repo_impl.dart';
import 'package:foodaroundme/resources/place_filter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/place.dart';
import '../repository/PlacesRepository.dart';
import '../service/locationService.dart';

class MapViewModel extends ChangeNotifier {
  final PlacesRepository placesRepository;


  // Rule of thumb
  // Use:
  // ✅ setState → tiny, UI-only state
  // ✅ ViewModel / Provider → anything that:
  // affects navigation
  // affects data
  // affects multiple widgets
  // affects behavior


  // ======================================================
  // 🔧 Services & APIs
  // ======================================================

  final LocationService _locationService = LocationService();
  Timer? _debounce;

  // state (in android) is value that changes over time
  // ======================================================
  // 🗺️ Map State
  // ======================================================

  GoogleMapController? mapController;
  String? darkMapStyle;
  LatLng center = const LatLng(42.3104, -71.0575);// default coordinate before it is assigned by getCurrentLocation()
  LatLng cameraCenter = const LatLng(42.3104, -71.0575);
  LatLng? userLocation;
  double cameraZoom = 11.0;
  static const double searchRadius = 800;
  Set<Circle> circles = {};
  Set<Marker> markers = {};


  // ======================================================
  // 📍 Places State
  // ======================================================
  List<Place> allPlaces = [];
  List<Place> filteredPlaces = [];
  List<Place> allSearchPlaces = [];
  List<Place> filteredSearchPlaces = [];

  Place? selectedPlace;
  PlaceFilter? activeFilter;

  // ======================================================
  // 🧭 UI State
  // ======================================================

  bool isLoading = false;
  bool showBottomSheet = false;
  bool showFab = true;

  int selectedIndex = 0;
  int visibleCount = 10;


  // ======================================================
  // 🏗️ Constructor
  // ======================================================

  MapViewModel({
    required this.placesRepository,
  }) {
    getCurrentLocation();
    _loadMapStyle();
    customMarker();
    customMarkerCurrent();
  }

  // ======================================================
  // 🗺️ Map Lifecycle & theme
  // ======================================================

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: center, zoom: 14.8)),
    );
  }

  // When the maps moves, keep updating these variables so i know where the map current position is
  void onCameraMove(CameraPosition position) {
    cameraCenter = position.target;
    cameraZoom = position.zoom;
  }
  // Fire when map stops moving
  void onCameraIdle() {
    center = cameraCenter;
    updateUserLocation(center);
  }

  Future<void> _loadMapStyle() async {
    darkMapStyle =
    await rootBundle.loadString('assets/map_styles/dark_map.json');
    notifyListeners();
  }

  void resetCamera() {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: center, zoom: 15),
      ),
    );
  }

  // ======================================================
  // 📍 Location
  // ======================================================

  Future<void> getCurrentLocation() async {
    isLoading = true;
    notifyListeners();

    final position = await _locationService.getCurrentPosition();
    if (position == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    // real center coordinates
    center = LatLng(position.latitude, position.longitude);

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: center, zoom: 14.8)),
    );

    isLoading = false;
    notifyListeners();
  }

  void updateUserLocation(LatLng location) {
    circles = {
      Circle(
        circleId: const CircleId('search-radius'),
        center: location,
        radius: searchRadius,
        strokeWidth: 2,
        strokeColor: Colors.blue.withOpacity(0.6),
        fillColor: Colors.blue.withOpacity(0.15),
      ),
    };

    updateMarkers();

  }


  // ======================================================
  // 📍 Places Fetching
  // ======================================================



  Future<void> loadNearbyRestaurants(String filter) async {
    final places = await placesRepository.getNearbyPlaces(
      center: cameraCenter,
      category: filter,
      radius: searchRadius.toInt()
    );

    allPlaces = places;
    filteredPlaces = List.from(places); // default: show all restaurants


    sortPlacesByDistance();
    updateMarkers(); // convert filteredPlaces → markers
  }



  Future<Place?> getPlaceDetails(String placeId)  {
    return placesRepository.getPlaceDetails(placeId);
  }


  // ======================================================
  // 📏 Distance/Sorting
  // ======================================================

  void sortPlacesByDistance() {
    final origin = userLocation ?? center;

    filteredPlaces = [...filteredPlaces]..sort((a, b) {
      final distanceA = Geolocator.distanceBetween(
        origin.latitude,
        origin.longitude,
        a.location.latitude,
        a.location.longitude,
      );

      final distanceB = Geolocator.distanceBetween(
        origin.latitude,
        origin.longitude,
        b.location.latitude,
        b.location.longitude,
      );
      return distanceA.compareTo(distanceB);
    });

  }


  // ======================================================
  // 📍 Markers
  // ======================================================


  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentIcon = BitmapDescriptor.defaultMarker;

  Future<void> customMarkerCurrent()  async {
    currentIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 40)),
      "assets/markers/currentHome.png",
    );
    notifyListeners();
  }

  void customMarker() {
    BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(40, 40)),
        "assets/markers/locationPurple.png",
    ).then((icon) {
      customIcon = icon;
      notifyListeners();
    });
  }
  // --- Convert Places p into markers and notify UI ---
  void updateMarkers() {
    // show one selectedMarker
    if(selectedPlace != null) {
      markers = { // Update marker to show only one/selected
        Marker(
          markerId: MarkerId(selectedPlace!.id),
          position: selectedPlace!.location,
          infoWindow: InfoWindow(title: selectedPlace!.name,
              onTap: () {
        },
          ),
            icon: customIcon

        ),
      };
    } else {
      // show all (filtered) markers
      markers = filteredPlaces.map(
            (p) => Marker(
              markerId: MarkerId(p.name),
          position: p.location,
          infoWindow: InfoWindow(
              title: p.name,
            onTap: () {
            },
          ),
                icon: customIcon
            ),
      ).toSet();
      notifyListeners();
    }
  }


  // assigns selectedPlace to a marker
  void selectPlace(Place place) {
    selectedPlace = place;
    _focusOnPlace(place);
    notifyListeners();
  }


  // zoom in on selectedPlace
  Future<void> _focusOnPlace(Place place) async {
    if (mapController == null) return;

    await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: place.location,
            zoom: 16.5,
          ),
        )
    );
  }


  // ======================================================
  // 🔎 Search & Filters
  // ======================================================

  Future<void> applyFilter(PlaceFilter filter) async {

    // Update Intent
    activeFilter = filter;
    selectedPlace = null;
    isLoading = true;

    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 2000));

    showBottomSheet = true;

    switch(filter) {
      case PlaceFilter.restaurant:
        await loadNearbyRestaurants(GeoapifyCategories.restaurant);
        break;
      case PlaceFilter.cafe:
        await loadNearbyRestaurants(GeoapifyCategories.cafe);
        break;
      case PlaceFilter.bar:
        await loadNearbyRestaurants(GeoapifyCategories.bar);
        break;
      case PlaceFilter.popular:
        await loadNearbyRestaurants("popular");
        break;
    }
    resetCamera();
    isLoading = false;
    notifyListeners();
  }

  /////////////////////////////////////////////////////////////


  Future<void> fetchPlacesByTextSearch(String query) async {
    final places = await placesRepository.searchPlaces(
        center: cameraCenter,
        radius: searchRadius.toInt(),
        query: query,
    );

    allSearchPlaces = places;
    filteredSearchPlaces = List.from(places);

    notifyListeners();
  }

  void filterPlacesLocally(String query) { // Should be in separate VM class
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        filteredSearchPlaces = List.from(allSearchPlaces);
      } else {
        final q = query.toLowerCase();
        filteredSearchPlaces = allSearchPlaces.where((place) {
          return place.name.toLowerCase().contains(q);
        }
        ).toList();
      }
      notifyListeners();
    });
  }

  Future<void> searchPlaces(String query) async {
    _debounce?.cancel();

    final q = query.trim();
    // If query is short, don't hit the API
    if (q.length < 2) {
      filteredSearchPlaces = [];
      allSearchPlaces = [];
      notifyListeners();
      return;
    }
    // 🔥 CLEAR immediately so UI updates
    filteredSearchPlaces = [];
    allSearchPlaces = [];
    notifyListeners();
    
    await fetchPlacesByTextSearch(query);
  }




  // ======================================================
  // 🧭 UI Controls
  // ======================================================

  void toggleButton(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void openSheetandResetCount() {
    visibleCount = 10;
    showBottomSheet = true;
    notifyListeners();
  }

  void closeSheet() {
    showBottomSheet = false;
    notifyListeners();
  }

  void hideExpandableFab() {
    showFab = false;
    notifyListeners();
  }

  void showExpandableFabAgain() {
    showFab = true;
    notifyListeners();
  }


  void addCount() {
    visibleCount += 5;
    notifyListeners();
  }



  // ======================================================

  // 🧾 Derived UI Data
  // for map_screen.dart

  String get sheetTitle {
    switch (activeFilter) {
      case PlaceFilter.restaurant:
        return "Restaurants";
      case PlaceFilter.cafe:
        return "Cafés";
      case PlaceFilter.bar:
        return "Bars";
      case PlaceFilter.popular:
        return "Popular";
      default:
        return "";
    }
  }

}






