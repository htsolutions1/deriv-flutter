import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ht_bot/core/models/oauth_state.dart';

/// Notifier that manages [OAuthState] through the PKCE OAuth flow.
///
/// Initialized with [OAuthState.initial()] — unauthenticated, not loading,
/// no error. State transitions are driven by UI actions on the Login screen
/// and by the OAuth callback handler.
///
/// Requirements: 12.5
class OAuthNotifier extends StateNotifier<OAuthState> {
  OAuthNotifier() : super(OAuthState.initial());

  /// Marks the OAuth flow as in-progress (e.g., URL was launched).
  void startLoading() => state = state.copyWith(isLoading: true, clearError: true);

  /// Records a successful authentication after the PKCE exchange completes.
  void setAuthenticated() => state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        clearError: true,
      );

  /// Surfaces an error that occurred during the OAuth flow.
  void setError(String message) => state = state.copyWith(
        isLoading: false,
        error: message,
      );

  /// Resets to the initial unauthenticated state (e.g., on logout).
  void reset() => state = OAuthState.initial();
}

/// Global provider for OAuth / authentication state.
///
/// The Login screen reads this to show loading indicators, error messages,
/// and to redirect on successful authentication.
final oauthProvider = StateNotifierProvider<OAuthNotifier, OAuthState>(
  (ref) => OAuthNotifier(),
);
