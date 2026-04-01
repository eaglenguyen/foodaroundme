import 'package:flutter/cupertino.dart';
import 'package:foodaroundme/main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../map/model/place.dart';
import '../../service/subscription/subscription_viewmodel.dart';



class AuthViewModel extends ChangeNotifier{
  final SupabaseClient _supabase; // ✅ injected, not global

  AuthViewModel({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client; // ✅ defaults to real client


  bool isLoading = false;
  String? error;
  String? username;
  String? bio;
  User? get currentUser => _supabase.auth.currentUser;
  final List<Place> savedPlaces = [];
  bool isSaved(String providerPlaceId) =>
      savedPlaces.any((p) => p.id == providerPlaceId);



  Future<void> loadProfileTable() async {
    if (currentUser == null) return;


    final row = await supabase
      .from('profiles')
      .select('username, bio')
      .eq('id', currentUser!.id)
      .maybeSingle();

    username = row?['username'] as String?;
    bio = row?['bio'] as String?;
    notifyListeners();
  }

  // Also handles duplicate Emails
  Future<void> seedProfileIfMissingFromGoogle() async {
    if (currentUser == null) return;

    // Load current profile row
    final row = await supabase
        .from('profiles')
        .select('username')
        .eq('id', currentUser!.id)
        .maybeSingle();

    final existing = (row?['username'] as String?)?.trim();

    // Pull google name from metadata as a one-time seed
    final googleName = (currentUser!.userMetadata?['full_name'] ?? 'null')?.toString().trim();

    // If these conditions are met, make the username (in profiles table) as google name
    if ((existing == null || existing.isEmpty) &&
        googleName != null &&
        googleName.isNotEmpty) {
      await supabase
          .from('profiles')
          .update({'username': googleName})
          .eq('id', currentUser!.id);
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
      // await Purchases.logOut();

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

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Google sign-in failed');
      }

      await _handlePostLogin(user);

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




  Future<void> savePlace(Place place) async {
    if (currentUser == null) return;
    final userId = currentUser!.id;


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
    if (currentUser == null) return;

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
          .eq('user_id', currentUser!.id)
          .eq('provider_place_id', placeId);
    }


  Future<void> fetchSavedPlaces() async {

    if (currentUser == null) {
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final rows = await _supabase
          .from('saved_places')
          .select('provider_place_id, name, address, categories, created_at')
          .eq('user_id', currentUser!.id)
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
    final res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = res.user;

    if (user == null) {
      throw Exception('Wrong credentials');
    }

    await _handlePostLogin(user);

    await fetchSavedPlaces();


  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }





  // Votes aka Likes/Dislike logic
  final Map<String, String?> _userVotes = {};
  final Map<String, ({int likes, int dislikes})> _counts = {};

  String? getUserVote(String providerPlaceId) => _userVotes[providerPlaceId];
  int getLikes(String providerPlaceId) => _counts[providerPlaceId]?.likes ?? 0;
  int getDislikes(String providerPlaceId) => _counts[providerPlaceId]?.dislikes ?? 0;

  Future<void> loadVotes(String providerPlaceId) async {
    final userId = _supabase.auth.currentUser?.id;

    final votesRes = await _supabase
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
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return; // click is null if not logged in

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


  Future<void> _handlePostLogin(User user) async {
    await Purchases.logIn(user.id);

    final subscriptionVM = Provider.of<SubscriptionViewModel>(
      navigatorKey.currentContext!,
      listen: false,
    );

    await subscriptionVM.checkSubscription();
  }



  // ✅ Only used in tests
  @visibleForTesting
  void testSetVote(String providerPlaceId, String? vote) {
    _userVotes[providerPlaceId] = vote;
  }

  @visibleForTesting
  void testSetCounts(String providerPlaceId, {required int likes, required int dislikes}) {
    _counts[providerPlaceId] = (likes: likes, dislikes: dislikes);
  }

  bool get isLoggedIn => _supabase.auth.currentUser != null;

}
