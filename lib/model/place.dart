import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';


class Place{
  // Fields == properties
  // Properties are empty/null by default
  final String id;
  final String name;
  final LatLng location;
  final String address;

  // Enrichment fields
  final String? photoUrl;
  final List<String> categories;
  final bool? isOpen;
  final double? rating;
  final int? priceLevel;
  final String? website;
  final String? phone;
  final List<String> photoUrls;


  // Constructor. This fills the fields with value, connects to fields above
  Place({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    this.photoUrl,
    required this.categories,
    this.isOpen,
    this.rating,
    this.priceLevel,
    this.website,
    this.phone,
    this.photoUrls = const [],

});

  /// Converts GooglePlace's SearchResult → Place data class
  static Place? fromSearchResult(SearchResult result) {
    final loc = result.geometry?.location;
    if (loc == null) return null;

    return Place(
      id: result.placeId!,
      name: result.name ?? 'Unknown',
      location: LatLng(loc.lat ?? 0.0, loc.lng ?? 0.0),
      address: result.vicinity ?? 'Not Available',
      categories: result.types?.cast<String>() ?? [],
      photoUrl: null,
      isOpen: null,
      rating: null,
      priceLevel: null
    );
  }


}
//result.photos?.isNotEmpty == true
//         ? result.photos!.first.photoReference
//           : null,

//isOpen: result.openingHours?.openNow,
//rating: result.rating,
//priceLevel: result.priceLevel