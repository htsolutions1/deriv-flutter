import 'package:flutter/foundation.dart';

/// Immutable state model for the OAuth authentication flow.
///
/// Tracks loading state, authentication status, and any error that
/// surfaced during the PKCE OAuth exchange.
///
/// Requirements: 2.6
@immutable
class OAuthState {
  /// Whether an OAuth operation (launch, callback handling) is in progress.
  final bool isLoading;

  /// Error message from a failed OAuth step. Null when no error is present.
  final String? error;

  /// Whether the user has successfully completed the OAuth flow.
  final bool isAuthenticated;

  const OAuthState({
    required this.isLoading,
    this.error,
    required this.isAuthenticated,
  });

  /// Returns the initial unauthenticated state before any OAuth action.
  factory OAuthState.initial() => const OAuthState(
        isLoading: false,
        error: null,
        isAuthenticated: false,
      );

  /// Returns a copy of this state with the provided fields replaced.
  ///
  /// Pass [clearError] as `true` to explicitly set [error] back to null.
  OAuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool clearError = false,
  }) {
    return OAuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OAuthState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          error == other.error &&
          isAuthenticated == other.isAuthenticated;

  @override
  int get hashCode => Object.hash(isLoading, error, isAuthenticated);

  @override
  String toString() => 'OAuthState('
      'isLoading: $isLoading, '
      'error: $error, '
      'isAuthenticated: $isAuthenticated)';
}
