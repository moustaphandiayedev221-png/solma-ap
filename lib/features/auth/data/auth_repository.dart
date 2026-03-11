import 'dart:async';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';
import 'native_auth_service.dart';

/// Repository d'authentification - Supabase Auth (JWT)
/// Aligné sur l'approche shoes :
/// - iOS Google : tentative native, fallback OAuth WebView
/// - Android Google : OAuth WebView uniquement
/// - iOS Apple : tentative native, fallback OAuth WebView
/// - Android Apple : OAuth WebView uniquement
class AuthRepository {
  AuthRepository([SupabaseClient? client])
      : _client = client ?? supabaseClient,
        _nativeAuth = NativeAuthService(client ?? supabaseClient);

  final SupabaseClient _client;
  final NativeAuthService _nativeAuth;

  static bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
      emailRedirectTo: null,
    );
  }

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Connexion avec Google.
  /// iOS : tentative native, fallback OAuth WebView (ex. iPad).
  /// Android : OAuth WebView uniquement (évite DEVELOPER_ERROR API 10).
  Future<void> signInWithGoogle() async {
    if (_isIos && NativeAuthService.isGoogleNativeAvailable) {
      try {
        await _nativeAuth.signInWithGoogle();
        return;
      } catch (e) {
        if (e is UserCanceledAuthException) rethrow;
        // Fallback OAuth WebView
        await _signInWithGoogleOAuth();
        return;
      }
    }
    await _signInWithGoogleOAuth();
  }

  /// Connexion avec Apple.
  /// iOS : tentative native, fallback OAuth WebView.
  /// Android : OAuth WebView uniquement.
  Future<void> signInWithApple() async {
    if (_isIos && NativeAuthService.isAppleNativeAvailable) {
      try {
        await _nativeAuth.signInWithApple();
        return;
      } catch (e) {
        if (e is UserCanceledAuthException) rethrow;
        await _signInWithAppleOAuth();
        return;
      }
    }
    await _signInWithAppleOAuth();
  }

  Future<void> _signInWithGoogleOAuth() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.colways://login-callback/',
      authScreenLaunchMode: LaunchMode.inAppWebView,
    );
    await _waitForAuthCompletion();
  }

  Future<void> _signInWithAppleOAuth() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.supabase.colways://login-callback/',
      authScreenLaunchMode: LaunchMode.inAppWebView,
    );
    await _waitForAuthCompletion();
  }

  /// Attend que l'authentification OAuth soit complétée.
  Future<void> _waitForAuthCompletion() async {
    const timeoutSeconds = 90;
    final completer = Completer<void>();
    StreamSubscription<AuthState>? subscription;
    Timer? timeoutTimer;

    subscription = _client.auth.onAuthStateChange.listen((state) {
      if (state.session != null) {
        completer.complete();
      }
    });

    timeoutTimer = Timer(Duration(seconds: timeoutSeconds), () {
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException(
            'La connexion a pris trop de temps. Vérifiez votre connexion et réessayez.',
          ),
        );
      }
    });

    try {
      await completer.future;
    } finally {
      await subscription.cancel();
      timeoutTimer.cancel();
    }
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> resetPassword(String email) =>
      _client.auth.resetPasswordForEmail(email);

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }
}
