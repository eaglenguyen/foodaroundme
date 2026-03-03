import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodaroundme/repositoryImp/geoapify_repo_impl.dart';
import 'package:foodaroundme/resources/place_filter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/place.dart';
import '../repository/PlacesRepository.dart';
import '../service/locationService.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart' as cm2;


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

  // ======================================================
  // 🗺️ Cluster Logic
  // ======================================================

  void Function(Place place)? onPlaceTap;
  late final cm2.ClusterManager clusterManager;
  final List<Place> clusterItems = [];

  void _onMarkersUpdated(Set<Marker> newMarkers) {
    markers = newMarkers;
    notifyListeners();
  }

  Future<Marker> _markerBuilder(cm2.Cluster cluster) async {
    if (cluster.isMultiple) {
      return Marker(
        markerId: MarkerId('cluster_${cluster.getId()}'),
        position: cluster.location,
        icon: await _getClusterIcon(cluster.count),
        infoWindow: InfoWindow(title: '${cluster.count} places'),
        onTap: () async {
          final nextZoom = (await mapController?.getZoomLevel() ?? cameraZoom) + 1.5;
          await mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: cluster.location, zoom: nextZoom),
            ),
          );
        }
      );
    }

    final place = cluster.items.first as Place;

    return Marker(
      markerId: MarkerId(place.id),
      position: place.location,
      infoWindow: InfoWindow(title: place.name),
      icon: customIcon,
      onTap: () {
        selectPlace(place);
        requestOpenDetails(place.id);
      },
    );
  }

  final Map<int, BitmapDescriptor> _clusterIconCache = {};

  Future<BitmapDescriptor> _getClusterIcon(int count) async {
    // cache by "bucket" so we don't generate thousands of unique images
    int bucket;
    if (count < 10) {
      bucket = count;
    } else if (count < 50) {
      bucket = 50;
    } else if (count < 100) {
      bucket = 100;
    } else {
      bucket = 999; }

      final cached = _clusterIconCache[bucket];
      if (cached != null) return cached;

      const int size = 140; // pixels (bigger = sharper)
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Background circle
      final Paint outer = Paint()..color = const Color(0xFFF5C518); // your accent
      final Paint inner = Paint()..color = const Color(0xFF1A1422); // dark center

      final Offset c = const Offset(size / 2, size / 2);
      canvas.drawCircle(c, size * 0.42, outer);
      canvas.drawCircle(c, size * 0.33, inner);

      // Count text
      final String text = bucket == 999 ? '99+' : (bucket == 50 ? '10+' : bucket.toString());
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.w800,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));

      final ui.Image image = await recorder.endRecording().toImage(size, size);
      final ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final descriptor = BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());

      _clusterIconCache[bucket] = descriptor;
      return descriptor;
    }

  String? _openDetailsForId;

  void requestOpenDetails(String placeId) {
    _openDetailsForId = placeId;
    notifyListeners();
  }

  String? consumeOpenDetailsRequest() {
    final id = _openDetailsForId;
    _openDetailsForId = null;
    return id;
  }


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
    clusterManager = cm2.ClusterManager(
      clusterItems,
      _onMarkersUpdated,
      markerBuilder: _markerBuilder,
    );
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

    clusterManager.setMapId(controller.mapId);
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: center, zoom: 14.8)),
    );
  }

  // When the maps moves, keep updating these variables so i know where the map current position is
  void onCameraMove(CameraPosition position) {
    cameraCenter = position.target;
    cameraZoom = position.zoom;

    clusterManager.onCameraMove(position);
  }
  // Fire when map stops moving
  void onCameraIdle() {
    center = cameraCenter;
    updateUserLocation(center);

    clusterManager.updateMap();
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

    //updateMarkers();
    updateClusterItems();

  }

  Future<void> moveToUserLocation() async {
    final position = await Geolocator.getCurrentPosition();

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        14.8,
      ),
    );
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
    updateClusterItems(); // convert filteredPlaces → markers
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
    }
    notifyListeners();

  }

  void updateClusterItems() {
    // if user selected a place, we only cluster that one (effectively single marker)
    clusterManager.setItems(filteredPlaces);
    clusterManager.updateMap();
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
            zoom: 18,
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






