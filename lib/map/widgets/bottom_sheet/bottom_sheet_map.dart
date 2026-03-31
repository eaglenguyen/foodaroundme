
import 'package:flutter/material.dart';
import 'package:foodaroundme/map/widgets/skeleton_row.dart';
import 'package:foodaroundme/resources/category_icon.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../../model/place.dart';
import '../../viewmodel/map_viewmodel.dart';


class BottomSheetMap extends StatefulWidget {
  final String title;
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
    _controller = DraggableScrollableController();
    _controller.addListener(_handleSheetSize);
  }

  void _handleSheetSize() {
    final size = _controller.size;
    if (size != _sheetSize) {
      setState(() => _sheetSize = size);
    }
    final shouldShowFab = size <= 0.155;
    if (shouldShowFab) {
      context.read<MapViewModel>().showExpandableFabAgain();
    } else {
      context.read<MapViewModel>().hideExpandableFab();
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
            color: Color(0xFF1C1825),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Stack(
            children: [
              ListView(
                primary: false,
                controller: scrollController,
                padding: const EdgeInsets.only(top: 20),
                children: [
                  // ✅ Drag handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ Header row with title + count badge
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        if (!widget.isLoading && widget.places.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Text(
                              '${widget.places.length} places',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ✅ Thin divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      color: Colors.white.withOpacity(0.06),
                      height: 1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ✅ Content
                  if (widget.isLoading) ...[
                    Shimmer(
                      duration: const Duration(milliseconds: 1500),
                      color: Colors.white,
                      colorOpacity: 0.25,
                      child: Column(
                        children: List.generate(
                          6,
                              (_) => const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            child: ShimmerPlaceRow(),
                          ),
                        ),
                      ),
                    ),
                  ] else if (widget.places.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.location_off_rounded,
                            size: 40,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No places nearby',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.35),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try expanding your search radius',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ...widget.places.take(widget.count).map((p) {
                      return _PlaceRow(
                        place: p,
                        onTap: () => widget.onSelect(p),
                      );
                    }),

                    // ✅ Show more button
                    if (widget.count < widget.places.length)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: GestureDetector(
                          onTap: widget.addCount,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.expand_more_rounded,
                                  size: 18,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Show more',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ],
              ),

              // ✅ Close button
              Positioned(
                top: 10,
                right: 16,
                child: GestureDetector(
                  onTap: mapVm.isLoading ? null : widget.close,
                  child: AnimatedOpacity(
                    opacity: mapVm.isLoading ? 0.3 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ✅ Extracted place row widget
class _PlaceRow extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;

  const _PlaceRow({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          splashColor: Colors.white.withOpacity(0.04),
          highlightColor: Colors.white.withOpacity(0.02),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.07),
              ),
            ),
            child: Row(
              children: [
                // ✅ Category icon pill
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    categoryIcon(place.categories ?? []),
                    color: Colors.white.withOpacity(0.6),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 14),

                // ✅ Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        formatCategories(place.categories ?? []),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.45),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Colors.white.withOpacity(0.2),
                ),
              ],
            ),
          ),
        ),
      ),
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


