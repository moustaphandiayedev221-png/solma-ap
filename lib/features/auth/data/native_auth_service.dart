import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/auth_config.dart';
import '../../../../core/providers/supabase_provider.dart';

/// Exception levée lorsque l'utilisateur annule la connexion (Google ou Apple).
class UserCanceledAuthException implements Exception {
  @override
  String toString() => 'Connexion annulée';
}

/// Service de connexion native Google et Apple.
/// Aligné sur l'approche shoes :
/// - iOS Google : flux natif (serverClientId = googleIosClientId ou googleWebClientId)
/// - iOS Apple : flux natif avec nonce SHA256 hex
/// - Android : pas de natif (OAuth WebView uniquement, pour éviter DEVELOPER_ERROR API 10)
class NativeAuthService {
  NativeAuthService([SupabaseClient? client])
      : _client = client ?? supabaseClient;

  final SupabaseClient _client;

  static bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  /// Connexion native Google (iOS uniquement — Android utilise OAuth WebView).
  /// Utilise serverClientId = googleIosClientId sur iOS pour éviter l'erreur Custom scheme URIs.
  Future<AuthResponse> signInWithGoogle() async {
    if (!_isIos) {
      throw UnsupportedError(
        'Connexion native Google : iOS uniquement. Android utilise OAuth WebView.',
      );
    }
    final iosId = AuthConfig.googleIosClientId;
    final webId = AuthConfig.googleWebClientId;
    if (iosId.isEmpty && webId.isEmpty) {
      throw UnsupportedError(
        'GOOGLE_IOS_CLIENT_ID ou GOOGLE_WEB_CLIENT_ID requis pour la connexion Google.',
      );
    }

    final serverClientId = iosId.isNotEmpty ? iosId : webId;
    final googleSignIn = GoogleSignIn(serverClientId: serverClientId);

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw UserCanceledAuthException();
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Token Google introuvable');
    }
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token Google introuvable (requis pour Supabase)');
    }

    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  /// Connexion native Apple (iOS uniquement).
  /// Le nonce doit être hashé en SHA256 (hex) pour Apple, puis transmis en clair à Supabase.
  Future<AuthResponse> signInWithApple() async {
    if (!_isIos) {
      throw UnsupportedError(
        'Connexion native Apple : iOS requis. Android utilise OAuth WebView.',
      );
    }

    final rawNonce = _client.auth.generateRawNonce();
    final hashedNonce = _sha256Hex(rawNonce);

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Token Apple introuvable');
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      // Apple ne fournit le nom qu'au premier sign-in — on le sauvegarde
      if (credential.givenName != null || credential.familyName != null) {
        final fullName = [
          credential.givenName,
          credential.familyName,
        ].whereType<String>().join(' ').trim();
        if (fullName.isNotEmpty && response.user != null) {
          await _client.auth.updateUser(
            UserAttributes(
              data: {
                'full_name': fullName,
                'given_name': credential.givenName,
                'family_name': credential.familyName,
              },
            ),
          );
        }
      }

      return response;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw UserCanceledAuthException();
      }
      rethrow;
    }
  }

  /// Hash SHA256 en hex (Apple attend ce format pour le nonce).
  static String _sha256Hex(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.bytes
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  /// Connexion native Google disponible : iOS avec Client ID configuré.
  static bool get isGoogleNativeAvailable =>
      _isIos &&
      (AuthConfig.googleIosClientId.isNotEmpty ||
          AuthConfig.googleWebClientId.isNotEmpty);

  /// Connexion native Apple disponible : iOS uniquement.
  static bool get isAppleNativeAvailable => _isIos;
}
