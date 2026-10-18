import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stub notifier for account-related actions.
///
/// No state is needed at this stage — actions such as logout, account
/// switching, and API token management are handled via side-effects
/// (navigation, dialogs). State will be added in a future task when
/// account data is available from the Deriv API.
class AccountNotifier extends StateNotifier<void> {
  AccountNotifier() : super(null);
}

/// Global provider for account actions.
final accountProvider = StateNotifierProvider<AccountNotifier, void>(
  (ref) => AccountNotifier(),
);
