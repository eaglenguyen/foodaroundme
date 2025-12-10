import 'package:flutter/material.dart';
import 'package:foodaroundme/resources/place_filter.dart';
import 'package:foodaroundme/ui/map_screen.dart';
import 'package:foodaroundme/ui/search_screen.dart';
import 'package:foodaroundme/viewmodel/mapViewModel.dart';
import 'package:foodaroundme/widgets/bottom_sheet_map.dart';
import 'package:provider/provider.dart';
import '../widgets/expandable_fab.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0; // 0 is Map, 1 is searchScreen
  bool isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MapViewModel>(context);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ⭐ ADD THE EXPANDABLE FAB HERE (only on mapScreen)
      floatingActionButton: AnimatedOpacity(
        opacity: currentIndex == 0 ? 1.0 : 0.0, // visible only on MapScreen
        duration: const Duration(milliseconds: 200),
        child: IgnorePointer(
          ignoring: currentIndex != 0, // prevents interaction when invisible
          child: Padding(
            padding: const EdgeInsets.only(bottom: 90), // moves FAB up
            child: ExpandableFab(
              distance: 112,
              onOpenChanged: (isOpen) {
                setState(() => isMenuOpen = isOpen);
              },
              children: [
                ActionButton(
                  icon: const Icon(Icons.fastfood_rounded),
                  label: "Food",
                  onPressed: () async {
                    await viewModel.applyFilter(PlaceFilter.restaurant);
                    if (!context.mounted) return;

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                      ),
                      builder: (_) => BottomSheetMap(
                        title: "Restaurants",
                        places: viewModel.filteredPlaces,
                        onSelect: () => Navigator.pop(context),
                      ),
                    );
                  },
                ),
                ActionButton(
                  icon: const Icon(Icons.coffee),
                  label: "Cafe",
                  onPressed: () async {
                    await viewModel.applyFilter(PlaceFilter.cafe);
                    if (!context.mounted) return;

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                      ),
                      builder: (_) => BottomSheetMap(
                        title: "Cafe",
                        places: viewModel.filteredPlaces,
                        onSelect: () => Navigator.pop(context),
                      ),
                    );
                  },
                ),
                ActionButton(
                  icon: const Icon(Icons.local_bar),
                  label: "Bars",
                  onPressed: () async {
                    await viewModel.applyFilter(PlaceFilter.bar);
                    if (!context.mounted) return;

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                      ),
                      builder: (_) => BottomSheetMap(
                        title: "Bars",
                        places: viewModel.filteredPlaces,
                        onSelect: () => Navigator.pop(context),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),


      appBar: AppBar(
        title: const Text("Maps"),
        backgroundColor: Colors.green,
      ),
      // animation for navigation
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),  // bottom
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            child: currentIndex == 0
                ? const MapScreen(key: ValueKey(0))
                : const SearchScreen(key: ValueKey(1)),
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

                      setState(() {
                        currentIndex = index == 3 ? 1 : 0; // ternary operator
                      });

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

