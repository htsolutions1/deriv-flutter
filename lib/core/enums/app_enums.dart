/// Application-wide enumerations.
///
/// All enums are pure Dart types — no imports required.
/// Used across features, providers, and shared widgets.

/// WebSocket / API connection state.
enum ConnectionStatus { connected, disconnected, connecting, error }

/// Trading bot operational state.
enum BotStatus { idle, running, stopped, error }

/// Direction of a trade or signal.
enum TradeDirection { buy, sell }

/// Lifecycle state of a trading signal.
enum SignalStatus { pending, executed, failed, expired }

/// Outcome of a completed trade.
enum TradeOutcome { win, loss, open }

/// Filter option for the Active Trades screen.
enum TradeFilter { all, running, closed }

/// Filter option for the Trade History screen.
enum HistoryFilter { all, win, loss }
