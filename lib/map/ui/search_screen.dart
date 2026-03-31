import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../resources/category_icon.dart';
import '../../service/subscription/paywall_screen.dart';
import '../../service/subscription/subscription_viewmodel.dart';
import '../viewmodel/map_viewmodel.dart';
import '../widgets/bottom_sheet_detail/bottom_sheet_details.dart';



class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();

}

class _SearchScreenState extends State<SearchScreen> {

  // Runs when widget is created
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();
    final subVm = context.watch<SubscriptionViewModel>();
    final places = viewModel.filteredSearchPlaces;
    final itemCount = places.length > 10 ? 10 : places.length;

    // ✅ show paywall if not subscribed
    if (subVm.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!subVm.isPro) {
      return PaywallScreen(onPurchase: subVm.purchase, onRestore: subVm.restore);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: Stack(
        children: [
          // 📍 Restaurant list
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
            itemCount: itemCount,
            itemBuilder: (_, index) {
              final place = viewModel.filteredSearchPlaces[index];

              return ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      categoryIcon(place.categories ?? []), // ✅
                      size: 20,
                    ),
                  ),
                title: Text(place.name),
                subtitle: Text(
                  formatCategories(place.categories ?? []),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis
                ),
                onTap: () async {
                  final details = await viewModel.getPlaceDetails(
                      place.id);
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
                          place: details,
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
                    viewModel.filterPlacesLocally(query);
                  } else {
                    viewModel.searchPlaces(query);
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
