import 'package:flutter/material.dart';
import 'package:foodaroundme/resources/place_filter.dart';
import 'package:foodaroundme/viewmodel/mapViewModel.dart';
import 'package:foodaroundme/widgets/bottom_sheet_map.dart';
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
          // ToggleButtonGroup
          Positioned(
            right: 0,
            left: 0,
            bottom: 40, // position under FAB
            child: Center(
              child: AnimatedOpacity(
                opacity: isMenuOpen ? 0.0 : 1.0, // hides when FAB is expanded
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),  // soft light background
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ToggleButtons(
                    borderRadius: const BorderRadius.all(Radius.circular(40)),
                    constraints: const BoxConstraints(minHeight: 40, minWidth: 40),
                    fillColor: Colors.green.shade300,
                    selectedColor: Colors.white,
                    color: Colors.black,
                    selectedBorderColor: Colors.green,
                    borderColor: Colors.transparent,
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
          ),
          )
          )
        ],
      ),
        //////////////////
        // ⭐ ADD THE EXPANDABLE FAB HERE
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 90), // moves FAB up
          child: ExpandableFab(
            distance: 112,
          onOpenChanged: (isOpen) {
              setState( () => isMenuOpen = isOpen );
          },
          children: [
            ActionButton(
              icon: const Icon(Icons.fastfood_rounded),
              label: "Food",
              onPressed: () async {
                await viewModel.applyFilter(PlaceFilter.restaurant);
                if(!context.mounted) return;

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:  BorderRadius.vertical(
                        top: Radius.circular(25.0),
                    ),
                    ),
                    builder: (_) => BottomSheetMap(
                      title: "Restaurants",
                      places: viewModel.filteredPlaces,
                      onSelect: () {
                      Navigator.pop(context);
                  },
                ),
                );
              },
            ),
            ActionButton(
              icon: const Icon(Icons.coffee),
              label: "Cafe",
              onPressed: () async {
                await viewModel.applyFilter(PlaceFilter.cafe);
                if(!context.mounted) return;

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:  BorderRadius.vertical(
                      top: Radius.circular(25.0),
                    ),
                  ),
                  builder: (_) => BottomSheetMap(
                    title: "Cafe",
                    places: viewModel.filteredPlaces,
                    onSelect: () {
                      Navigator.pop(context);
                    },
                  ),
                );
              },

            ),
            ActionButton(
              icon: const Icon(Icons.local_bar),
              label: "Bars",
              onPressed: () async {
                await viewModel.applyFilter(PlaceFilter.bar);
                if(!context.mounted) return;

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:  BorderRadius.vertical(
                      top: Radius.circular(25.0),
                    ),
                  ),
                  builder: (_) => BottomSheetMap(
                    title: "Bars",
                    places: viewModel.filteredPlaces,
                    onSelect: () {
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            )
          ],
        ),
        )
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

