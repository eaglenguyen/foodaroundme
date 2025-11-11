import 'package:flutter/material.dart';
import 'package:foodaroundme/viewmodel/mapViewModel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';


class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MapViewModel>(context);
    const restaurantName = "Felipe's Taqueria";
    const tag = "Bonchon";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Maps Sample App"),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: viewModel.onMapCreated,
            initialCameraPosition: CameraPosition(target: viewModel.center, zoom: 11.0),
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: viewModel.center,
                infoWindow: const InfoWindow(title: "You're here"),
              ),
            },
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // TikTok Button
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.video_library_outlined),
                    label: const Text('TikTok'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => viewModel.openTikTok(restaurantName),
                  ),
                ),

                const SizedBox(width: 12), // spacing between buttons

                // Instagram Button
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Instagram'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => viewModel.openInstagramTag(tag),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
