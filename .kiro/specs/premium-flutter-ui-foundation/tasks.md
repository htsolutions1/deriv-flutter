# Implementation Plan: HT BOT Premium Flutter UI Foundation

## Overview

This plan breaks the UI shell into 11 incremental milestones that progress from project scaffold → theme & constants → routing → core models & providers → shared widget library → screen implementations → animation polish → PKCE utilities → final wiring. Each milestone produces runnable, integrated code. No backend calls are made anywhere; all data-dependent areas render typed empty states.

Language: **Dart / Flutter**

---

## Tasks

- [x] 1. Flutter project scaffold and pubspec
  - [x] 1.1 Create `pubspec.yaml` with all pinned dependencies
    - Add `flutter_screenutil: ^5.9.0`, `flex_color_scheme: ^7.3.1`, `go_router: ^14.2.7`, `flutter_riverpod: ^2.5.1`, `riverpod_annotation: ^2.3.5`, `flutter_animate: ^4.5.0`, `glassmorphism_ui: ^0.3.0`, `blur: ^3.1.0`, `fl_chart: ^0.68.0`, `google_fonts: ^6.2.1`, `gap: ^3.0.1`, `intl: ^0.19.0`, `flutter_svg: ^2.0.10+1`, `phosphor_flutter: ^2.1.0`, `lucide_icons_flutter: ^1.0.29`, `lottie: ^3.1.0`, `flutter_staggered_grid_view: ^0.7.0`, `flutter_secure_storage: ^9.2.2`, `url_launcher: ^6.3.0`, `crypto: ^3.0.3`
    - Add `dev_dependencies`: `mockito: ^5.4.4`, `build_runner: ^2.4.11`, `riverpod_generator: ^2.4.0`, `flutter_test`
    - Lock portrait orientation in `android/app/src/main/AndroidManifest.xml`
    - _Requirements: 1.1, 1.4, 12.1_

  - [x] 1.2 Create `lib/main.dart` with app entry point
    - `WidgetsFlutterBinding.ensureInitialized()`
    - `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`
    - Wrap in `ProviderScope`
    - `ScreenUtilInit(designSize: Size(390, 844), minTextAdapt: true, splitScreenMode: false)` wrapping `MaterialApp.router`
    - Reference `AppTheme.lightTheme()` and `AppRouter.router` (stubs acceptable at this stage)
    - _Requirements: 1.1, 1.4, 1.6_

  - [x] 1.3 Create `lib/core/constants/` barrel and folder structure
    - Create all top-level directories: `lib/core/constants/`, `lib/core/enums/`, `lib/core/models/`, `lib/core/providers/`, `lib/core/utils/`, `lib/theme/`, `lib/routing/`, `lib/shared/widgets/`, `lib/shared/cards/`, `lib/shared/buttons/`, `lib/shared/dialogs/`, `lib/shared/navigation/`, `lib/shared/tiles/`, `lib/shared/animations/`, `lib/features/login/providers/`, `lib/features/dashboard/providers/`, `lib/features/trades/providers/`, `lib/features/signals/providers/`, `lib/features/settings/providers/`, `lib/features/account/providers/`, `lib/features/history/providers/`
    - Create `.gitkeep` placeholder files or empty barrel `index.dart` files in each directory
    - _Requirements: 12.1_

- [x] 2. Theme system and color constants
  - [x] 2.1 Create `lib/core/constants/app_colors.dart`
    - Define `abstract final class AppColors` with all 12 color constants: `background (#EAF4FF)`, `surface (rgba 255,255,255,0.55)`, `accent (#D4AF37)`, `primaryText (#243447)`, `secondaryText (#64748B)`, `success (#22C55E)`, `loss (#EF4444)`, `border (rgba 255,255,255,0.35)`, semantic aliases `buyColor`, `sellColor`, `connected`, `disconnected (#F97316)`, `error`
    - _Requirements: 1.2, 12.3_

  - [x] 2.2 Create `lib/theme/text_styles.dart` and `lib/theme/app_theme.dart`
    - Define `AppTheme.lightTheme()` using `FlexThemeData.light` with `AppColors.accent` as primary and `AppColors.background` as surface seed
    - Define `GoogleFonts.interTextTheme()` as the base text theme
    - Define named text style aliases in `text_styles.dart` (e.g., `headlineLarge`, `bodyMedium`, `labelSmall`)
    - _Requirements: 1.2, 1.5, 12.4_

  - [x] 2.3 Create `lib/core/constants/app_sizes.dart` and `lib/core/constants/app_strings.dart`
    - `AppSizes`: card radius, default padding, button height, icon sizes as named constants using `.r`/`.w`/`.h` conventions documented in comments
    - `AppStrings`: all UI string literals (screen titles, empty state labels, button labels) to avoid magic strings
    - _Requirements: 12.2, 12.3_

- [x] 3. Core enums, models, and domain types
  - [x] 3.1 Create `lib/core/enums/app_enums.dart`
    - Define all seven enums: `ConnectionStatus`, `BotStatus`, `TradeDirection`, `SignalStatus`, `TradeOutcome`, `TradeFilter`, `HistoryFilter`
    - _Requirements: 4.5, 5.1, 6.1, 9.1_

  - [x] 3.2 Create domain model files
    - `lib/core/models/trade_model.dart`: `@immutable TradeModel` with fields `id`, `direction`, `stake`, `entryPrice`, `duration`, `takeProfit`, `stopLoss`, `currentPnl`, `outcome`, `openedAt`
    - `lib/core/models/signal_model.dart`: `@immutable SignalModel` with fields `id`, `direction`, `source`, `timestamp`, `status`
    - `lib/core/models/pkce_params.dart`: `@immutable PkceParams` with `codeVerifier`, `codeChallenge`, `state`
    - _Requirements: 5.4, 6.4, 2.5_

  - [x] 3.3 Create provider state models
    - `lib/features/dashboard/providers/dashboard_state.dart`: `DashboardState` with nullable `balance`, `todayProfit`, `winRate`; non-null `activeTrades` (0), `tradesToday` (0), `botStatus` (idle), `connectionStatus` (disconnected); factory `DashboardState.empty()`
    - `lib/features/settings/providers/settings_state.dart`: `SettingsState` with typed fields for all 15 settings and factory `SettingsState.defaults()`
    - `lib/core/models/oauth_state.dart`: `OAuthState` with `isLoading`, `error` (String?), `isAuthenticated`; factory `OAuthState.initial()`
    - _Requirements: 4.1–4.5, 7.1–7.3, 2.6_

- [x] 4. Riverpod providers
  - [x] 4.1 Create core providers
    - `lib/core/providers/connection_provider.dart`: `connectionStatusProvider` as `StateProvider<ConnectionStatus>` defaulting to `disconnected`
    - `lib/core/providers/loading_provider.dart`: `loadingProvider` as `StateProvider<bool>` defaulting to `false`
    - `lib/shared/navigation/drawer_provider.dart`: `drawerOpenProvider` as `StateProvider<bool>` defaulting to `false`
    - _Requirements: 3.10, 10.6, 3.6_

  - [x] 4.2 Create feature providers
    - `lib/features/dashboard/providers/dashboard_provider.dart`: `DashboardNotifier` extends `StateNotifier<DashboardState>` initialized with `DashboardState.empty()`
    - `lib/features/trades/providers/trades_provider.dart`: `TradesNotifier` extends `StateNotifier<List<TradeModel>>` initialized with `[]`; `tradeFilterProvider` as `StateProvider<TradeFilter>`
    - `lib/features/signals/providers/signals_provider.dart`: `SignalsNotifier` extends `StateNotifier<List<SignalModel>>` initialized with `[]`
    - `lib/features/history/providers/history_provider.dart`: `HistoryNotifier` extends `StateNotifier<List<TradeModel>>` initialized with `[]`; `historyFilterProvider` as `StateProvider<HistoryFilter>`
    - `lib/features/settings/providers/settings_provider.dart`: `SettingsNotifier` extends `StateNotifier<SettingsState>` initialized with `SettingsState.defaults()`
    - `lib/features/account/providers/account_provider.dart`: stub `AccountNotifier`
    - `lib/features/login/providers/oauth_provider.dart`: `OAuthNotifier` extends `StateNotifier<OAuthState>` initialized with `OAuthState.initial()`
    - _Requirements: 12.5, 4.5, 5.1_

- [x] 5. Routing
  - [x] 5.1 Create `lib/routing/app_router.dart`
    - Define `abstract final class AppRoutes` with seven string constants: `login`, `dashboard`, `trades`, `signals`, `settings`, `account`, `history`
    - Define `AppRouter.router` using `GoRouter` with `initialLocation: AppRoutes.login`
    - Add a `GoRoute` for `AppRoutes.login` pointing to `LoginScreen`
    - Add a `ShellRoute` wrapping `AuthenticatedShell` with six nested `GoRoute`s for all authenticated screens
    - Screens may be stubbed as `Placeholder()` widgets until feature tasks complete
    - _Requirements: 1.3, 3.4, 12.2_

- [x] 6. PKCE utilities
  - [x] 6.1 Create `lib/core/utils/pkce_generator.dart`
    - Implement `PkceGenerator.generate()` returning `PkceParams`
    - `_generateVerifier()`: 64-byte `Random.secure()` → `base64UrlEncode` → strip `=` → truncate to 64 chars
    - `_sha256Base64Url(String input)`: `utf8.encode` → `sha256.convert` → `base64UrlEncode` → strip `=`
    - `_generateState()`: 16-byte `Random.secure()` → hex string
    - _Requirements: 2.5, 2.6_

  - [x] 6.2 Create `lib/core/utils/oauth_url_builder.dart`
    - Implement `OAuthUrlBuilder.buildLoginUrl({clientId, redirectUri, state, codeChallenge, scope})`
    - Base URL: `https://auth.deriv.com/oauth2/auth`
    - Required query params: `response_type=code`, `client_id`, `redirect_uri`, `scope`, `state`, `code_challenge`, `code_challenge_method=S256`
    - _Requirements: 2.5_

  - [ ]* 6.3 Write property tests for PKCE utilities
    - **Property 1: PKCE Authorization URL Contains All Required Parameters** — for any `PkceParams`, assert all seven query params present in built URL
    - **Property 2: PKCE Parameters Are Unique Across Invocations** — for 100 independent `PkceGenerator.generate()` calls, assert no two `codeVerifier` or `state` values collide
    - **Property 13: PKCE Code Challenge Is Deterministically Derived from Verifier** — for any verifier, re-compute `BASE64URL(SHA256(verifier))` and assert equality with the returned `codeChallenge`
    - **Validates: Requirements 2.5, 2.6**

- [x] 7. Shared widget library — cards and utility widgets
  - [x] 7.1 Create `lib/shared/cards/glass_card.dart`
    - `GlassCard` accepts `child`, `borderRadius` (default 16), `blurSigma` (default 10), `opacity` (default 0.55), `padding`
    - Use `ClipRRect` + `BackdropFilter(filter: ImageFilter.blur(...))` + `Container` with `AppColors.surface` background and `AppColors.border` border
    - All radii via `.r`, all padding via `.w`
    - _Requirements: 10.1_

  - [ ]* 7.2 Write property test for GlassCard
    - **Property 12: GlassCard Renders Without Error for Any Valid Configuration** — use `flutter_test` to pump `GlassCard` with boundary values: `borderRadius` ∈ {0, 20, 40}, `blurSigma` ∈ {0, 15, 30}, `opacity` ∈ {0.0, 0.55, 1.0}; assert no exception thrown
    - **Validates: Requirements 10.1**

  - [x] 7.3 Create card variant widgets
    - `lib/shared/cards/status_card.dart`: `StatusCard(label, status, badgeColor)` wrapping `GlassCard`
    - `lib/shared/cards/profit_card.dart`: `ProfitCard(label, value, isPositive)` wrapping `GlassCard`; null value → "--"
    - `lib/shared/cards/statistic_card.dart`: `StatisticCard(label, value, chart)` wrapping `GlassCard`; null value → `EmptyState` in chart area
    - `lib/shared/cards/metric_tile.dart`: `MetricTile(label, value)` wrapping `GlassCard`
    - _Requirements: 10.2, 4.1–4.4_

  - [x] 7.4 Create utility widgets
    - `lib/shared/widgets/empty_state.dart`: `EmptyState(icon?, label, subLabel?)` — centered column
    - `lib/shared/widgets/loading_overlay.dart`: `LoadingOverlay` — full-screen scrim with `CircularProgressIndicator`; visibility driven by `loadingProvider`
    - `lib/shared/widgets/connection_badge.dart`: `ConnectionBadge(status)` — pill badge; color switch matching `AppColors` per status enum value
    - `lib/shared/widgets/status_badge.dart`: `StatusBadge(status, label)` — colored dot + pill
    - `lib/shared/widgets/sidebar_item.dart`: `SidebarItem(icon, label, selected, onTap)` — highlight selected with `AppColors.accent`
    - _Requirements: 10.6, 10.7, 10.8, 10.9, 10.10, 10.11_

  - [ ]* 7.5 Write unit tests for utility widgets
    - Test `ConnectionBadge` renders green for `connected`, orange for `disconnected`, amber for `connecting`, red for `error`
    - Test `EmptyState` shows label text
    - Test `SidebarItem` calls `onTap` callback when tapped
    - **Property 8: ConnectionBadge Color Matches ConnectionStatus** — assert color token per enum value
    - **Validates: Requirements 3.10, 10.7**

- [x] 8. Shared widget library — buttons
  - [x] 8.1 Create button widgets
    - `lib/shared/buttons/primary_button.dart`: `PrimaryButton(label, onPressed)` — `ElevatedButton` with `AppColors.accent` background, `AppColors.primaryText` foreground; height `48.h`; radius `12.r`
    - `lib/shared/buttons/secondary_button.dart`: `SecondaryButton(label, onPressed)` — `OutlinedButton` with `AppColors.surface` background, `AppColors.secondaryText` foreground
    - `lib/shared/buttons/animated_button.dart`: `AnimatedButton(child)` — wraps child with `flutter_animate` `.fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0)`; `GestureDetector.onTapDown` triggers `.scale(end: Offset(0.95, 0.95), duration: 80.ms)`
    - _Requirements: 10.3, 11.3_

- [x] 9. Shared widget library — navigation, tiles, and dialogs
  - [x] 9.1 Create navigation widgets
    - `lib/shared/navigation/bottom_nav_bar.dart`: `BottomNavBar` — 5 items (Dashboard, Trades, Signals, Settings, Account); active item uses `AppColors.accent`; inactive items use muted gray; taps call `context.go(route)`
    - `lib/shared/navigation/navigation_header.dart`: `NavigationHeader(title)` — hamburger icon left, screen title center, `ConnectionBadge` right; hamburger tap sets `drawerOpenProvider` to `true`
    - `lib/shared/navigation/drawer_overlay.dart`: `DrawerOverlay` + `DrawerPanel` — `AnimatedPositioned` sliding from `left: -280.w` to `left: 0` driven by `drawerOpenProvider`; `GestureDetector` scrim tap dismisses; contains `SidebarItem` for all 7 routes
    - `lib/shared/navigation/authenticated_shell.dart`: `AuthenticatedShell(child)` — `Stack` composing `child`, optional scrim, `DrawerOverlay`, `NavigationHeader` at top, `BottomNavBar` at bottom; wraps in `ConsumerWidget`
    - _Requirements: 3.1–3.9_

  - [ ]* 9.2 Write unit tests for navigation widgets
    - Test `BottomNavBar` renders 5 items
    - Test active item uses `AppColors.accent`
    - Test hamburger tap sets `drawerOpenProvider` to true
    - **Property 4: BottomNavBar Active Item Uses Gold Accent** — assert color token for each active route
    - **Property 5: Every Authenticated Screen Contains NavigationHeader and BottomNavBar** — pump `AuthenticatedShell` and assert widget tree contains both
    - **Property 6: BottomNavBar Tap Routes to Correct Screen** — tap each item and assert GoRouter location matches `AppRoutes` constant
    - **Property 7: SidebarItem Tap Closes Drawer and Navigates** — assert `drawerOpenProvider` is `false` after sidebar tap
    - **Validates: Requirements 3.1–3.9**

  - [x] 9.3 Create tile widgets
    - `lib/shared/tiles/trade_tile.dart`: `TradeTile(trade)` — direction label colored `AppColors.buyColor` or `AppColors.sellColor`; fields: Stake, Entry Price, Duration, TP, SL, Current P&L; nulls → "--"
    - `lib/shared/tiles/signal_tile.dart`: `SignalTile(signal)` — direction colored per `TradeDirection`; fields: source, timestamp, status badge
    - `lib/shared/tiles/account_tile.dart`: `AccountTile(label, value)` — two-column row
    - `lib/shared/tiles/settings_tile.dart`: `SettingsTile({label, value, onTap, isSwitch, isSensitive, switchValue, onChanged})` — renders text field row or Cupertino switch row; sensitive fields obscured with visibility toggle icon
    - _Requirements: 10.4, 5.4, 5.6, 6.4, 7.6_

  - [ ]* 9.4 Write unit tests for tile widgets
    - Test `TradeTile` renders green for `TradeDirection.buy` and red for `TradeDirection.sell`
    - Test `SignalTile` applies same color convention
    - Test `SettingsTile` with `isSensitive: true` shows obscured text by default
    - **Property 9: TradeTile Direction Color Is Consistent** — assert `buyColor` / `sellColor` per direction
    - **Property 10: SignalTile Direction Color Is Consistent** — assert same color tokens
    - **Validates: Requirements 5.6, 6.5, 9.4, 7.6**

  - [x] 9.5 Create dialog and bottom sheet widgets
    - `lib/shared/dialogs/glass_dialog.dart`: `GlassDialog({title, content, actions})` — `showDialog` wrapping `GlassCard`-styled `AlertDialog`
    - `lib/shared/dialogs/glass_bottom_sheet.dart`: `GlassBottomSheet({child})` — `showModalBottomSheet` with `GlassCard` surface, rounded top corners `20.r`
    - _Requirements: 10.5, 7.4, 8.3, 8.4_

- [ ] 10. Screen implementations
  - [x] 10.1 Implement `lib/features/login/login_screen.dart`
    - `Scaffold` background `AppColors.background`, `SafeArea`, centered `Column`
    - HT BOT logo (SVG or styled `Text`), headline "HT BOT", subtitle "Deriv Trading Bot"
    - `AnimatedButton` wrapping `PrimaryButton("Connect with Deriv")`
    - `onPressed`: call `OAuthNotifier.initiateLogin()` which runs `PkceGenerator.generate()`, persists `codeVerifier` and `state` via `flutter_secure_storage`, builds URL with `OAuthUrlBuilder`, launches via `url_launcher`
    - OAuth error → `GlassDialog` with retry; URL launch failure → inline error text below button
    - _Requirements: 2.1–2.11_

  - [ ]* 10.2 Write unit tests for login screen
    - Test button renders with gold accent
    - Test entrance animation present in widget tree
    - **Property 3: OAuth State Mismatch Is Always Rejected** — simulate callback with mismatched state, assert no navigation to dashboard and error displayed
    - **Validates: Requirements 2.3, 2.4, 2.8**

  - [x] 10.3 Implement `lib/features/dashboard/dashboard_screen.dart`
    - `ConsumerWidget` reading `dashboardProvider`
    - Layout: `BalanceCard` (full-width `GlassCard`, null → "--"), `Row[ProfitCard | StatisticCard(WinRate + `fl_chart` `PieChart`)]`, `Row[MetricTile(Active Trades) | MetricTile(Trades Today)]`, `Wrap[StatusCard×4]`
    - `PrimaryButton("Start Bot")`, `AnimatedButton(child: danger-styled "Emergency Stop")`
    - Staggered entrance: helper `_animatedCard(Widget, int index)` using `flutter_animate` delay `80 * index ms`, `fadeIn(350ms)`, `slideY(begin: 0.15)`
    - `EmptyState` inside `StatisticCard` when `winRate == null`
    - _Requirements: 4.1–4.10_

  - [x] 10.4 Implement `lib/features/trades/active_trades_screen.dart`
    - `ConsumerWidget` reading `tradesProvider` and `tradeFilterProvider`
    - Filter chips row: "Running", "Closed", "All" — selected chip uses `AppColors.accent` (`ChoiceChip`)
    - `ListView.builder` of `TradeTile`s or `EmptyState("No trades to display")`
    - Pinned `PrimaryButton("Close All Trades")` at bottom
    - _Requirements: 5.1–5.7_

  - [ ]* 10.5 Write unit tests for filter chip behavior
    - Test selected chip renders with `AppColors.accent`
    - Test unselected chips use different color
    - **Property 11: Filter Chip Selection Uses Gold Accent** — assert accent color on selected chip for both screens
    - **Validates: Requirements 5.2, 9.2**

  - [ ] 10.6 Implement `lib/features/signals/signal_monitor_screen.dart`
    - `ConsumerWidget` reading `signalsProvider` and `connectionStatusProvider`
    - `StatusCard("Signal Source", ConnectionBadge(status))` at top
    - `Row[MetricTile("Last Heartbeat") | MetricTile("Last Signal") | MetricTile("Avg Latency")]`; all values "--"
    - "Recent Signals" section: `ListView(SignalTile…)` or `EmptyState("Waiting for next signal…")`
    - _Requirements: 6.1–6.6_

  - [ ] 10.7 Implement `lib/features/settings/settings_screen.dart`
    - `SingleChildScrollView` → `Column`
    - "Trading Settings" group: 8 `SettingsTile`s (Stake Amount, Take Profit, Stop Loss, Max Concurrent Trades, Daily Profit Target, Daily Loss Limit, Martingale Multiplier, Cooldown Period)
    - "Connection Settings" group: API Token (`isSensitive: true`), Python Engine URL, Auto Reconnect (switch)
    - "Notification Settings" group: 4 switch `SettingsTile`s (Trade Executed, Signal Received, Bot Stopped, Connection Lost)
    - Tapping a text tile opens `GlassBottomSheet` for input (no persistence)
    - _Requirements: 7.1–7.8_

  - [ ] 10.8 Implement `lib/features/account/account_screen.dart`
    - Profile section: placeholder avatar circle, name "--", email "--"
    - AccountTile list: Account Type, Account ID, Balance, Currency, API Status, Token Expiry; values "--"
    - `PrimaryButton("Manage API Token")` → opens `GlassBottomSheet` with instructions + text input (no persistence)
    - `SecondaryButton("Switch Account")` → opens `GlassDialog` with empty list `EmptyState` + cancel
    - `SecondaryButton("Logout")` → opens confirm `GlassDialog` → on confirm, navigate to `/login`
    - _Requirements: 8.1–8.6_

  - [ ] 10.9 Implement `lib/features/history/trade_history_screen.dart`
    - Filter chips: "All", "Win", "Loss" — selected uses `AppColors.accent`
    - `ListView(TradeTile…)` or `EmptyState("No trade history yet")`
    - Summary row: 5 `MetricTile`s (Total Trades `0`, Wins `0`, Losses `0`, Win Rate `0%`, Total Profit `0`)
    - _Requirements: 9.1–9.6_

- [x] 11. Animation framework helpers
  - [x] 11.1 Create `lib/shared/animations/staggered_entrance.dart`
    - `StaggeredEntrance({required Widget child, required int index, Duration baseDelay = const Duration(milliseconds: 80)})`: applies `flutter_animate` `.animate(delay: baseDelay * index).fadeIn(duration: 350.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic)`
    - Cap stagger at 6 items max so total sequence ≤ 830ms
    - _Requirements: 11.1, 11.2_

  - [x] 11.2 Create `lib/shared/animations/press_animation.dart`
    - `PressAnimation({required Widget child})`: `StatefulWidget` tracking `_isPressed`; `GestureDetector` on `onTapDown`/`onTapUp`/`onTapCancel`; `flutter_animate` `.animate(target: _isPressed ? 1 : 0).scale(end: Offset(0.95, 0.95), duration: 80.ms, curve: Curves.easeIn)`
    - _Requirements: 11.3_

- [ ] 12. Checkpoint — integration and final wiring
  - [ ] 12.1 Wire all screens into `AppRouter`
    - Replace all `Placeholder()` stubs in `app_router.dart` with actual screen imports
    - Verify `ShellRoute` wraps all six authenticated screens inside `AuthenticatedShell`
    - Verify `LoginScreen` sits outside the shell
    - _Requirements: 1.3, 3.3, 3.4_

  - [ ] 12.2 Wire `LoadingOverlay` into `AuthenticatedShell`
    - Read `loadingProvider` inside `AuthenticatedShell`; conditionally render `LoadingOverlay` on top of the stack
    - _Requirements: 10.6_

  - [ ] 12.3 Final checkpoint — Ensure all tests pass, ask the user if questions arise.

---

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP delivery
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key integration points
- Property tests validate universal correctness properties (13 properties defined in design.md)
- All screens use empty/null states — no hardcoded data anywhere
- `flutter_screenutil` `.w`, `.h`, `.r`, `.sp` must be used for every dimension
- `gap` package replaces all `SizedBox` spacing widgets

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.3"] },
    { "id": 1, "tasks": ["1.2", "2.1", "2.3"] },
    { "id": 2, "tasks": ["2.2", "3.1"] },
    { "id": 3, "tasks": ["3.2", "3.3"] },
    { "id": 4, "tasks": ["4.1", "4.2", "5.1"] },
    { "id": 5, "tasks": ["6.1", "6.2"] },
    { "id": 6, "tasks": ["6.3", "7.1"] },
    { "id": 7, "tasks": ["7.2", "7.3", "7.4", "8.1"] },
    { "id": 8, "tasks": ["7.5", "9.1", "9.3", "9.5"] },
    { "id": 9, "tasks": ["9.2", "9.4", "11.1", "11.2"] },
    { "id": 10, "tasks": ["10.1", "10.3", "10.4", "10.6", "10.7", "10.8", "10.9"] },
    { "id": 11, "tasks": ["10.2", "10.5", "12.1", "12.2"] }
  ]
}
```
