import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceFoursquare {
  // Fields == properties
  // Properties are empty/null by default
  final String placeId;
  final String name;
  final LatLng location;
  final bool? isOpen;
  final double? rating;
  final int? priceLevel;
  final List<String> categories;


  // Constructor. This fills the fields with value, connects to fields above
  PlaceFoursquare({
    required this.placeId,
    required this.name,
    required this.location,
    this.isOpen,
    this.rating,
    this.priceLevel,
    required this.categories,
  });


  factory PlaceFoursquare.fromFoursquare(Map<String, dynamic> json) {
    return PlaceFoursquare(
      placeId: json['fsq_id'],
      name: json['name'],
      location: LatLng(
        json['geocodes']['main']['latitude'],
        json['geocodes']['main']['longitude'],
      ),
      rating: json['rating']?.toDouble(),
      priceLevel: json['price'],
      isOpen: json['hours']?['open_now'],
      categories: (json['categories'] as List)
          .map((c) => c['short_name'] as String)
          .toList(),
    );
  }


}