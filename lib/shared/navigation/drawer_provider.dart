import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls whether the [DrawerOverlay] is currently open.
///
/// Set to `true` to slide the drawer in; `false` to dismiss it.
/// Defaults to `false`.
/// Requirements: 3.6
final drawerOpenProvider = StateProvider<bool>(
  (ref) => false,
);
