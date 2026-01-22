import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceFoursquare {
  // Fields == properties
  // Properties are empty/null by default
  final String placeId;
  final String name;
  final List<String> categories;


  // Constructor. This fills the fields with value, connects to fields above
  PlaceFoursquare({
    required this.placeId,
    required this.name,
    required this.categories,
  });


  factory PlaceFoursquare.fromFoursquare(Map<String, dynamic> json) {
    return PlaceFoursquare(
      placeId: json['fsq_id'],
      name: json['name'],
      categories: (json['categories'] as List)
          .map((c) => c['short_name'] as String)
          .toList(),
    );
  }


}