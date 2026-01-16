class PlaceDetailsV1 {
  final List<String> types;


  PlaceDetailsV1({
    required this.types,

  });

  factory PlaceDetailsV1.fromJson(Map<String, dynamic> json) {
    return PlaceDetailsV1(
      types: List<String>.from(json['types'] ?? []),
    );
  }
}


