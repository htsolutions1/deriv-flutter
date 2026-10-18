import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ht_bot/core/enums/app_enums.dart';
import 'package:ht_bot/core/models/trade_model.dart';

/// Notifier that manages the list of historical (closed) trades.
///
/// Initialized with an empty list; history is populated when the
/// trade history screen is loaded or refreshed.
class HistoryNotifier extends StateNotifier<List<TradeModel>> {
  HistoryNotifier() : super([]);

  /// Replaces the entire history list.
  void setHistory(List<TradeModel> history) =>
      state = List.unmodifiable(history);

  /// Appends a single closed trade to the history.
  void addEntry(TradeModel trade) => state = [...state, trade];

  /// Clears all history entries.
  void clear() => state = [];
}

/// Global provider for the trade history list.
final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<TradeModel>>(
  (ref) => HistoryNotifier(),
);

/// Filter applied to the Trade History screen list.
///
/// Defaults to [HistoryFilter.all] so the full history is visible on first load.
final historyFilterProvider = StateProvider<HistoryFilter>(
  (ref) => HistoryFilter.all,
);
