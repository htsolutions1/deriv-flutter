import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ht_bot/core/models/signal_model.dart';

/// Notifier that manages the list of incoming trading signals.
///
/// Initialized with an empty list; signals are prepended as the signal
/// monitor receives them from the Python engine.
class SignalsNotifier extends StateNotifier<List<SignalModel>> {
  SignalsNotifier() : super([]);

  /// Replaces the entire signals list.
  void setSignals(List<SignalModel> signals) =>
      state = List.unmodifiable(signals);

  /// Prepends a new signal so the most recent appears at the top.
  void addSignal(SignalModel signal) => state = [signal, ...state];

  /// Removes the signal with the given [id], if present.
  void removeSignal(String id) =>
      state = state.where((s) => s.id != id).toList();
}

/// Global provider for the signals list.
final signalsProvider =
    StateNotifierProvider<SignalsNotifier, List<SignalModel>>(
  (ref) => SignalsNotifier(),
);
