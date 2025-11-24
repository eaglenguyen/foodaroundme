import 'package:flutter/material.dart';
import 'package:foodaroundme/viewmodel/mapViewModel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../widgets/expandable_fab.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MapViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Maps Sample App"),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: viewModel.onMapCreated,
            initialCameraPosition: CameraPosition(
              target: viewModel.center,
              zoom: 11.0,
            ),
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: viewModel.center,
                infoWindow: const InfoWindow(title: "You're here"),
              ),
              // inserting each items from the list into another Marker set/list
              ...viewModel.markers,
            },
          ),
          // togglebuttons
          Positioned(
            right: 0,
            left: 0,
            bottom: 40, // position under FAB
            child: Center(
            child: ToggleButtons(
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
              fillColor: Colors.green,
              selectedColor: Colors.white,
              color: Colors.black,
              selectedBorderColor: Colors.green,
              borderColor: Colors.grey,
              isSelected: viewModel.selectedButtons,
              onPressed: (index) {
                viewModel.toggleButton(index);  // update your viewmodel
              },
              children: const [
                Icon(Icons.home),
                Icon(Icons.map),
                Icon(Icons.person),
                Icon(Icons.search),
              ],
            ),
          ),
          )
        ],
      ),
        //////////////////
        // ⭐ ADD THE EXPANDABLE FAB HERE
        floatingActionButton: ExpandableFab(
            distance: 112,
          children: [
            ActionButton(icon: const Icon(Icons.restaurant),
            onPressed: () => viewModel.loadNearbyRestaurants(),
            ),
            ActionButton(icon: const Icon(Icons.local_offer),
            onPressed: () {
              //
            },
            ),
            ActionButton(icon: const Icon(Icons.favorite),
            onPressed: () {
              //
            },)
          ],
        ),
        /////////////////
    );
  }
}


/*
              // Restaurant detailScreen
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
                ),*/

