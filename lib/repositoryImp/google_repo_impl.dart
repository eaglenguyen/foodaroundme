
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as gmw;
import 'package:google_place/google_place.dart' as gp;
import '../model/place.dart';
import '../repository/PlacesRepository.dart';



class GoogleRepoImpl implements PlacesRepository {
  final String _apiKey;
  final gp.GooglePlace _searchApi;
  final gmw.GoogleMapsPlaces _detailsApi;

  GoogleRepoImpl(String apiKey)
      : _apiKey = apiKey,
        _searchApi = gp.GooglePlace(apiKey),
        _detailsApi = gmw.GoogleMapsPlaces(apiKey: apiKey);

  @override
  Future<List<Place>> getNearbyPlaces({
    required LatLng center,
    required int radius,
    required String category,
  }) async {
    final result = await _searchApi.search.getNearBySearch(
      gp.Location(lat: center.latitude, lng: center.longitude),
      radius,
      type: category,
    );

    if (result?.results == null) return [];

    return result!.results!
        .map(_mapSearchResultToPlace)
        .whereType<Place>()
        .toList();
  }

  @override
  Future<List<Place>> searchPlaces({
    required String query,
    LatLng? center,
    int radius = 500,
  }) async {
    final result = await _searchApi.search.getTextSearch(
      query,
      location: center != null
          ? gp.Location(lat: center.latitude, lng: center.longitude)
          : null,
      radius: center != null ? radius : null,
    );

    if (result?.results == null) return [];

    return result!.results!
        .map(_mapSearchResultToPlace)
        .whereType<Place>()
        .toList();
  }

  @override
  Future<Place?> getPlaceDetails(String placeId) async {
    final gmw.PlacesDetailsResponse response = await _detailsApi.getDetailsByPlaceId(
      placeId,
      fields: ['place_id','name', 'geometry'],
    );

    if (!response.isOkay) return null;

    final gmw.PlaceDetails r = response.result;
    return Place(
      id: r.placeId,
      name: r.name,
      address: r.formattedAddress ?? '',
      location: LatLng(
        r.geometry!.location.lat,
        r.geometry!.location.lng,
      ),
      categories: [],
      cuisine: [],

    );
  }

  Place? _mapSearchResultToPlace(gp.SearchResult r) {
    final loc = r.geometry?.location;
    if (loc == null) return null;

    return Place(
      id: r.placeId!,
      name: r.name ?? '',
      address: r.vicinity ?? '',
      location: LatLng(loc.lat!, loc.lng!),
      categories: r.types?.cast<String>() ?? [],
      cuisine: [],

    );
  }

  List<String> buildPhotoUrls(gmw.PlaceDetails details) {
    if (details.photos.isEmpty) return [];

    return details.photos
        .take(6) // limit for grid
        .map((p) =>
    'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=800'
        '&photo_reference=${p.photoReference}'
        '&key=$_apiKey'
    )
        .toList();
  }

  // Place Photos billing
  String? getPlacePhotoUrl(String? photoReference) {
    if (photoReference == null) return null;

    return 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=400'
        '&photo_reference=$photoReference'
        '&key=$_apiKey';
  }

  @override
  Future<Place?> getCacheDetails(String placeId) {
    // TODO: implement getCacheDetails
    throw UnimplementedError();
  }






}
