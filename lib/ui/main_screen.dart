import 'package:flutter/material.dart';
import 'package:foodaroundme/resources/place_filter.dart';
import 'package:foodaroundme/ui/map_screen.dart';
import 'package:foodaroundme/ui/profile_screen.dart';
import 'package:foodaroundme/ui/search_screen.dart';
import 'package:foodaroundme/viewmodel/mapViewModel.dart';

import 'package:provider/provider.dart';
import '../widgets/action_button.dart';
import '../widgets/expandable_fab.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isMenuOpen = false;


  final List<Widget> screens = const [
    MapScreen(key: ValueKey(0)),     // index 0
    ProfileScreen(key: ValueKey(1)), // index 1
    SearchScreen(key: ValueKey(2)),  // index 2
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();

    return Scaffold(

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ⭐ ADD THE EXPANDABLE FAB HERE (only on mapScreen)
      floatingActionButton: AnimatedOpacity(
        opacity: viewModel.selectedIndex == 0 && viewModel.showFab ? 1.0 : 0.0, // visible only on MapScreen
        duration: const Duration(milliseconds: 200),
        child: IgnorePointer(
          ignoring: viewModel.selectedIndex != 0 || !viewModel.showFab, // prevents interaction when invisible
          child: Padding(
            padding: const EdgeInsets.only(bottom: 90), // moves FAB up
            child: ExpandableFab(
              distance: 112, // controls the spread of icons
              onOpenChanged: (isOpen) {
                setState(() => isMenuOpen = isOpen // setState similar to LaunchedEffect/mutableStateof
                );
              },
              children: [
                ActionButton(
                  icon: const Icon(Icons.fastfood_rounded),
                  label: "Food",
                  onPressed: () async {
                    viewModel.hideExpandableFab();
                    await viewModel.applyFilter(PlaceFilter.restaurant);
                    viewModel.openSheet();

                    if (!context.mounted) return;

                  },
                ),
                ActionButton(
                  icon: const Icon(Icons.coffee),
                  label: "Cafe",
                  onPressed: () async {
                    viewModel.hideExpandableFab();
                    await viewModel.applyFilter(PlaceFilter.cafe);
                    viewModel.openSheet();

                    if (!context.mounted) return;


                  },
                ),
                ActionButton(
                  icon: const Icon(Icons.local_bar),
                  label: "Bars",
                  onPressed: () async {
                    viewModel.hideExpandableFab();
                    await viewModel.applyFilter(PlaceFilter.bar);
                    viewModel.openSheet();
                    if (!context.mounted) return;
                  },
                ),
              ],
            ),
          ),
        ),
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
            child: screens[viewModel.selectedIndex]
          ),

          // ToggleButtonGroup
          Positioned(
            right: 0,
            left: 0,
            bottom: 40, // position under FAB
            child: Center(
              child: IgnorePointer(
                ignoring: isMenuOpen || !viewModel.showFab, // when true (fab is open), ignore interaction
                child: AnimatedOpacity(
                opacity: isMenuOpen || !viewModel.showFab ? 0.0 : 1.0, // hides when FAB is expanded
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
                    constraints: const BoxConstraints(minHeight: 40, minWidth: 70),
                    fillColor: Colors.white,
                    selectedColor: Colors.black,
                    color: Colors.grey,
                    selectedBorderColor: Colors.black,
                    borderColor: Colors.transparent,
                    isSelected: List.generate(
                      3,
                          (index) => (index == viewModel.selectedIndex),   // iterates through list, sets current index of list to true/false depending if i actually equals index

                    ),
                    onPressed: (index) {
                      viewModel.toggleButton(index);  // update your viewmodel
                    },
                    children: const [
                      Icon(Icons.map),
                      Icon(Icons.person),
                      Icon(Icons.search),
                    ],
                  ),
              ),
          ),
          )
          )
          )
        ],
      ),
        //////////////////

    );
  }
}

