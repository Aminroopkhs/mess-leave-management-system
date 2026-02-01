import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleAuthService {
  // Configure Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Web Client ID from .env - this helps Android get the ID token
    serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
  );

  /// Get the current Google account if already signed in
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Sign in with Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      print('Error signing in with Google: $error');
      return null;
    }
  }

  /// Get the ID token for backend verification
  Future<String?> getIdToken() async {
    try {
      final account = _googleSignIn.currentUser;
      if (account == null) {
        print('No user signed in');
        return null;
      }

      final authentication = await account.authentication;
      return authentication.idToken;
    } catch (error) {
      print('Error getting ID token: $error');
      return null;
    }
  }

  /// Get the access token
  Future<String?> getAccessToken() async {
    try {
      final account = _googleSignIn.currentUser;
      if (account == null) {
        print('No user signed in');
        return null;
      }

      final authentication = await account.authentication;
      return authentication.accessToken;
    } catch (error) {
      print('Error getting access token: $error');
      return null;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      print('Error signing out: $error');
    }
  }

  /// Disconnect from Google (revokes access)
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (error) {
      print('Error disconnecting: $error');
    }
  }

  /// Check if user is currently signed in
  bool isSignedIn() {
    return _googleSignIn.currentUser != null;
  }

  /// Sign in silently (without showing UI) if previously signed in
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (error) {
      print('Error signing in silently: $error');
      return null;
    }
  }
}
