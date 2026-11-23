import 'dart:math' as math;

import '../models/result.dart';
import '../references/citations.dart';
import 'energy.dart';

class DownrangePoint {
  const DownrangePoint({
    required this.yards,
    required this.speedFps,
    required this.keFtLb,
    required this.momentumSlugFtPerSec,
  });

  final double yards;
  final double speedFps;
  final double keFtLb;
  final double momentumSlugFtPerSec;
}

class DownrangeResult {
  const DownrangeResult({
    required this.points,
    required this.dragPerSecond,
  });

  final List<DownrangePoint> points;
  final double dragPerSecond;
}

/// First-order exponential speed loss model for planning tables.
CalcResult<DownrangeResult> calculateDownrange({
  required double launchSpeedFps,
  required double arrowWeightGrains,
  double dragPerSecond = 0.08,
  List<double> distancesYards = const [0, 20, 30, 40, 50, 60],
}) {
  requireFinitePositive('launch speed', launchSpeedFps);
  requireFinitePositive('arrow weight', arrowWeightGrains);
  requireFiniteNonNegative('drag', dragPerSecond);

  final points = <DownrangePoint>[];
  for (final yd in distancesYards) {
    final feet = yd * 3.0;
    final t = dragPerSecond == 0
        ? feet / launchSpeedFps
        : () {
            final kxOverV = dragPerSecond * feet / launchSpeedFps;
            if (kxOverV >= 0.95) return feet / (launchSpeedFps * 0.5);
            return -math.log(1 - kxOverV) / dragPerSecond;
          }();
    final speed = launchSpeedFps * math.exp(-dragPerSecond * t);
    final em = calculateEnergyAndMomentum(
      arrowWeightGrains: arrowWeightGrains,
      speedFps: speed,
    );
    points.add(
      DownrangePoint(
        yards: yd,
        speedFps: speed,
        keFtLb: em.value.keFtLb,
        momentumSlugFtPerSec: em.value.momentumSlugFtPerSec,
      ),
    );
  }

  return CalcResult(
    value: DownrangeResult(points: points, dragPerSecond: dragPerSecond),
    formulaId: 'downrange_energy',
    formulaDisplay: 'v(t) ≈ v0 e^{-kt}; KE/momentum from remaining speed',
    steps: [
      for (final p in points)
        '${p.yards.toStringAsFixed(0)} yd → ${p.speedFps.toStringAsFixed(1)} fps, '
            '${p.keFtLb.toStringAsFixed(1)} ft-lb, '
            '${p.momentumSlugFtPerSec.toStringAsFixed(3)} slug·ft/s',
    ],
    assumptions: [
      'Drag coefficient k is a planning assumption, not a measured Cd.',
      'No wind; flat fire.',
    ],
    limitations: [
      'Not a full ballistic solver. Calibrate k against chronograph + known marks.',
    ],
    safetyNotes: [
      'Do not use downrange estimates alone for long hunting shots.',
    ],
    citation: Citations.keFtLb,
  );
}

CalcResult<double> velocityLoss({
  required double launchSpeedFps,
  required double distanceYards,
  double dragPerSecond = 0.08,
}) {
  final table = calculateDownrange(
    launchSpeedFps: launchSpeedFps,
    arrowWeightGrains: 450,
    dragPerSecond: dragPerSecond,
    distancesYards: [0, distanceYards],
  );
  final loss = launchSpeedFps - table.value.points.last.speedFps;
  return CalcResult(
    value: loss,
    formulaId: 'velocity_loss',
    formulaDisplay: 'Δv = v0 − v(d) with first-order drag',
    steps: [
      'Launch ${launchSpeedFps.toStringAsFixed(1)} fps',
      'At ${distanceYards.toStringAsFixed(0)} yd ≈ ${table.value.points.last.speedFps.toStringAsFixed(1)} fps',
      'Loss ≈ ${loss.toStringAsFixed(1)} fps',
    ],
    assumptions: table.assumptions,
    limitations: table.limitations,
    safetyNotes: table.safetyNotes,
    citation: Citations.gravityDrop,
  );
}
