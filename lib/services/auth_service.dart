import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Wraps Firebase Auth for both Google Sign-In and Phone OTP.
///
/// Sign-in is entirely OPTIONAL in CardamomAI — every core feature
/// (scanning, the library, history, care guide) already works fully
/// offline with no account. This service exists to let a signed-in
/// state exist for whoever wants one, without gatekeeping the app
/// behind it. See [SettingsController] usage in the Settings screen
/// for how sign-in state is surfaced.
///
/// Uses the google_sign_in 7.x API (a rewrite from 6.x): the client
/// is a singleton (`GoogleSignIn.instance`), requires an explicit
/// `initialize()` call before use, and signals user cancellation via
/// [GoogleSignInException] rather than returning null.
class AuthService extends ChangeNotifier {
  bool _googleInitialized = false;

  /// Firebase.initializeApp() may not have been called yet (e.g. if
  /// `flutterfire configure` hasn't been run for this project). Every
  /// other feature in CardamomAI works with no Firebase involvement
  /// at all, so this guards every entry point here rather than
  /// letting a missing Firebase config crash the whole app.
  FirebaseAuth? _authOrNull() {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  bool get isAvailable => _authOrNull() != null;
  User? get currentUser => _authOrNull()?.currentUser;
  bool get isSignedIn => currentUser != null;
  Stream<User?> get authStateChanges => _authOrNull()?.authStateChanges() ?? const Stream<User?>.empty();

  AuthService() {
    _authOrNull()?.authStateChanges().listen((_) => notifyListeners());
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize();
    _googleInitialized = true;
  }

  /// Signs in with Google. Returns null if the user cancelled the
  /// picker (not treated as an error) — rethrows anything else,
  /// including a [StateError] if Firebase isn't configured yet.
  Future<UserCredential?> signInWithGoogle() async {
    final auth = _authOrNull();
    if (auth == null) {
      throw StateError('Sign-in isn\'t set up yet for this build.');
    }
    try {
      await _ensureGoogleInitialized();
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
      return await auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  /// Starts phone verification. Firebase will either auto-verify
  /// (some Android devices can detect the SMS automatically, calling
  /// [onAutoVerified] directly) or send a code and call [onCodeSent]
  /// with a verification ID the caller must hold onto for
  /// [verifyOtpAndSignIn].
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException error) onError,
    required void Function(UserCredential credential) onAutoVerified,
  }) async {
    final auth = _authOrNull();
    if (auth == null) {
      throw StateError('Sign-in isn\'t set up yet for this build.');
    }
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        final result = await auth.signInWithCredential(credential);
        onAutoVerified(result);
      },
      verificationFailed: onError,
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // No action needed — if the user is still on the OTP screen,
        // they can simply enter the code manually.
      },
    );
  }

  Future<UserCredential> verifyOtpAndSignIn({
    required String verificationId,
    required String smsCode,
  }) async {
    final auth = _authOrNull();
    if (auth == null) {
      throw StateError('Sign-in isn\'t set up yet for this build.');
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _authOrNull()?.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Not signed in with Google, or Google client not initialized -
      // fine either way, Firebase sign-out already happened above.
    }
  }
}
