import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';


class Place{
  final String name;
  final LatLng location;
  final String address;
  final List<String> types;

  Place({
    required this.name,
    required this.location,
    required this.address,
    required this.types,
  });

  /// Converts GooglePlace's PlaceSearchResult → our Place
  static Place? fromSearchResult(SearchResult result) {
    final loc = result.geometry?.location;
    if (loc == null) return null;

    return Place(
      name: result.name ?? 'Unknown',
      location: LatLng(loc.lat ?? 0.0, loc.lng ?? 0.0),
      address: result.formattedAddress ?? 'null',
      types: result.types?.cast<String>() ?? [],
    );
  }
}