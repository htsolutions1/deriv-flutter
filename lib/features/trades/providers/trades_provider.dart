import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ht_bot/core/enums/app_enums.dart';
import 'package:ht_bot/core/models/trade_model.dart';

/// Notifier that manages the list of active trades.
///
/// Initialized with an empty list; trades are added / removed as the
/// trading engine pushes updates.
class TradesNotifier extends StateNotifier<List<TradeModel>> {
  TradesNotifier() : super([]);

  /// Replaces the entire trades list.
  void setTrades(List<TradeModel> trades) => state = List.unmodifiable(trades);

  /// Appends a single trade to the list.
  void addTrade(TradeModel trade) => state = [...state, trade];

  /// Removes the trade with the given [id], if present.
  void removeTrade(String id) =>
      state = state.where((t) => t.id != id).toList();
}

/// Global provider for the active trades list.
final tradesProvider =
    StateNotifierProvider<TradesNotifier, List<TradeModel>>(
  (ref) => TradesNotifier(),
);

/// Filter applied to the Active Trades screen list.
///
/// Defaults to [TradeFilter.all] so all trades are visible on first load.
final tradeFilterProvider = StateProvider<TradeFilter>(
  (ref) => TradeFilter.all,
);
