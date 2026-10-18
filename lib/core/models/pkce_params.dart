import 'package:flutter/foundation.dart';

/// Holds the PKCE parameter set generated for an OAuth 2.0 authorization request.
///
/// Requirements: 2.5
@immutable
class PkceParams {
  final String codeVerifier;
  final String codeChallenge;
  final String state;

  const PkceParams({
    required this.codeVerifier,
    required this.codeChallenge,
    required this.state,
  });
}
