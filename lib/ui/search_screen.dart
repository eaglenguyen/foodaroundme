import 'package:flutter/material.dart';
import 'package:foodaroundme/viewmodel/mapViewModel.dart';
import 'package:provider/provider.dart';



class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();

}

class _SearchScreenState extends State<SearchScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapViewModel>().loadNearbyRestaurants("restaurant");
    });
  }


  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: Stack(
        children: [


          // 📍 Restaurant list
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
            itemCount: viewModel.filteredPlaces.length,
            itemBuilder: (_, index) {
              final place = viewModel.filteredPlaces[index];

              return ListTile(
                leading: const Icon(Icons.restaurant),
                title: Text(place.name),
                subtitle: Text(
                  "1 mile away",
                ),
              );
            },
          ),

          // 🔍 Bottom search bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 120,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(30),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
