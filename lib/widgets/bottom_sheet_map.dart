import 'package:flutter/material.dart';
import 'package:foodaroundme/viewmodel/mapViewModel.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController();

    _controller.addListener(_handleSheetSize);
  }

  void _handleSheetSize() {
    final size = _controller.size;
    final shouldShowFab = size <= 0.155;
    context.read<MapViewModel>()
    .setFabVisibility(shouldShowFab);
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
    maxChildSize: 0.95,
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
            const SizedBox(height: 16),

            /// drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 16),

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

            const SizedBox(height: 12),

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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => widget.onSelect(p),
                      child: Container(
                        padding: const EdgeInsets.all(12),
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
                              child: Image.network(
                                'https://via.placeholder.com/60',
                                fit: BoxFit.cover,
                              ),
                            ),
                            ),
                            const SizedBox(width: 12),

                            /// CENTER TEXT
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Title
                                  Text(
                                    p.name ?? 'Unknown',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  /// Categories
                                  Text(
                                     'Restaurant',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  /// Meta info
                                  Text(
                                    'Open Now',
                                    style: const TextStyle(
                                      fontSize: 12,
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


