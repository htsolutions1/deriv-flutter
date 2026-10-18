import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global loading overlay toggle.
///
/// Set to `true` to show the [LoadingOverlay] widget over the current screen.
/// Defaults to `false`.
/// Requirements: 10.6
final loadingProvider = StateProvider<bool>(
  (ref) => false,
);
