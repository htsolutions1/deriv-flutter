import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../models/pkce_params.dart';

/// Generates PKCE (Proof Key for Code Exchange) parameters for OAuth 2.0.
///
/// Requirements: 2.5, 2.6
abstract final class PkceGenerator {
  /// Generates a complete set of PKCE parameters: verifier, challenge, and state.
  static PkceParams generate() {
    final verifier = _generateVerifier();
    final challenge = _sha256Base64Url(verifier);
    final state = _generateState();
    return PkceParams(
      codeVerifier: verifier,
      codeChallenge: challenge,
      state: state,
    );
  }

  /// Generates a cryptographically random code verifier.
  ///
  /// Produces 64 random bytes, base64url-encodes them, strips padding,
  /// and truncates to 64 characters.
  static String _generateVerifier() {
    final bytes = List<int>.generate(64, (_) => Random.secure().nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '').substring(0, 64);
  }

  /// Computes BASE64URL(SHA256(input)) with no padding characters.
  ///
  /// Used to derive the code challenge from the code verifier.
  static String _sha256Base64Url(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  /// Generates a cryptographically random state string as a hex-encoded value.
  ///
  /// Produces 16 random bytes and encodes each as a 2-character lowercase hex string.
  static String _generateState() {
    final bytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
