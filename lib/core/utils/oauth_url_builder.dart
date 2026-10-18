/// Builds OAuth 2.0 authorization URLs for the Deriv PKCE flow.
///
/// Requirements: 2.5
abstract final class OAuthUrlBuilder {
  static const String _baseUrl = 'https://auth.deriv.com/oauth2/auth';

  /// Constructs the authorization URL with all required PKCE query parameters.
  ///
  /// Parameters:
  /// - [clientId]: The OAuth client identifier.
  /// - [redirectUri]: The URI to redirect to after authorization.
  /// - [state]: A random value to protect against CSRF attacks.
  /// - [codeChallenge]: The SHA-256 base64url-encoded code challenge.
  /// - [scope]: Space-separated list of requested scopes (default: `trade account_manage`).
  static Uri buildLoginUrl({
    required String clientId,
    required String redirectUri,
    required String state,
    required String codeChallenge,
    String scope = 'trade account_manage',
  }) {
    return Uri.parse(_baseUrl).replace(queryParameters: {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scope,
      'state': state,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
    });
  }
}
