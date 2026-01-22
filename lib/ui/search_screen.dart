import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/mapViewModel.dart';
import '../viewmodel/searchViewModel.dart';
import '../widgets/bottom_sheet_detail/bottom_sheet_details.dart';



class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();

}

class _SearchScreenState extends State<SearchScreen> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final searchViewModel = context.watch<SearchViewModel>();
    final mapViewModel = context.watch<MapViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: Stack(
        children: [


          // 📍 Restaurant list
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
            itemCount: searchViewModel.newPlaces.length,
            itemBuilder: (_, index) {
              final place = searchViewModel.newPlaces[index];

              return ListTile(
                leading: const Icon(Icons.restaurant),
                title: Text(place.name),
                subtitle: Text(
                  place.types.join(", "),
                  ),
                onTap: () async {
                  final details = await mapViewModel.getPlaceDetails(
                      place.placeId);
                  if (!context.mounted) return;

                  if (details == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Details not available')),
                    );
                    return;
                  }
//
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25.0)),
                    ),
                    builder: (_) =>
                        BottomSheetDetails(
                          place: place,
                          details: details,
                        ),
                  );
                });
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
                onChanged: (query) {
                  if (query.length < 3) {
                    searchViewModel.filterPlacesLocally(query);
                  } else {
                    searchViewModel.searchPlaces(query);
                  }                },
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
