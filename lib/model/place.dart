import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';


class Place{
  // Fields == properties
  // Properties are empty/null by default
  final String placeId;
  final String name;
  final LatLng location;
  final String address;
  final String? photoReference;
  final List<String> types;
  final bool? isOpen;
  final double? rating;
  final int? priceLevel;

  // Constructor. This fills the fields with value, connects to fields above
  Place({
    required this.placeId,
    required this.name,
    required this.location,
    required this.address,
    this.photoReference,
    required this.types,
    this.isOpen,
    this.rating,
    this.priceLevel,
  });

  /// Converts GooglePlace's SearchResult → Place data class
  static Place? fromSearchResult(SearchResult result) {
    final loc = result.geometry?.location;
    if (loc == null) return null;

    return Place(
      placeId: result.placeId!,
      name: result.name ?? 'Unknown',
      location: LatLng(loc.lat ?? 0.0, loc.lng ?? 0.0),
      address: result.vicinity ?? 'Not Available',
      types: result.types?.cast<String>() ?? [],
      photoReference: result.photos?.isNotEmpty == true
        ? result.photos!.first.photoReference
          : null,
      isOpen: result.openingHours?.openNow,
      rating: result.rating,
      priceLevel: result.priceLevel
    );
  }
}