import '../models/components.dart';

class SpineMatch {
  const SpineMatch({
    required this.primary,
    required this.alternate,
    required this.chartName,
  });

  final int primary;
  final int? alternate;
  final String chartName;
}

/// Approximate planning bands for compound vs finger-released recurve.
///
/// These are **not** copies of any manufacturer chart. They encode commonly
/// taught shop ranges for initial selection and are always labeled as planning
/// aids in the UI.
class SpinePlanningChart {
  SpinePlanningChart._();

  static const compoundChartName = 'Arcus compound planning chart v1';
  static const recurveChartName = 'Arcus recurve/traditional planning chart v1';

  /// Compound bands: (maxEffectiveLb, spine)
  static const _compoundBands = <(double, int)>[
    (35, 600),
    (40, 500),
    (45, 500),
    (50, 400),
    (55, 400),
    (62, 400),
    (68, 340),
    (75, 340),
    (82, 300),
    (90, 300),
    (100, 250),
    (120, 200),
  ];

  static const _recurveBands = <(double, int)>[
    (25, 1000),
    (30, 900),
    (35, 800),
    (40, 700),
    (45, 600),
    (50, 500),
    (55, 500),
    (60, 400),
    (65, 400),
    (70, 340),
    (80, 300),
  ];

  static SpineMatch match({
    required BowType bowType,
    required double effectiveWeightPounds,
  }) {
    final bands = switch (bowType) {
      BowType.compound => _compoundBands,
      BowType.recurve || BowType.traditional => _recurveBands,
      BowType.crossbow => _compoundBands,
    };
    final name = switch (bowType) {
      BowType.compound => compoundChartName,
      BowType.recurve || BowType.traditional => recurveChartName,
      BowType.crossbow => compoundChartName,
    };

    int? chosen;
    for (final (maxLb, spine) in bands) {
      if (effectiveWeightPounds <= maxLb) {
        chosen = spine;
        break;
      }
    }
    chosen ??= bands.last.$2;

    // Near boundaries, suggest adjacent spine for testing.
    int? alternate;
    final idx = bands.indexWhere((e) => e.$2 == chosen);
    if (idx > 0) {
      final prevMax = bands[idx - 1].$1;
      if ((effectiveWeightPounds - prevMax).abs() <= 3) {
        alternate = bands[idx - 1].$2;
      }
    }
    if (idx >= 0 && idx < bands.length - 1) {
      final thisMax = bands[idx].$1;
      if ((thisMax - effectiveWeightPounds).abs() <= 3) {
        alternate = bands[idx + 1].$2;
      }
    }
    if (alternate == chosen) alternate = null;

    return SpineMatch(primary: chosen, alternate: alternate, chartName: name);
  }
}
