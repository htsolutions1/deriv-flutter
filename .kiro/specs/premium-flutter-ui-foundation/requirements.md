# Requirements Document

## Introduction

This document defines the UI requirements for **HT BOT** — a production-grade Flutter mobile application for a Deriv Binary Options Trading Bot. The app targets small-screen Android devices (360–430 dp width), operates in portrait orientation, and aims for 60+ FPS rendering. The scope is strictly the UI layer: no backend integration, no mock trading data, no business logic. All data-dependent sections display proper empty states. The app uses a light-only Apple HIG-inspired theme with glassmorphism cards, a gold accent (#D4AF37), and a light-blue background (#EAF4FF).

The app exposes seven screens (Login, Dashboard, Active Trades, Signal Monitor, Settings, Account, Trade History), unified by a persistent Bottom Navigation Bar (5 items) and a left drawer overlay accessible from every authenticated screen.

---

## Glossary

- **App**: The HT BOT Flutter application.
- **LoginScreen**: The splash/welcome screen that the user sees before authentication.
- **DashboardScreen**: The primary post-login screen showing account balance, bot status, and summary metrics.
- **ActiveTradesScreen**: The screen displaying currently running and recently closed trade positions.
- **SignalMonitorScreen**: The screen showing the live signal feed, heartbeat, and latency metrics.
- **SettingsScreen**: The screen containing grouped configuration controls for trading, connection, and notifications.
- **AccountScreen**: The screen showing the user's Deriv account details, API token management, and logout.
- **TradeHistoryScreen**: The screen displaying a filterable list of historical trades and summary statistics.
- **BottomNavBar**: The persistent 5-item bottom navigation bar visible on all authenticated screens.
- **DrawerOverlay**: The left-side navigation drawer that slides in as an overlay over any authenticated screen.
- **GlassCard**: A frosted-glass card widget with a semi-transparent background, blur effect, and rounded corners.
- **StatusCard**: A compact GlassCard variant displaying a status label and an indicator badge.
- **ProfitCard**: A GlassCard variant displaying a monetary value with a directional color indicator.
- **StatisticCard**: A GlassCard variant displaying a numeric metric with a label.
- **AnimatedButton**: A button widget with entrance and press animations powered by flutter_animate.
- **PrimaryButton**: The main call-to-action button using the gold accent color.
- **SecondaryButton**: A secondary action button using a muted surface color.
- **SidebarItem**: A row widget representing a navigation destination inside the DrawerOverlay.
- **NavigationHeader**: The top app bar row containing the hamburger icon, screen title, and ConnectionBadge.
- **EmptyState**: A centered illustration + label widget shown when a list or data section has no content.
- **TradeTile**: A list tile displaying trade direction, stake, entry, duration, TP, SL, and current P&L.
- **SignalTile**: A list tile displaying a signal direction, source, timestamp, and execution status.
- **AccountTile**: A list tile displaying a Deriv account attribute label and its value.
- **SettingsTile**: A row widget pairing a label with a Cupertino switch or a text input field.
- **GlassDialog**: A modal dialog rendered on a frosted-glass surface.
- **GlassBottomSheet**: A bottom sheet rendered on a frosted-glass surface.
- **LoadingOverlay**: A full-screen semi-transparent overlay with a centered activity indicator.
- **ConnectionBadge**: A compact pill badge indicating the WebSocket/server connection state.
- **StatusBadge**: A compact colored dot or pill indicating an entity's operational status.
- **MetricTile**: A compact tile pairing a numeric value with a descriptive label.
- **OAuthFlowUI**: The set of UI elements that initiate and visually guide the Deriv OAuth 2.0 PKCE authorization flow.
- **flutter_screenutil**: The package used for responsive size scaling across the 360–430 dp target range.
- **go_router**: The declarative routing package managing all named routes.
- **Riverpod**: The state-management package providing all UI state to screens and widgets.
- **fl_chart**: The charting package used for the win-rate donut chart on the DashboardScreen.
- **flutter_animate**: The animation package used for entrance, press, and transition animations.
- **glassmorphism_ui / blur**: Packages used to render frosted-glass effects on GlassCard and overlay surfaces.
- **flex_color_scheme**: The package used to generate the app's ThemeData.
- **phosphor_flutter / lucide_icons_flutter**: Icon libraries used throughout the App.
- **google_fonts**: The package providing the App's typeface.
- **gap**: The package used for consistent spacing between widgets.
- **intl**: The package used for number and date formatting.

---

## Requirements

### Requirement 1 — Application Foundation

**User Story:** As a developer, I want a well-structured Flutter project scaffold with a consistent theme, routing, and responsive utilities, so that all screens share a coherent visual and behavioral baseline.

#### Acceptance Criteria

1. THE App SHALL initialize flutter_screenutil with a design size of 390 × 844 dp before rendering any screen, ensuring all size values scale proportionally on devices between 360 dp and 430 dp width.
2. THE App SHALL apply a ThemeData generated via flex_color_scheme using `#EAF4FF` as the surface/background seed color and `#D4AF37` as the primary accent color, with no dark theme variant.
3. THE App SHALL register all named routes through go_router, including `/login`, `/dashboard`, `/trades`, `/signals`, `/settings`, `/account`, and `/history`.
4. THE App SHALL lock the device orientation to portrait mode at startup.
5. THE App SHALL load and apply a google_fonts typeface consistently across all text styles in the ThemeData.
6. THE App SHALL wrap the widget tree in a ProviderScope so that all Riverpod providers are accessible to every screen and widget.

---

### Requirement 2 — Login Screen

**User Story:** As a first-time or returning user, I want a polished welcome screen with a clear call-to-action, so that I can initiate the Deriv OAuth 2.0 PKCE login flow from a single tap.

#### Acceptance Criteria

1. WHEN the App launches cold, THE LoginScreen SHALL be the first screen displayed before any authenticated content.
2. THE LoginScreen SHALL display the HT BOT logo centered vertically and horizontally on the `#EAF4FF` background.
3. THE LoginScreen SHALL display an AnimatedButton labeled "Connect with Deriv" below the logo using the PrimaryButton style with the gold accent color.
4. WHEN the "Connect with Deriv" button is rendered, THE LoginScreen SHALL apply an entrance animation via flutter_animate (e.g., fade-in with upward slide) before the button becomes interactive.
5. WHEN the user taps "Connect with Deriv", THE OAuthFlowUI SHALL construct the Deriv authorization URL with `response_type=code`, `client_id`, `redirect_uri`, `scope`, `state`, `code_challenge`, and `code_challenge_method=S256` parameters, matching the OAuth 2.0 PKCE specification.
6. WHEN the OAuthFlowUI constructs the authorization URL, THE OAuthFlowUI SHALL generate a fresh cryptographically random `code_verifier` and `state` value for every new login attempt.
7. WHEN the OAuthFlowUI stores the `code_verifier` and `state` before redirecting, THE OAuthFlowUI SHALL persist these values in flutter_secure_storage, not in plain shared preferences.
8. WHEN the OAuth callback returns a `state` parameter, THE OAuthFlowUI SHALL compare it with the stored `state` value and SHALL display an error message if the values do not match.
9. WHEN the OAuth callback returns a valid `code` and a matching `state`, THE OAuthFlowUI SHALL navigate the user to the DashboardScreen via the go_router `/dashboard` route.
10. IF the OAuth callback returns an `error` parameter, THEN THE OAuthFlowUI SHALL display a GlassDialog informing the user that authentication failed, with a retry action.
11. THE LoginScreen SHALL NOT display any trade data, account balance, or bot status information.

---

### Requirement 3 — Shared Navigation Shell

**User Story:** As an authenticated user, I want consistent navigation available on every screen, so that I can move between the app's main sections without losing context.

#### Acceptance Criteria

1. THE BottomNavBar SHALL display exactly five navigation items: Dashboard, Trades, Signals, Settings, and Account, each with a phosphor_flutter or lucide_icons_flutter icon and a text label.
2. THE BottomNavBar SHALL highlight the active destination using the gold accent color (`#D4AF37`) and render inactive items in a muted gray tone.
3. THE BottomNavBar SHALL be visible at all times on every authenticated screen (DashboardScreen, ActiveTradesScreen, SignalMonitorScreen, SettingsScreen, AccountScreen, TradeHistoryScreen).
4. WHEN the user taps a BottomNavBar item, THE App SHALL navigate to the corresponding route using go_router without rebuilding the NavigationHeader or DrawerOverlay widgets unnecessarily.
5. THE NavigationHeader SHALL be displayed at the top of every authenticated screen and SHALL contain: a hamburger icon on the leading side, the current screen title in the center, and a ConnectionBadge on the trailing side.
6. WHEN the user taps the hamburger icon in the NavigationHeader, THE DrawerOverlay SHALL slide in from the left edge as an overlay, without pushing the main screen content to the right.
7. THE DrawerOverlay SHALL contain SidebarItem widgets for all seven screens (including Trade History), the HT BOT logo or app name at the top, and a close affordance.
8. WHEN the user taps a SidebarItem inside the DrawerOverlay, THE App SHALL close the DrawerOverlay and navigate to the selected screen.
9. WHEN the user taps outside the DrawerOverlay or swipes it to the left, THE DrawerOverlay SHALL dismiss with a slide-out animation.
10. THE ConnectionBadge SHALL render in a green color when the connection state provider indicates "connected" and in a red/orange color when the provider indicates "disconnected" or "error".

---

### Requirement 4 — Dashboard Screen

**User Story:** As a trader, I want a compact overview of my account balance, bot status, profit, and trade metrics on the Dashboard, so that I can assess the bot's current state at a glance.

#### Acceptance Criteria

1. THE DashboardScreen SHALL display a prominent GlassCard at the top showing the account balance field with an EmptyState placeholder (e.g., "--") when no account data is available.
2. THE DashboardScreen SHALL display a ProfitCard showing "Today's Profit" with an EmptyState placeholder when no profit data is available.
3. THE DashboardScreen SHALL display a StatisticCard showing "Win Rate" with a fl_chart donut chart; WHEN no trade data is available, THE StatisticCard SHALL display an EmptyState centered inside the chart area.
4. THE DashboardScreen SHALL display a MetricTile showing "Active Trades" count and a MetricTile showing "Trades Today" count, both rendering `0` as their empty-state value.
5. THE DashboardScreen SHALL display a StatusCard for each of the following system entities: Bot Status, Signal Source Status, Connection Status, and Server Status; WHEN no runtime data is available, EACH StatusCard SHALL display a StatusBadge in an "idle" or "offline" visual state.
6. THE DashboardScreen SHALL display a PrimaryButton labeled "Start Bot" (or a "Stop Bot" variant) that is enabled in the UI but does not trigger any backend call in the UI-only phase.
7. THE DashboardScreen SHALL display an AnimatedButton labeled "Emergency Stop" styled distinctly (e.g., red border or red tinted surface) that is enabled in the UI but does not trigger any backend call in the UI-only phase.
8. THE DashboardScreen SHALL NOT display any hardcoded balance values, fake profit figures, or fabricated trade counts.
9. WHEN the DashboardScreen is first rendered, THE DashboardScreen SHALL apply staggered entrance animations via flutter_animate to each card and metric tile.
10. THE DashboardScreen SHALL lay out all cards and tiles in a responsive grid using flutter_screenutil sizing, such that the layout remains readable on both 360 dp and 430 dp width devices.

---

### Requirement 5 — Active Trades Screen

**User Story:** As a trader, I want to see all running and recently closed trade positions in a filterable list, so that I can monitor individual trade performance.

#### Acceptance Criteria

1. THE ActiveTradesScreen SHALL display three filter chips labeled "Running", "Closed", and "All" at the top of the screen.
2. WHEN a filter chip is tapped, THE ActiveTradesScreen SHALL highlight the selected chip using the gold accent color and display the EmptyState widget in the list area, because no real trade data is provided in the UI-only phase.
3. THE ActiveTradesScreen SHALL render a TradeTile for each trade entry in the list; WHEN no entries exist, THE ActiveTradesScreen SHALL display an EmptyState widget with an appropriate label (e.g., "No trades to display").
4. THE TradeTile SHALL display the following fields for each position: trade direction (BUY/SELL) as a colored label, Stake, Entry Price, Duration, Take Profit, Stop Loss, and Current P&L — all fields SHALL show an EmptyState placeholder value (e.g., "--") in the UI-only phase.
5. THE ActiveTradesScreen SHALL display a PrimaryButton labeled "Close All Trades" below the trade list; the button SHALL be visible but SHALL NOT trigger any backend action in the UI-only phase.
6. THE TradeTile SHALL indicate the BUY direction with a green color token and the SELL direction with a red color token, consistent with the app's ThemeData.
7. THE ActiveTradesScreen SHALL NOT display any hardcoded trade records or fabricated P&L values.

---

### Requirement 6 — Signal Monitor Screen

**User Story:** As a trader, I want a real-time view of the signal feed, connection health, and recent signal history, so that I can verify the signal source is operating correctly.

#### Acceptance Criteria

1. THE SignalMonitorScreen SHALL display a StatusCard showing "Signal Source" with a ConnectionBadge; WHEN no connection data is available, THE StatusCard SHALL display the ConnectionBadge in a "disconnected" visual state.
2. THE SignalMonitorScreen SHALL display MetricTile widgets for "Last Heartbeat", "Last Signal", and "Average Latency"; WHEN no data is available, EACH MetricTile SHALL display "--" as its value.
3. THE SignalMonitorScreen SHALL display a "Recent Signals" section containing a vertical timeline list of SignalTile widgets; WHEN no signals are available, THE SignalMonitorScreen SHALL display an EmptyState widget with the label "Waiting for next signal…".
4. THE SignalTile SHALL display the signal direction (BUY/SELL) as a colored label, the signal source identifier, a formatted timestamp placeholder, and an execution status badge; all field values SHALL be EmptyState placeholders in the UI-only phase.
5. THE SignalMonitorScreen SHALL apply the BUY direction color token (green) and SELL direction color token (red) to the respective SignalTile direction labels, consistent with the TradeTile color conventions.
6. THE SignalMonitorScreen SHALL NOT display any hardcoded signal records or fabricated latency values.

---

### Requirement 7 — Settings Screen

**User Story:** As a trader, I want grouped configuration controls for trading risk, connection parameters, and notifications, so that I can adjust the bot's behavior before activation.

#### Acceptance Criteria

1. THE SettingsScreen SHALL display a "Trading Settings" group containing SettingsTile widgets for: Stake Amount, Take Profit, Stop Loss, Max Concurrent Trades, Daily Profit Target, Daily Loss Limit, Martingale Multiplier, and Cooldown Period.
2. THE SettingsScreen SHALL display a "Connection Settings" group containing SettingsTile widgets for: API Token (text input), Python Engine URL (text input), and Auto Reconnect (Cupertino switch).
3. THE SettingsScreen SHALL display a "Notification Settings" group containing SettingsTile widgets with Cupertino switch controls for at least: Trade Executed, Signal Received, Bot Stopped, and Connection Lost notification types.
4. THE SettingsTile widgets that require numeric or text input SHALL render a tappable text field or inline input that opens a GlassBottomSheet or GlassDialog for editing; the input controls SHALL NOT persist any values to storage in the UI-only phase.
5. THE SettingsTile widgets that use Cupertino switches SHALL render the switch in the off/false state by default and SHALL allow the switch to be toggled visually without persisting state in the UI-only phase.
6. WHERE a SettingsTile input field contains a sensitive value (e.g., API Token), THE SettingsScreen SHALL obscure the displayed value with password masking by default and SHALL provide a visibility toggle icon.
7. THE SettingsScreen SHALL organize each group under a labeled section header styled consistently with the app's ThemeData.
8. THE SettingsScreen SHALL NOT hardcode any API token values, trading parameter values, or URL values.

---

### Requirement 8 — Account Screen

**User Story:** As a user, I want to see my Deriv account details, manage my API token, switch accounts, and log out, so that I can control my authentication and account selection.

#### Acceptance Criteria

1. THE AccountScreen SHALL display a "Profile" section at the top containing a placeholder avatar, a display name EmptyState ("--"), and an email EmptyState ("--").
2. THE AccountScreen SHALL display a "Deriv Account" section containing AccountTile widgets for: Account Type, Account ID, Balance, Currency, API Status, and Token Expiry; all values SHALL display EmptyState placeholders ("--") in the UI-only phase.
3. THE AccountScreen SHALL display a PrimaryButton labeled "Manage API Token" that opens a GlassBottomSheet containing instructions and a text input for entering or replacing an API token; the GlassBottomSheet SHALL NOT persist any token value in the UI-only phase.
4. THE AccountScreen SHALL display a SecondaryButton labeled "Switch Account" that opens a GlassDialog presenting an empty account list with an EmptyState widget and a cancel action.
5. THE AccountScreen SHALL display a SecondaryButton labeled "Logout" that opens a GlassDialog asking for confirmation before proceeding; the confirmation action SHALL navigate the user to the LoginScreen via the go_router `/login` route and SHALL clear any locally stored session state.
6. THE AccountScreen SHALL NOT display any hardcoded account IDs, balances, or real API token values.

---

### Requirement 9 — Trade History Screen

**User Story:** As a trader, I want to review past trades with filtering and summary statistics, so that I can evaluate the bot's historical performance.

#### Acceptance Criteria

1. THE TradeHistoryScreen SHALL display three filter chips labeled "All", "Win", and "Loss" at the top of the screen.
2. WHEN a filter chip is tapped, THE TradeHistoryScreen SHALL highlight the selected chip using the gold accent color and display the EmptyState widget in the list area in the UI-only phase.
3. THE TradeHistoryScreen SHALL render a TradeTile for each historical trade entry; WHEN no entries exist, THE TradeHistoryScreen SHALL display an EmptyState widget with an appropriate label (e.g., "No trade history yet").
4. THE TradeTile SHALL display the P&L value for winning trades in a green color token and for losing trades in a red color token, consistent with the app's ThemeData.
5. THE TradeHistoryScreen SHALL display a "Summary" section below the list containing MetricTile widgets for: Total Trades, Total Wins, Total Losses, Win Rate, and Total Profit; all values SHALL display `0` or `0%` as their empty-state values.
6. THE TradeHistoryScreen SHALL NOT display any hardcoded historical trade records or fabricated summary statistics.

---

### Requirement 10 — Shared Widget Library

**User Story:** As a developer, I want a complete library of reusable, spec-compliant widgets, so that all screens share consistent visual components without duplicating code.

#### Acceptance Criteria

1. THE App SHALL provide a GlassCard widget that accepts a child widget and applies a frosted-glass surface using the glassmorphism_ui or blur package, with configurable border radius, opacity, and blur sigma.
2. THE App SHALL provide StatusCard, ProfitCard, StatisticCard, and MetricTile as compositional variants of GlassCard, each exposing typed constructor parameters for their specific data fields.
3. THE App SHALL provide AnimatedButton, PrimaryButton, and SecondaryButton widgets; PrimaryButton SHALL use the gold accent color (`#D4AF37`) as its background; SecondaryButton SHALL use a muted surface color; AnimatedButton SHALL wrap any button child with a flutter_animate entrance and press animation.
4. THE App SHALL provide TradeTile, SignalTile, AccountTile, and SettingsTile as standalone list-item widgets with clearly typed constructor parameters for each displayed field.
5. THE App SHALL provide GlassDialog and GlassBottomSheet widgets that render their content on a frosted-glass surface consistent with GlassCard styling.
6. THE App SHALL provide a LoadingOverlay widget that renders a full-screen semi-transparent scrim with a centered activity indicator and can be shown or hidden via a Riverpod provider flag.
7. THE App SHALL provide a ConnectionBadge widget that accepts a connection state enum and renders the appropriate color and label.
8. THE App SHALL provide a StatusBadge widget that accepts a status enum and renders a colored dot or pill with a label.
9. THE App SHALL provide an EmptyState widget that accepts an optional icon, a required label string, and an optional sub-label string, and centers them vertically and horizontally within its parent.
10. THE App SHALL provide a SidebarItem widget used exclusively inside the DrawerOverlay, accepting an icon, a label, a selected boolean, and an onTap callback.
11. WHILE a list widget is in an empty data state, THE App SHALL display the EmptyState widget in place of the list content on every screen that contains a data list.

---

### Requirement 11 — Animation and Performance

**User Story:** As a user, I want fluid, polished animations that reinforce the premium feel of the app, so that the experience matches fintech-grade UX standards.

#### Acceptance Criteria

1. THE App SHALL target a minimum of 60 frames per second on mid-range Android devices with a screen width between 360 dp and 430 dp.
2. WHEN a screen is navigated to, THE App SHALL apply entrance animations to primary content blocks using flutter_animate with staggered delays, ensuring the total entrance sequence completes within 600 ms.
3. WHEN an AnimatedButton is pressed, THE App SHALL apply a scale-down press animation via flutter_animate that completes within 100 ms.
4. THE App SHALL use the gap package for all spacing between widgets instead of hardcoded SizedBox heights, to maintain consistent vertical and horizontal rhythm.
5. THE App SHALL use flutter_screenutil `.sp` and `.w`/`.h` extension getters for all font sizes and dimensional values to ensure proportional scaling across the target device width range.
6. THE App SHALL NOT use blocking synchronous operations on the main isolate that would cause frame drops below 60 FPS.

---

### Requirement 12 — Code Architecture and Quality

**User Story:** As a developer, I want a clean, modular folder structure with a clear separation of concerns, so that the codebase is maintainable and ready for backend integration.

#### Acceptance Criteria

1. THE App SHALL organize source files under the following top-level feature directories: `lib/core/`, `lib/theme/`, `lib/constants/`, `lib/routing/`, `lib/shared/widgets/`, `lib/shared/animations/`, `lib/shared/dialogs/`, `lib/shared/cards/`, `lib/shared/navigation/`, `lib/features/dashboard/`, `lib/features/trades/`, `lib/features/signals/`, `lib/features/history/`, `lib/features/settings/`, and `lib/features/account/`.
2. THE App SHALL declare all go_router route paths as named string constants in `lib/constants/` or `lib/routing/` to avoid magic strings in screen code.
3. THE App SHALL define all color constants (`#EAF4FF`, `#D4AF37`, and all semantic color tokens) in a single `AppColors` class inside `lib/theme/` or `lib/constants/`.
4. THE App SHALL define all ThemeData configuration in a dedicated `AppTheme` class inside `lib/theme/`, referencing `AppColors` and `google_fonts` typefaces.
5. THE App SHALL declare all Riverpod providers in dedicated provider files co-located with their respective feature directory, not inline inside widget `build` methods.
6. THE App SHALL NOT contain any hardcoded trading data, API keys, credential strings, or backend URLs in source files committed to the project.
