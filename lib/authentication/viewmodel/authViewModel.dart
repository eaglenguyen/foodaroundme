import 'package:flutter/cupertino.dart';
import 'package:foodaroundme/main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../map/model/place.dart';



class AuthViewModel extends ChangeNotifier{

  bool isLoading = false;
  String? error;

  String? username;
  String? bio;

  final List<Place> savedPlaces = [];


  Future<void> loadProfileTable() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final row = await supabase
      .from('profiles')
      .select('username, bio')
      .eq('id', user.id)
      .maybeSingle();

    username = row?['username'] as String?;
    bio = row?['bio'] as String?;
    notifyListeners();
  }

  // Also handles duplicate Emails
  Future<void> seedProfileIfMissingFromGoogle() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // Load current profile row
    final row = await supabase
        .from('profiles')
        .select('username')
        .eq('id', user.id)
        .maybeSingle();

    final existing = (row?['username'] as String?)?.trim();

    // Pull google name from metadata as a one-time seed
    final googleName = (user.userMetadata?['full_name'] ?? 'null')?.toString().trim();

    // If these conditions are met, make the username (in profiles table) as google name
    if ((existing == null || existing.isEmpty) &&
        googleName != null &&
        googleName.isNotEmpty) {
      await supabase
          .from('profiles')
          .update({'username': googleName})
          .eq('id', user.id);
    }
  }


  Future<void> signInWithGoogle() async {

    const webClientId = '960770120495-d6d049dnh3do3s9ag3msavu7mp202roi.apps.googleusercontent.com';

    const iosClientId = '960770120495-21i2r9h3cml61lsvhqk4fg1gs74fm4he.apps.googleusercontent.com';

    // Google sign in on Android will work without providing the Android
    // Client ID registered on Google Cloud.

    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );

      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        isLoading = false;
        notifyListeners();
        return;
      }
      final googleAuth = await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Missing Google auth token');
      }

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      await seedProfileIfMissingFromGoogle();
      await loadProfileTable();
      await fetchSavedPlaces();

    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  bool isSaved(String providerPlaceId) =>
      savedPlaces.any((p) => p.id == providerPlaceId);


  Future<void> savePlace(Place place) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    final userId = user.id;


    if (isSaved(place.id)) {
      await supabase
          .from('saved_places')
          .delete()
          .eq('user_id', userId)
          .eq('provider_place_id', place.id);
      savedPlaces.removeWhere((p) => p.id == place.id); // ✅ remove from list
    } else {
      await supabase.from('saved_places').upsert({
        'user_id': userId,
        'provider_place_id': place.id,
        'name': place.name,
        'address': place.address,
        'categories': place.categories,
      });
      savedPlaces.add(place); // ✅ add to list
    }

    notifyListeners();
  }

  Future<void> deleteSavedPlace(String placeId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // optimistic remove
    final removedIndex = savedPlaces.indexWhere((p) => p.id == placeId);
    Place? removed;
    if (removedIndex != -1) {
      removed = savedPlaces.removeAt(removedIndex);
      notifyListeners();
    }


      await supabase
          .from('saved_places')
          .delete()
          .eq('user_id', user.id)
          .eq('provider_place_id', placeId);
    }


  Future<void> fetchSavedPlaces() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final rows = await supabase
          .from('saved_places')
          .select('provider_place_id, name, address, categories, created_at')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final list = (rows as List).cast<Map<String, dynamic>>();

      savedPlaces
        ..clear()
        ..addAll(list.map((r) {
          return Place(
            id: r['provider_place_id'] as String,
            name: (r['name'] as String?) ?? 'Unnamed',
            address: (r['address'] as String?) ?? '',
            location: const LatLng(0, 0),
            categories: (r['categories'] as List?)?.cast<String>() ?? [],
          );
        }));


    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  // Auth logic

  Future<void> signInEmail (String email, String password) async {
    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    await fetchSavedPlaces();
    if (res.user == null) {
      throw Exception('Wrong credentials');
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }



  // Votes aka Likes/Dislike logic
  final Map<String, String?> _userVotes = {};
  final Map<String, ({int likes, int dislikes})> _counts = {};

  String? getUserVote(String providerPlaceId) => _userVotes[providerPlaceId];
  int getLikes(String providerPlaceId) => _counts[providerPlaceId]?.likes ?? 0;
  int getDislikes(String providerPlaceId) => _counts[providerPlaceId]?.dislikes ?? 0;

  Future<void> loadVotes(String providerPlaceId) async {
    final userId = supabase.auth.currentUser?.id;

    final votesRes = await supabase
        .from('place_votes')
        .select('vote, user_id')
        .eq('provider_place_id', providerPlaceId);

    final list = votesRes as List;

    _counts[providerPlaceId] = (
    likes: list.where((r) => r['vote'] == 'like').length,
    dislikes: list.where((r) => r['vote'] == 'dislike').length,
    );

    if (userId != null) {
      final userVote = list
          .where((r) => r['user_id'] == userId)
          .map((r) => r['vote'] as String?)
          .firstOrNull;
      _userVotes[providerPlaceId] = userVote;
    }
    notifyListeners();
  }

  Future<void> vote(String providerPlaceId, String vote) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final current = _userVotes[providerPlaceId];

    if (current == vote) {
      await supabase
          .from('place_votes')
          .delete()
          .eq('user_id', userId)
          .eq('provider_place_id', providerPlaceId);
      _userVotes[providerPlaceId] = null;
    } else {
      await supabase.from('place_votes').upsert(
        {
          'user_id': userId,
          'provider_place_id': providerPlaceId,
          'vote': vote,
        },
        onConflict: 'user_id, provider_place_id',
      );
      _userVotes[providerPlaceId] = vote;
    }

    // Refresh counts
    final updatedRes = await supabase
        .from('place_votes')
        .select('vote')
        .eq('provider_place_id', providerPlaceId);

    final updated = updatedRes as List;
    _counts[providerPlaceId] = (
    likes: updated.where((r) => r['vote'] == 'like').length,
    dislikes: updated.where((r) => r['vote'] == 'dislike').length,
    );

    notifyListeners();
  }
}
