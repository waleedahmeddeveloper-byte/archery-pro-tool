import '../models/result.dart';
import '../references/citations.dart';
import 'ballistics.dart';

class SightPinGapResult {
  const SightPinGapResult({
    required this.gapsInches,
    required this.peepToSightInches,
  });

  /// Gap between consecutive pins in the list order of [distancesYards].
  final List<({double fromYd, double toYd, double gapInches})> gapsInches;
  final double peepToSightInches;
}

/// Approximate pin spacing from trajectory drop differences and peep-to-sight geometry.
CalcResult<SightPinGapResult> calculateSightPinGaps({
  required double speedFps,
  required double zeroYards,
  required double peepToSightInches,
  List<double> distancesYards = const [20, 30, 40, 50, 60],
  double sightHeightInches = 3.5,
}) {
  requireFinitePositive('speed', speedFps);
  requireFinitePositive('zero', zeroYards);
  requireFinitePositive('peep-to-sight', peepToSightInches);

  final traj = calculateGravityTrajectory(
    speedFps: speedFps,
    zeroYards: zeroYards,
    distancesYards: distancesYards,
    sightHeightInches: sightHeightInches,
  );

  final gaps = <({double fromYd, double toYd, double gapInches})>[];
  for (var i = 0; i < traj.value.points.length - 1; i++) {
    final a = traj.value.points[i];
    final b = traj.value.points[i + 1];
    // Angular difference ≈ Δdrop / distance; gap on sight ≈ angle × peep distance.
    // Using difference in LOS drop converted through small-angle geometry:
    final deltaDropIn = b.dropInchesFromLineOfSight - a.dropInchesFromLineOfSight;
    final meanDistIn = ((a.distanceYards + b.distanceYards) / 2.0) * 36.0;
    final gap = (deltaDropIn / meanDistIn) * peepToSightInches;
    gaps.add((fromYd: a.distanceYards, toYd: b.distanceYards, gapInches: gap.abs()));
  }

  return CalcResult(
    value: SightPinGapResult(
      gapsInches: gaps,
      peepToSightInches: peepToSightInches,
    ),
    formulaId: 'sight_pin_gap',
    formulaDisplay:
        'Pin gap ≈ (Δdrop / mean_distance) × peep-to-sight (small-angle)',
    steps: [
      for (final g in gaps)
        '${g.fromYd.toStringAsFixed(0)}→${g.toYd.toStringAsFixed(0)} yd: ${g.gapInches.toStringAsFixed(3)} in',
    ],
    assumptions: [
      'Uses gravity-only trajectory under the hood.',
      'Peep-to-sight measured along the sight plane.',
    ],
    limitations: [
      'Real sights, peep stretch, and drag change gaps — verify on the range.',
    ],
    safetyNotes: [
      'Confirm every pin with live groups before hunting.',
    ],
    citation: Citations.gravityDrop,
  );
}
