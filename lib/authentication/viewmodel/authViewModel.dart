import 'package:flutter/cupertino.dart';
import 'package:foodaroundme/app_root.dart';
import 'package:foodaroundme/main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../model/place.dart';


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
    /// TODO: update the Web client ID with your own.
    ///
    /// Web Client ID that you registered with Google Cloud.
    const webClientId = '960770120495-d6d049dnh3do3s9ag3msavu7mp202roi.apps.googleusercontent.com';

    /// TODO: update the iOS client ID with your own.
    ///
    /// iOS Client ID that you registered with Google Cloud.
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

    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }


  }

  Future<void> savePlace(Place place) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('saved_places').upsert({
      'user_id': supabase.auth.currentUser!.id,
      'provider_place_id': place.id,
      'name': place.name,
      'address': place.address,
      'categories': place.categories,
    });
  }

  Future<void> deleteSavedPlace(String placeId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // optimistic remove
    final removedIndex = savedPlaces.indexWhere((p) => p.id == placeId);
    Place? removed;
    if (removedIndex != -1) {
      removed = savedPlaces.removeAt(removedIndex);
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





  Future<void> signInEmail (String email, String password) async {
    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (res.user == null) {
      throw Exception('Wrong credentials');
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

}