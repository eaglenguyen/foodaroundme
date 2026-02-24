import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthViewModel extends ChangeNotifier{
  final SupabaseClient _supabase = Supabase.instance.client;

  bool isLoading = false;
  String? error;

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
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }


  }

  Future<void> signUpEmail (String email, String password) async {
    final res = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (res.user != null) {
      throw Exception('Sign-up failed');
    }
  }

  Future<void> signInEmail (String email, String password) async {
    final res = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    if (res.user != null) {
      throw Exception('Wrong credentials');
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

}