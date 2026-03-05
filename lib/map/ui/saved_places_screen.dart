import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../authentication/viewmodel/authViewModel.dart';
import '../viewmodel/mapViewModel.dart';
import '../widgets/bottom_sheet_detail/bottom_sheet_details.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}
  class _SavedPlacesScreenState extends State<SavedPlacesScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AuthViewModel>().fetchSavedPlaces());
  }


  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final places = authVm.savedPlaces;



    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: const Color(0xFF120C18),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        title: const Text(
          "Favorites ❤️",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1C1622),
              Color(0xFF0F0B14),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            itemCount: places.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final place = places[index];
              return _SavedPlaceCard(
                name: place.name,
                cuisine: formatCuisines(place.categories),
                address: cleanAddress(place.address),
                onTap: () async {
                  final mapVm = context.read<MapViewModel>();
                  mapVm.selectPlace(place);

                  final details = await mapVm.getPlaceDetails(place.id);
                  if (!context.mounted || details == null) return;
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: const Color(0xFF120C18),
                    builder: (_) => BottomSheetDetails(place: details),
                  );

                },
                onDelete: () {
                  context.read<AuthViewModel>().deleteSavedPlace(place.id);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SavedPlaceCard extends StatelessWidget {
  final String name;
  final String cuisine;
  final String address;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SavedPlaceCard({
    required this.name,
    required this.cuisine,
    required this.address,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1422),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            // Placeholder image circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF5C518).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 16),

            // Text section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cuisine,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFF5C518),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.white38,
                  ),
                  splashRadius: 20,
                  onPressed: onDelete,
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white38,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String cleanAddress(String rawAddress) {
  if (rawAddress.isEmpty) return '';

  final parts = rawAddress.split(',');

  if (parts.length <= 1) return rawAddress; // fallback

  // Remove the first part (the place name) and trim each remaining part
  final addressOnly = parts.sublist(1).map((p) => p.trim()).join(', ');

  return addressOnly;
}

String formatCuisines(dynamic rawCategories) {
  if (rawCategories == null) return 'Restaurant';

  final categories = List<String>.from(rawCategories);

  const allowedPrefixes = [
    'restaurant.',
    'catering.',
  ];

  final cuisines = categories
  // keep only allowed category types
      .where((c) => allowedPrefixes.any((p) => c.startsWith(p)))
  // keep only allowed category types
      .map((c) => c.split('.').last)
      .map((c) => c.replaceAll('_', ' '))
      .map((c) =>
  c.isEmpty ? c : c[0].toUpperCase() + c.substring(1))
      .toSet()
      .toList();

  // Remove 'Restaurant' if there are other cuisines
  if (cuisines.length > 1) {
    cuisines.remove('Restaurant');
  }

  return cuisines.isEmpty ? 'Restaurant' : cuisines.join(' • ');
}