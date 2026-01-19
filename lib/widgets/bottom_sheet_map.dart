import 'package:flutter/material.dart';
import 'package:foodaroundme/viewmodel/mapViewModel.dart';
import 'package:foodaroundme/widgets/drag_handles/morph_drag_handle.dart';
import 'package:provider/provider.dart';
import '../model/place.dart';

class BottomSheetMap extends StatefulWidget {
  final String title;
  // changed to function to take place object
  final void Function(Place) onSelect;
  final VoidCallback close;
  final List<Place> places;


  const BottomSheetMap({
    super.key,
    required this.title,
    required this.onSelect,
    required this.close,
    required this.places,
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


    return DraggableScrollableSheet(
      expand: false,
      controller: _controller,
      initialChildSize: 0.4,
      minChildSize: 0.15,
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

            // Displays text if list of places are empty
            if(widget.places.isEmpty) ...[   // ... is used to inject a list of widgets
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      "No Restaurants/Cafes Nearby",
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
                  ...widget.places.map( (p) {
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
                              SizedBox(
                                width: 60,
                                height: 60,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: p.photoReference != null
                                ? Image.network(
                                  getPlacePhotoUrl(p.photoReference!)!,
                                  fit: BoxFit.cover,
                                ) : Container( // if null, placeholder icon
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey,
                                  child: const Icon(Icons.restaurant, color: Colors.white),
                                )
                              )
                              ),
                              const SizedBox(width: 12),

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
                                    Text(
                                      "Restaurant • Food • Drinks ",
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
                                      hoursAndRatings(p),
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
                onPressed: widget.close,
              ),
            ),

          ],
          ),
        );
        },
  );
  }
}

String? getPlacePhotoUrl(String? photoReference) {
  if (photoReference == null) return null;

  return 'https://maps.googleapis.com/maps/api/place/photo'
      '?maxwidth=400'
      '&photo_reference=$photoReference'
      '&key=${MapViewModel.apiKey}';
}


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

