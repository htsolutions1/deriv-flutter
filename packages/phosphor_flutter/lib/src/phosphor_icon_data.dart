library phosphor_flutter;

import 'package:flutter/widgets.dart';

// Patched for Flutter 3.44+ where IconData is `final` and cannot be subclassed.
// Uses Dart 3.3 extension types — requires sdk: ">=3.3.0 <4.0.0" in pubspec.yaml.

/// Base Phosphor icon data. Wraps [IconData] as an extension type.
extension type const PhosphorIconData._(IconData _iconData) implements IconData {
  const PhosphorIconData(int codePoint, String style)
      : this._(IconData(
          codePoint,
          fontFamily: 'Phosphor$style',
          fontPackage: 'phosphor_flutter',
          matchTextDirection: true,
        ));
}

/// Flat (non-duotone) Phosphor icon data. Implements [PhosphorIconData].
extension type const PhosphorFlatIconData._(IconData _iconData)
    implements PhosphorIconData {
  const PhosphorFlatIconData(int codePoint, String style)
      : this._(IconData(
          codePoint,
          fontFamily: 'Phosphor$style',
          fontPackage: 'phosphor_flutter',
          matchTextDirection: true,
        ));
}

/// Duotone Phosphor icon data. Implements [PhosphorIconData].
extension type const PhosphorDuotoneIconData._(IconData _iconData)
    implements PhosphorIconData {
  const PhosphorDuotoneIconData(int codePoint, PhosphorIconData secondary)
      : this._(IconData(
          codePoint,
          fontFamily: 'PhosphorDuotone',
          fontPackage: 'phosphor_flutter',
          matchTextDirection: true,
        ));

  /// Reconstructs the secondary (background) icon from the primary codepoint.
  ///
  /// By Phosphor font convention the secondary glyph is always at
  /// `codePoint - 1` in the same Duotone font family.
  PhosphorIconData get secondary => PhosphorIconData._(IconData(
        _iconData.codePoint - 1,
        fontFamily: 'PhosphorDuotone',
        fontPackage: 'phosphor_flutter',
        matchTextDirection: true,
      ));
}
