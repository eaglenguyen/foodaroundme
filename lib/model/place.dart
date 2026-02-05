import 'package:google_maps_flutter/google_maps_flutter.dart';


class Place{
  // Fields == properties
  // Properties are empty/null by default
  final String id;
  final String name;
  final LatLng location;
  final String address;

  // Enrichment fields
  final String? photoUrl;
  final List<String>? categories;
  final String? cuisine;
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
    this.cuisine,
    this.photoUrl,
    this.categories,
    this.isOpen,
    this.rating,
    this.priceLevel,
    this.website,
    this.phone,
    this.photoUrls = const [],

});

  /// Converts GooglePlace's SearchResult → Place data class
  // Moved to googleRepo called _mapSearchResultToPlace


}
//result.photos?.isNotEmpty == true
//         ? result.photos!.first.photoReference
//           : null,

//isOpen: result.openingHours?.openNow,
//rating: result.rating,
//priceLevel: result.priceLevel