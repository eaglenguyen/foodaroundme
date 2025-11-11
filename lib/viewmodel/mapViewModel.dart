import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../service/locationService.dart';

class MapViewModel extends ChangeNotifier {

  // current layout is variables -> methods/functions
  final LocationService _locationService = LocationService();
  bool isLoading = false;
  LatLng center = const LatLng(42.3104, -71.0575);
  GoogleMapController? mapController;

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

  Future<void> openTikTok(String restaurantName) async {
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
  }
}
