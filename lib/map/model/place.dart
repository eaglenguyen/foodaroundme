import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class Place with ClusterItem{
  // Fields == properties
  // Properties are empty/null by default
  final String id;
  final String name;
  final String address;
  @override
  final LatLng location;
  // Enrichment fields
  final String? photoUrl;
  final List<String>? categories;
  final bool? isOpen;
  final double? rating;
  final int? priceLevel;
  final String? website;
  final String? phone;
  final List<String> photoUrls;
  final String? openingHours;



  // Constructor. This fills the fields with value, connects to fields above
  Place({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    this.photoUrl,
    this.categories,
    this.isOpen,
    this.rating,
    this.priceLevel,
    this.website,
    this.phone,
    this.photoUrls = const [],
    this.openingHours,


  });


}


  /// Converts GooglePlace's SearchResult → Place data class
  // Moved to googleRepo called _mapSearchResultToPlace


//result.photos?.isNotEmpty == true
//         ? result.photos!.first.photoReference
//           : null,
