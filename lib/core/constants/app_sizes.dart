/// Raw dimension constants for the HT BOT UI.
///
/// All values are plain [double]s. Apply flutter_screenutil extensions at
/// usage sites:
///   - `.r`  for border radii  (e.g. `AppSizes.cardRadius.r`)
///   - `.w`  for widths        (e.g. `AppSizes.defaultPadding.w`)
///   - `.h`  for heights       (e.g. `AppSizes.buttonHeight.h`)
///   - `.sp` for font sizes
abstract final class AppSizes {
  // ── Card border radii ───────────────────────────────────────────────────
  static const double cardRadiusSmall   = 12;
  static const double cardRadius        = 16; // default
  static const double cardRadiusLarge   = 20;

  // ── Padding / spacing ───────────────────────────────────────────────────
  static const double paddingSmall      = 8;
  static const double defaultPadding    = 16; // default
  static const double paddingLarge      = 24;

  // ── Button ──────────────────────────────────────────────────────────────
  static const double buttonHeight      = 48;

  // ── Icon sizes ──────────────────────────────────────────────────────────
  static const double iconSmall         = 16;
  static const double iconMedium        = 24;
  static const double iconLarge         = 32;

  // ── Navigation ──────────────────────────────────────────────────────────
  static const double drawerWidth       = 280;
  static const double bottomNavHeight   = 60;
}
