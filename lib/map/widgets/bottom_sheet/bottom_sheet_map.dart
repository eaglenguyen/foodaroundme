
import 'package:flutter/material.dart';
import 'package:foodaroundme/map/widgets/skeleton_row.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../../model/place.dart';
import '../../viewmodel/mapViewModel.dart';
import 'morph_drag_handle.dart';

class BottomSheetMap extends StatefulWidget {
  final String title;
  // changed to function to take place object
  final void Function(Place) onSelect;
  final VoidCallback close;
  final VoidCallback addCount;
  final List<Place> places;
  final int count;
  final bool isLoading;


  const BottomSheetMap({
    super.key,
    required this.title,
    required this.onSelect,
    required this.close,
    required this.addCount,
    required this.places,
    required this.count,
    required this.isLoading,
  });

  @override
  State<BottomSheetMap> createState() => _BottomSheetMapState();
}

class _BottomSheetMapState extends State<BottomSheetMap> {
  late final DraggableScrollableController _controller;
  double _sheetSize = 0.4;


  @override
  void initState() {
    super.initState();
    // Linking viewmodel method to here
    _controller = DraggableScrollableController();
    _controller.addListener(_handleSheetSize);
  }

  void _handleSheetSize() {
    final size = _controller.size;
    if(size != _sheetSize) {
      setState(() { // runs when this variable values have changed, so rebuild UI/widget
        _sheetSize = size;
      });
    }

    final shouldShowFab = size <= 0.155;

    if (shouldShowFab) {
    context.read<MapViewModel>()
    .showExpandableFabAgain();
  } else {
      context.read<MapViewModel>()
          .hideExpandableFab();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleSheetSize);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapVm = context.watch<MapViewModel>();


    return DraggableScrollableSheet(
      expand: false,
      controller: _controller,
      initialChildSize: 0.4,
      minChildSize: 0.13,
      maxChildSize: 1,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF2A2433),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Stack(
          children:[
            ListView(
            primary: false,
            controller: scrollController,
            padding: const EdgeInsets.only(top: 28),
            children: [
              const SizedBox(height: 8),

            /// drag handle
            Center(
              child: MorphingDragHandle(sheetSize: _sheetSize)
            ),


            /// Title
            Center(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 6),
              if (widget.isLoading) ...[
                Shimmer(
                  duration: const Duration(milliseconds: 1500),
                  color: Colors.white,
                  colorOpacity: 0.25,
                child: Column(
                children: List.generate(
                  6,
                      (_) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: ShimmerPlaceRow(),
                  ),
                ),
                ),
        ),
              ] else if
              // Displays text if list of places are empty
              (widget.places.isEmpty) ...[   // ... is used to inject a list of widgets
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      "No Restaurants Nearby",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      ),
                        ),
                          ),
                  ] else ...[
                    /// ⭐ The correct way to show the list
                    /// p is the place object clicked
                  ...widget.places.take(widget.count).map( (p) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => widget.onSelect(p),
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2433), // dark card
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              /// LEFT IMAGE

                              /// CENTER TEXT
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Title
                                    Text(
                                      p.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),

                                    const SizedBox(height: 2),

                                    /// Cuisine Info
                                    ///

                                    Text(

                                      formatCategories(p.categories!),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                      ),
                                    ),

                                    const SizedBox(height: 2),

                                    /// Meta info
                                    Text(
                                      "Hours Unknown • ⭐ • \$ ",
                                      //hoursAndRatings(p),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                    ),
              if (widget.count < widget.places.length)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () {
                        widget.addCount();
                      },
                      icon: const Icon(
                        Icons.expand_more,
                        color: Colors.white70,
                        size: 18,
                      ),
                      label: const Text(
                        "Show more",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
            ],
          ),
            /// CLOSE BUTTON
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                color: Colors.white70,
                splashRadius: 20,
                onPressed: mapVm.isLoading ? null : widget.close,
              ),
            ),

            const SizedBox(height: 2),


          ],

          ),

        );
        },
  );
  }
}


//Atmosphere Billing
String hoursAndRatings(Place p) {
  final status = p.isOpen == null
      ? 'Hours Unknown'
      : p.isOpen!
      ? 'Open Now'
      : 'Closed';

  final ratingText = p.rating != null
      ? ' • ⭐ ${p.rating!.toStringAsFixed(1)}'
      : '';

  String priceLevelToString(int? level) {
    if (level == null || level <= 0) return '';
    return '\$' * level;
  }
  final priceText = p.priceLevel != null && p.priceLevel! > 0
      ? ' • ${priceLevelToString(p.priceLevel)}'
      : '';


  return status + ratingText + priceText;
}


String formatCategories(dynamic rawCategories) {
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