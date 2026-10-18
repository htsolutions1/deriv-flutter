# Design Document — HT BOT Premium Flutter UI Foundation

## Overview

This document describes the architecture, component structure, data models, routing strategy, and correctness properties for the **HT BOT** Flutter UI. The scope is the complete UI shell: seven screens, 20+ shared widgets, theme system, responsive scaling, routing, and Riverpod state management. No backend calls are implemented; all data-dependent sections use typed empty states.

---

## Architecture

The application follows a **feature-first clean architecture** with a shared widget library. The dependency direction flows inward: screens depend on shared widgets and providers; providers depend on domain models and constants; nothing in `lib/features/` references another feature's internals.

```
lib/
├── core/
│   ├── constants/          # AppColors, AppSizes, AppStrings, route constants
│   ├── enums/              # ConnectionState, BotStatus, TradeDirection, SignalStatus
│   └── utils/              # PkceGenerator, OAuthUrlBuilder
├── theme/
│   ├── app_theme.dart      # AppTheme (flex_color_scheme ThemeData factory)
│   └── text_styles.dart    # Named text style aliases
├── routing/
│   └── app_router.dart     # GoRouter definition with all 7 named routes
├── shared/
│   ├── widgets/            # EmptyState, LoadingOverlay, ConnectionBadge, StatusBadge, SidebarItem
│   ├── cards/              # GlassCard, StatusCard, ProfitCard, StatisticCard, MetricTile
│   ├── buttons/            # PrimaryButton, SecondaryButton, AnimatedButton
│   ├── dialogs/            # GlassDialog, GlassBottomSheet
│   ├── navigation/         # BottomNavBar, NavigationHeader, DrawerOverlay
│   ├── tiles/              # TradeTile, SignalTile, AccountTile, SettingsTile
│   └── animations/         # StaggeredEntrance, PressAnimation
└── features/
    ├── login/
    │   ├── login_screen.dart
    │   └── providers/oauth_provider.dart
    ├── dashboard/
    │   ├── dashboard_screen.dart
    │   └── providers/dashboard_provider.dart
    ├── trades/
    │   ├── active_trades_screen.dart
    │   └── providers/trades_provider.dart
    ├── signals/
    │   ├── signal_monitor_screen.dart
    │   └── providers/signals_provider.dart
    ├── settings/
    │   ├── settings_screen.dart
    │   └── providers/settings_provider.dart
    ├── account/
    │   ├── account_screen.dart
    │   └── providers/account_provider.dart
    └── history/
        ├── trade_history_screen.dart
        └── providers/history_provider.dart
```

---

## Theme System

### AppColors

```dart
// lib/core/constants/app_colors.dart
abstract final class AppColors {
  static const Color background    = Color(0xFFEAF4FF);
  static const Color surface       = Color(0x8CFFFFFF);   // rgba(255,255,255,0.55)
  static const Color accent        = Color(0xFFD4AF37);   // gold
  static const Color primaryText   = Color(0xFF243447);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color success       = Color(0xFF22C55E);
  static const Color loss          = Color(0xFFEF4444);
  static const Color border        = Color(0x59FFFFFF);   // rgba(255,255,255,0.35)

  // Semantic aliases
  static const Color buyColor      = success;
  static const Color sellColor     = loss;
  static const Color connected     = success;
  static const Color disconnected  = Color(0xFFF97316);   // orange-500
  static const Color error         = loss;
}
```

### AppTheme

```dart
// lib/theme/app_theme.dart
abstract final class AppTheme {
  static ThemeData lightTheme() {
    return FlexThemeData.light(
      colors: FlexSchemeColor.from(
        primary: AppColors.accent,
        secondary: AppColors.accent,
        surface: AppColors.background,
      ),
      surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
      blendLevel: 7,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: _buildTextTheme(),
    );
  }

  static TextTheme _buildTextTheme() => GoogleFonts.interTextTheme();
}
```

---

## Responsive Sizing

flutter_screenutil is initialized in `main.dart` inside `ScreenUtilInit` before `MaterialApp.router`:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: HtBotApp()));
}

class HtBotApp extends ConsumerWidget {
  const HtBotApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (_, __) => MaterialApp.router(
        theme: AppTheme.lightTheme(),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
```

All dimension values throughout the codebase use:
- `.w` / `.h` for widths/heights (e.g., `16.w`, `48.h`)
- `.r` for border radii
- `.sp` for font sizes
- `gap` package for spacing: `Gap(12.h)` instead of `SizedBox(height: 12)`

---

## Routing

```dart
// lib/routing/app_router.dart
abstract final class AppRoutes {
  static const String login     = '/login';
  static const String dashboard = '/dashboard';
  static const String trades    = '/trades';
  static const String signals   = '/signals';
  static const String settings  = '/settings';
  static const String account   = '/account';
  static const String history   = '/history';
}

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(path: AppRoutes.login,     builder: (_, __) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => AuthenticatedShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const DashboardScreen()),
          GoRoute(path: AppRoutes.trades,    builder: (_, __) => const ActiveTradesScreen()),
          GoRoute(path: AppRoutes.signals,   builder: (_, __) => const SignalMonitorScreen()),
          GoRoute(path: AppRoutes.settings,  builder: (_, __) => const SettingsScreen()),
          GoRoute(path: AppRoutes.account,   builder: (_, __) => const AccountScreen()),
          GoRoute(path: AppRoutes.history,   builder: (_, __) => const TradeHistoryScreen()),
        ],
      ),
    ],
  );
}
```

`AuthenticatedShell` wraps all authenticated screens with `NavigationHeader`, `BottomNavBar`, and `DrawerOverlay` without rebuilding them on route changes.

---

## Data Models

### Enums

```dart
// lib/core/enums/app_enums.dart
enum ConnectionStatus { connected, disconnected, connecting, error }
enum BotStatus        { idle, running, stopped, error }
enum TradeDirection   { buy, sell }
enum SignalStatus     { pending, executed, failed, expired }
enum TradeOutcome     { win, loss, open }
enum TradeFilter      { all, running, closed }
enum HistoryFilter    { all, win, loss }
```

### Domain Models (UI layer only — no persistence)

```dart
// lib/core/models/trade_model.dart
@immutable
class TradeModel {
  final String   id;
  final TradeDirection direction;
  final double?  stake;
  final double?  entryPrice;
  final Duration? duration;
  final double?  takeProfit;
  final double?  stopLoss;
  final double?  currentPnl;
  final TradeOutcome outcome;
  final DateTime? openedAt;
  const TradeModel({required this.id, required this.direction, required this.outcome, ...});
}

// lib/core/models/signal_model.dart
@immutable
class SignalModel {
  final String       id;
  final TradeDirection direction;
  final String?      source;
  final DateTime?    timestamp;
  final SignalStatus status;
  const SignalModel({required this.id, required this.direction, required this.status, ...});
}
```

### Provider State Models

```dart
// Empty-state sentinel values
class DashboardState {
  final double?         balance;           // null → show "--"
  final double?         todayProfit;       // null → show "--"
  final double?         winRate;           // null → show EmptyState in chart
  final int             activeTrades;      // default 0
  final int             tradesToday;       // default 0
  final BotStatus       botStatus;         // default BotStatus.idle
  final ConnectionStatus connectionStatus; // default ConnectionStatus.disconnected
  const DashboardState({...});
  factory DashboardState.empty() => const DashboardState(
    balance: null, todayProfit: null, winRate: null,
    activeTrades: 0, tradesToday: 0,
    botStatus: BotStatus.idle, connectionStatus: ConnectionStatus.disconnected,
  );
}
```

---

## Components

### GlassCard

The foundation widget for all card surfaces.

```dart
// lib/shared/cards/glass_card.dart
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final double opacity;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blurSigma    = 10,
    this.opacity      = 0.55,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius.r),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          padding: padding ?? EdgeInsets.all(16.w),
          child: child,
        ),
      ),
    );
  }
}
```

### Card Variants

| Widget | Extends | Key Parameters |
|---|---|---|
| `StatusCard` | `GlassCard` | `label`, `status` (enum), `badgeColor` |
| `ProfitCard` | `GlassCard` | `label`, `value` (double?), `isPositive` (bool?) |
| `StatisticCard` | `GlassCard` | `label`, `value` (double?), `chart` (Widget?) |
| `MetricTile` | `GlassCard` | `label`, `value` (String) |

### Button Hierarchy

```dart
// PrimaryButton: gold background, primaryText foreground
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  // ElevatedButton(style: filled with AppColors.accent)
}

// SecondaryButton: surface background, secondaryText foreground
class SecondaryButton extends StatelessWidget { ... }

// AnimatedButton: wraps any button with flutter_animate
class AnimatedButton extends StatelessWidget {
  final Widget child;
  // .animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0)
  // GestureDetector onTapDown: .animate().scale(end: 0.95, duration: 80.ms)
}
```

### ConnectionBadge

```dart
class ConnectionBadge extends StatelessWidget {
  final ConnectionStatus status;
  Color get _color => switch (status) {
    ConnectionStatus.connected    => AppColors.connected,
    ConnectionStatus.connecting   => AppColors.accent,
    ConnectionStatus.disconnected => AppColors.disconnected,
    ConnectionStatus.error        => AppColors.error,
  };
  String get _label => switch (status) {
    ConnectionStatus.connected    => 'Live',
    ConnectionStatus.connecting   => 'Connecting',
    ConnectionStatus.disconnected => 'Offline',
    ConnectionStatus.error        => 'Error',
  };
}
```

### EmptyState

```dart
class EmptyState extends StatelessWidget {
  final IconData? icon;
  final String    label;
  final String?   subLabel;
  // Centers icon + label + subLabel vertically/horizontally
}
```

### DrawerOverlay

Implemented as an `AnimatedPositioned` overlay driven by a `drawerOpenProvider` (StateProvider<bool>). Does not use Flutter's built-in `Drawer` (which pushes content). Instead:

```dart
// Overlay approach: Stack in AuthenticatedShell
Stack(children: [
  child,                           // the screen content
  if (isDrawerOpen)
    GestureDetector(               // dismiss on outside tap
      onTap: () => ref.read(drawerOpenProvider.notifier).state = false,
      child: Container(color: Colors.black26),
    ),
  AnimatedPositioned(
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOutCubic,
    left: isDrawerOpen ? 0 : -280.w,
    child: DrawerPanel(),
  ),
])
```

---

## Screen Designs

### LoginScreen

Layout: `Scaffold` with `#EAF4FF` background, `SafeArea`, centered `Column`.

```
SafeArea
└── Column (mainAxisAlignment: center)
    ├── HtBotLogo (SVG or text logo, 120×120)
    ├── Gap(32.h)
    ├── Text("HT BOT", style: headline)
    ├── Gap(8.h)
    ├── Text("Deriv Trading Bot", style: subtitle)
    ├── Gap(64.h)
    └── AnimatedButton
        └── PrimaryButton("Connect with Deriv")
```

OAuth PKCE flow triggered on button tap:
1. `PkceGenerator.generate()` → `{codeVerifier, codeChallenge, state}`
2. Persist in `flutter_secure_storage`
3. `OAuthUrlBuilder.buildLoginUrl(...)` assembles URL
4. Launch URL via `url_launcher`

### DashboardScreen

Responsive grid layout using `flutter_staggered_grid_view` or manual `Column`/`Row` with `flutter_screenutil`:

```
Column
├── Gap(12.h)
├── BalanceCard (full width GlassCard)
├── Gap(12.h)
├── Row [ProfitCard | StatisticCard(WinRate+Donut)]
├── Gap(12.h)
├── Row [MetricTile(ActiveTrades) | MetricTile(TradesToday)]
├── Gap(12.h)
├── Wrap / Row [StatusCard×4]  (Bot, Signal, Connection, Server)
├── Gap(16.h)
├── PrimaryButton("Start Bot")
├── Gap(8.h)
└── AnimatedButton(child: danger-styled "Emergency Stop")
```

Staggered entrance: each card animates with a 60 ms stagger offset via `flutter_animate`.

### ActiveTradesScreen

```
Column
├── FilterChips Row [Running | Closed | All]
├── Gap(12.h)
└── Expanded
    └── ListView.builder(
          itemBuilder: trades.isEmpty ? EmptyState : TradeTile
        )
    └── PrimaryButton("Close All Trades")  // pinned bottom
```

### SignalMonitorScreen

```
Column
├── StatusCard(Signal Source, ConnectionBadge)
├── Gap(12.h)
├── Row [MetricTile(Heartbeat) | MetricTile(LastSignal) | MetricTile(Latency)]
├── Gap(16.h)
├── SectionHeader("Recent Signals")
└── Expanded
    └── signals.isEmpty ? EmptyState("Waiting for next signal…") : ListView(SignalTile…)
```

### SettingsScreen

```
SingleChildScrollView
└── Column
    ├── SettingsGroup("Trading Settings")
    │   └── SettingsTile × 8
    ├── Gap(16.h)
    ├── SettingsGroup("Connection Settings")
    │   └── SettingsTile × 3
    └── Gap(16.h)
        SettingsGroup("Notification Settings")
        └── SettingsTile(switch) × 4
```

API Token tile renders `obscureText: true` with a trailing IconButton toggling visibility.

### AccountScreen

```
Column
├── ProfileSection (avatar + name EmptyState + email EmptyState)
├── Gap(16.h)
├── AccountSection (AccountTile × 6)
├── Gap(24.h)
├── PrimaryButton("Manage API Token")   → opens GlassBottomSheet
├── Gap(12.h)
├── SecondaryButton("Switch Account")   → opens GlassDialog
└── Gap(12.h)
    SecondaryButton("Logout")           → opens confirm GlassDialog → /login
```

### TradeHistoryScreen

```
Column
├── FilterChips Row [All | Win | Loss]
├── Gap(12.h)
├── Expanded
│   └── trades.isEmpty ? EmptyState : ListView(TradeTile…)
└── SummarySection
    └── Row [MetricTile×5: Total, Wins, Losses, WinRate, TotalProfit]
```

---

## Riverpod Provider Map

| Provider | Type | Location | Default |
|---|---|---|---|
| `connectionStatusProvider` | `StateProvider<ConnectionStatus>` | `core/providers/` | `disconnected` |
| `drawerOpenProvider` | `StateProvider<bool>` | `shared/navigation/` | `false` |
| `dashboardProvider` | `StateNotifierProvider<DashboardNotifier, DashboardState>` | `features/dashboard/` | `DashboardState.empty()` |
| `tradesProvider` | `StateNotifierProvider<TradesNotifier, List<TradeModel>>` | `features/trades/` | `[]` |
| `signalsProvider` | `StateNotifierProvider<SignalsNotifier, List<SignalModel>>` | `features/signals/` | `[]` |
| `tradeFilterProvider` | `StateProvider<TradeFilter>` | `features/trades/` | `TradeFilter.all` |
| `historyFilterProvider` | `StateProvider<HistoryFilter>` | `features/history/` | `HistoryFilter.all` |
| `settingsProvider` | `StateNotifierProvider<SettingsNotifier, SettingsState>` | `features/settings/` | defaults |
| `loadingProvider` | `StateProvider<bool>` | `core/providers/` | `false` |
| `oauthProvider` | `StateNotifierProvider<OAuthNotifier, OAuthState>` | `features/login/` | `OAuthState.initial()` |

---

## OAuth PKCE Utilities

```dart
// lib/core/utils/pkce_generator.dart
abstract final class PkceGenerator {
  static PkceParams generate() {
    final verifier  = _generateVerifier();
    final challenge = _sha256Base64Url(verifier);
    final state     = _generateState();
    return PkceParams(codeVerifier: verifier, codeChallenge: challenge, state: state);
  }

  static String _generateVerifier() {
    final bytes = List<int>.generate(64, (_) => Random.secure().nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '').substring(0, 64);
  }

  static String _sha256Base64Url(String input) {
    final bytes    = utf8.encode(input);
    final digest   = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  static String _generateState() {
    final bytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

@immutable
class PkceParams {
  final String codeVerifier;
  final String codeChallenge;
  final String state;
  const PkceParams({required this.codeVerifier, required this.codeChallenge, required this.state});
}

// lib/core/utils/oauth_url_builder.dart
abstract final class OAuthUrlBuilder {
  static const String _baseUrl = 'https://auth.deriv.com/oauth2/auth';

  static Uri buildLoginUrl({
    required String clientId,
    required String redirectUri,
    required String state,
    required String codeChallenge,
    String scope = 'trade account_manage',
  }) {
    return Uri.parse(_baseUrl).replace(queryParameters: {
      'response_type':          'code',
      'client_id':              clientId,
      'redirect_uri':           redirectUri,
      'scope':                  scope,
      'state':                  state,
      'code_challenge':         codeChallenge,
      'code_challenge_method':  'S256',
    });
  }
}
```

---

## Animation Conventions

All entrance animations use `flutter_animate` with a consistent stagger pattern:

```dart
// Staggered card entrance (DashboardScreen example)
Widget _animatedCard(Widget child, int index) {
  return child
    .animate(delay: Duration(milliseconds: 80 * index))
    .fadeIn(duration: 350.ms)
    .slideY(begin: 0.15, end: 0, duration: 350.ms, curve: Curves.easeOutCubic);
}

// Total entrance sequence <= 600ms: 6 items × 80ms delay + 350ms = 830ms
// Cap at 6 staggered items max to stay within 600ms total visible change
```

Button press animation:
```dart
child.animate(target: isPressed ? 1 : 0)
  .scale(end: const Offset(0.95, 0.95), duration: 80.ms, curve: Curves.easeIn);
```

---

## Error Handling

| Scenario | UI Response |
|---|---|
| OAuth state mismatch | `GlassDialog` with "Security error: please try again" + retry button |
| OAuth error callback | `GlassDialog` with error message from `error_description` + retry |
| OAuth URL launch failure | Inline error text below button |
| Provider throws | `ErrorWidget` boundary per screen; no unhandled crashes |
| Empty data states | `EmptyState` widget with context-appropriate label |

---

## pubspec.yaml Key Dependencies

```yaml
dependencies:
  flutter_screenutil: ^5.9.0
  flex_color_scheme: ^7.3.1
  go_router: ^14.2.7
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  flutter_animate: ^4.5.0
  glassmorphism_ui: ^0.3.0
  blur: ^3.1.0
  fl_chart: ^0.68.0
  google_fonts: ^6.2.1
  gap: ^3.0.1
  intl: ^0.19.0
  flutter_svg: ^2.0.10+1
  phosphor_flutter: ^2.1.0
  lucide_icons_flutter: ^1.0.29
  lottie: ^3.1.0
  flutter_staggered_grid_view: ^0.7.0
  flutter_secure_storage: ^9.2.2
  url_launcher: ^6.3.0
  crypto: ^3.0.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.11
  riverpod_generator: ^2.4.0
```

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: PKCE Authorization URL Contains All Required Parameters

*For any* freshly generated `PkceParams`, the authorization URL produced by `OAuthUrlBuilder.buildLoginUrl` must contain all seven required OAuth 2.0 PKCE parameters: `response_type`, `client_id`, `redirect_uri`, `scope`, `state`, `code_challenge`, and `code_challenge_method=S256`.

**Validates: Requirements 2.5**

---

### Property 2: PKCE Parameters Are Unique Across Invocations

*For any* two independent calls to `PkceGenerator.generate()`, the resulting `codeVerifier` values must differ and the resulting `state` values must differ, ensuring no reuse of security-critical PKCE values.

**Validates: Requirements 2.6**

---

### Property 3: OAuth State Mismatch Is Always Rejected

*For any* stored `state` value and *any* callback `state` that differs from the stored value, the OAuth callback handler must not navigate to the DashboardScreen and must surface an error to the user.

**Validates: Requirements 2.8**

---

### Property 4: BottomNavBar Active Item Uses Gold Accent

*For any* authenticated route (dashboard, trades, signals, settings, account), the corresponding BottomNavBar item must render with the gold accent color (`#D4AF37`) and all other items must render with a muted color.

**Validates: Requirements 3.2**

---

### Property 5: Every Authenticated Screen Contains NavigationHeader and BottomNavBar

*For any* of the six authenticated screens (DashboardScreen, ActiveTradesScreen, SignalMonitorScreen, SettingsScreen, AccountScreen, TradeHistoryScreen), the widget tree must contain both a `NavigationHeader` and a `BottomNavBar`.

**Validates: Requirements 3.3, 3.5**

---

### Property 6: BottomNavBar Tap Routes to Correct Screen

*For any* BottomNavBar item tap, the router must navigate to the route path that corresponds to the tapped item's declared route constant, as defined in `AppRoutes`.

**Validates: Requirements 3.4**

---

### Property 7: SidebarItem Tap Closes Drawer and Navigates

*For any* `SidebarItem` inside the `DrawerOverlay`, tapping it must set `drawerOpenProvider` to `false` and navigate to the route associated with that sidebar item.

**Validates: Requirements 3.8**

---

### Property 8: ConnectionBadge Color Matches ConnectionStatus

*For any* `ConnectionStatus` enum value passed to `ConnectionBadge`, the rendered background color must match the color defined in `AppColors` for that status: `success` for `connected`, `disconnected` (orange) for `disconnected`, `accent` for `connecting`, and `error` for `error`.

**Validates: Requirements 3.10**

---

### Property 9: TradeTile Direction Color Is Consistent

*For any* `TradeTile` (on ActiveTradesScreen or TradeHistoryScreen), a `TradeDirection.buy` value must render the direction label with `AppColors.buyColor` (green) and a `TradeDirection.sell` value must render with `AppColors.sellColor` (red).

**Validates: Requirements 5.6, 9.4**

---

### Property 10: SignalTile Direction Color Is Consistent

*For any* `SignalTile`, a `TradeDirection.buy` direction must render with `AppColors.buyColor` and a `TradeDirection.sell` direction must render with `AppColors.sellColor`, consistent with TradeTile conventions.

**Validates: Requirements 6.5**

---

### Property 11: Filter Chip Selection Uses Gold Accent

*For any* filter chip selection on ActiveTradesScreen or TradeHistoryScreen, the selected chip must render with the gold accent color (`#D4AF37`) as its active color, and unselected chips must not use that color.

**Validates: Requirements 5.2, 9.2**

---

### Property 12: GlassCard Renders Without Error for Any Valid Configuration

*For any* combination of valid `borderRadius` (0–40), `blurSigma` (0–30), and `opacity` (0.0–1.0) values, a `GlassCard` must build and render without throwing an exception.

**Validates: Requirements 10.1**

---

### Property 13: PKCE Code Challenge Is Deterministically Derived from Verifier

*For any* `codeVerifier` string, re-computing `BASE64URL(SHA256(codeVerifier))` must produce the same `codeChallenge` that `PkceGenerator.generate()` embedded in the returned `PkceParams`, confirming the derivation is correct and reproducible.

**Validates: Requirements 2.5, 2.6**
