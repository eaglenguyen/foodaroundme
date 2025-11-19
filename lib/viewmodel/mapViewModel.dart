import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import '../service/locationService.dart';

class MapViewModel extends ChangeNotifier {

  // current layout is state variables -> methods/functions
  // state (in android) is value that changes over time
  final LocationService _locationService = LocationService();
  bool isLoading = false;
  LatLng center = const LatLng(42.3104, -71.0575);
  List<bool> selectedButtons = [true, false, false, false];
  GoogleMapController? mapController;

  // fetch restaurant api
  late GooglePlace _places;
  Set<Marker> markers = {};

  MapViewModel() {
    initPlaces();
  }

  void initPlaces() {
    const apiKey = String.fromEnvironment("GOOGLE_MAPS_API_KEY");
    _places = GooglePlace(apiKey);
  }

  Future<void> loadNearbyRestaurants() async {
    final result = await _places.search.getNearBySearch(
      Location(lat: center.latitude, lng: center.longitude),
      800, // radius meters
      type: "restaurant",
    );

    if (result == null || result.results == null) return;

    final newMarkers = result.results!.map((place) {
      final location = place.geometry?.location;
      if (location == null) return null;

      return Marker(
        markerId: MarkerId(place.placeId ?? place.name ?? "unknown"),
        position: LatLng(location.lat!, location.lng!),
        infoWindow: InfoWindow(
          title: place.name,
          snippet: place.vicinity,
        ),
      );
    }).whereType<Marker>().toSet();

    markers = newMarkers;
    notifyListeners();
  }

  void toggleButton(int index) {
    for (int i = 0; i < selectedButtons.length; i++) {
      selectedButtons[i] = i == index;
    }
    notifyListeners();
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
