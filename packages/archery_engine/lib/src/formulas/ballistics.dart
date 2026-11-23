import 'dart:math' as math;

import '../models/result.dart';
import '../models/units.dart';
import '../references/citations.dart';

class DropPoint {
  const DropPoint({
    required this.distanceYards,
    required this.dropInchesFromLineOfSight,
    required this.timeOfFlightSec,
  });

  final double distanceYards;
  final double dropInchesFromLineOfSight;
  final double timeOfFlightSec;
}

class TrajectoryResult {
  const TrajectoryResult({
    required this.points,
    required this.modelName,
    required this.zeroYards,
    required this.launchSpeedFps,
  });

  final List<DropPoint> points;
  final String modelName;
  final double zeroYards;
  final double launchSpeedFps;
}

/// Gravity-only drop relative to a sight line with a zero distance.
///
/// Model:
/// - Constant horizontal speed (vacuum)
/// - Sight height above arrow
/// - Launch angle chosen so path crosses LOS at [zeroYards]
CalcResult<TrajectoryResult> calculateGravityTrajectory({
  required double speedFps,
  required double zeroYards,
  List<double> distancesYards = const [10, 20, 30, 40, 50, 60],
  double sightHeightInches = 3.5,
}) {
  requireFinitePositive('speed', speedFps);
  requireFinitePositive('zero', zeroYards);
  requireFinitePositive('sight height', sightHeightInches);

  final g = Units.gravityFtPerSec2;
  final sightFt = sightHeightInches / 12.0;
  final zeroFt = zeroYards * 3.0;

  // Solve launch angle so y(zero) = 0 in LOS frame where LOS is horizontal
  // through the pin. Arrow starts at y = -sightHeight.
  // y(x) = -sight + x*tanθ - g x² / (2 v² cos²θ)
  // For small angles, tanθ≈θ, cos≈1:
  // 0 = -sight + zero*θ - g zero² /(2 v²) => θ = (sight + g zero²/(2v²)) / zero
  final theta =
      (sightFt + (g * zeroFt * zeroFt) / (2 * speedFps * speedFps)) / zeroFt;

  final points = <DropPoint>[];
  for (final dYd in distancesYards) {
    final x = dYd * 3.0;
    final t = x / speedFps;
    final y = -sightFt + x * theta - (g * x * x) / (2 * speedFps * speedFps);
    // Positive drop means below LOS.
    final dropIn = (-y) * 12.0;
    points.add(
      DropPoint(
        distanceYards: dYd,
        dropInchesFromLineOfSight: dropIn,
        timeOfFlightSec: t,
      ),
    );
  }

  return CalcResult(
    value: TrajectoryResult(
      points: points,
      modelName: 'Gravity-only / constant speed (vacuum)',
      zeroYards: zeroYards,
      launchSpeedFps: speedFps,
    ),
    formulaId: 'gravity_trajectory',
    formulaDisplay:
        'y(x) = -h + x tanθ − g x² / (2 v²); θ set so y(zero)=0',
    steps: [
      'v = ${speedFps.toStringAsFixed(1)} fps, zero = ${zeroYards.toStringAsFixed(1)} yd, h = ${sightHeightInches.toStringAsFixed(2)} in',
      'Launch angle θ ≈ ${(theta * 180 / math.pi).toStringAsFixed(3)}°',
      for (final p in points)
        '${p.distanceYards.toStringAsFixed(0)} yd → ${p.dropInchesFromLineOfSight.toStringAsFixed(1)} in relative to LOS (t=${p.timeOfFlightSec.toStringAsFixed(3)} s)',
    ],
    assumptions: [
      'No aerodynamic drag (speed constant).',
      'Flat fire, no wind.',
      'Sight height constant above the shaft.',
    ],
    limitations: [
      'Real arrows decelerate; actual drop is larger, especially past 40–50 yd.',
      'Use the optional drag model for a second opinion, then trust holes on paper.',
    ],
    safetyNotes: [
      'Sight tapes from estimates must be verified at the range.',
      'Never invent long-range hunting shots from vacuum math alone.',
    ],
    citation: Citations.gravityDrop,
  );
}

/// Simple quadratic-drag horizontal deceleration model (optional advanced).
///
/// Uses a user-supplied ballistic coefficient style coefficient [dragPerSecond]
/// such that a = -k v² is approximated with dv/dt = -k v, giving
/// v(t)=v0 e^{-k t} as a transparent first-order loss model. Labeled clearly.
CalcResult<TrajectoryResult> calculateDragAwareTrajectory({
  required double speedFps,
  required double zeroYards,
  double dragPerSecond = 0.08,
  List<double> distancesYards = const [10, 20, 30, 40, 50, 60],
  double sightHeightInches = 3.5,
}) {
  requireFinitePositive('speed', speedFps);
  requireFinitePositive('zero', zeroYards);
  requireFiniteNonNegative('drag', dragPerSecond);

  final g = Units.gravityFtPerSec2;
  final sightFt = sightHeightInches / 12.0;

  double timeToDistance(double feet) {
    if (dragPerSecond == 0) return feet / speedFps;
    // x = (v0/k)(1 - e^{-k t}) => t = -ln(1 - k x / v0)/k
    final kxOverV = dragPerSecond * feet / speedFps;
    if (kxOverV >= 0.95) {
      // Pathologically high drag for this distance.
      return feet / (speedFps * 0.5);
    }
    return -math.log(1 - kxOverV) / dragPerSecond;
  }

  final tZero = timeToDistance(zeroYards * 3.0);
  // Choose theta so y(zero)=0 with variable t: y = -h + v0*θ*t_approx - ½gt²
  // Using initial vertical = v0*θ (small angle) and horizontal delay via t(x).
  final theta = (sightFt + 0.5 * g * tZero * tZero) / (speedFps * tZero);

  final points = <DropPoint>[];
  for (final dYd in distancesYards) {
    final t = timeToDistance(dYd * 3.0);
    final y = -sightFt + speedFps * theta * t - 0.5 * g * t * t;
    points.add(
      DropPoint(
        distanceYards: dYd,
        dropInchesFromLineOfSight: (-y) * 12.0,
        timeOfFlightSec: t,
      ),
    );
  }

  return CalcResult(
    value: TrajectoryResult(
      points: points,
      modelName:
          'First-order drag (k=${dragPerSecond.toStringAsFixed(3)} /s) + gravity',
      zeroYards: zeroYards,
      launchSpeedFps: speedFps,
    ),
    formulaId: 'drag_trajectory',
    formulaDisplay:
        'Approximate v(t)=v0 e^{-kt}; drop from gravity over t(x)',
    steps: [
      'k = ${dragPerSecond.toStringAsFixed(3)} /s (user assumption)',
      't(zero) = ${tZero.toStringAsFixed(3)} s',
      for (final p in points)
        '${p.distanceYards.toStringAsFixed(0)} yd → ${p.dropInchesFromLineOfSight.toStringAsFixed(1)} in (t=${p.timeOfFlightSec.toStringAsFixed(3)} s)',
    ],
    assumptions: [
      'Drag coefficient is a simplifying assumption, not a wind-tunnel Cd.',
      'No windage / Magnus / fishtailing modeled.',
    ],
    limitations: [
      'Not a full 6-DOF ballistic solver.',
      'Default k is illustrative — calibrate against chronograph + known marks.',
    ],
    safetyNotes: [
      'Advanced estimate still requires range validation.',
    ],
    citation: Citations.gravityDrop,
    warnings: [
      'Drag model is approximate; show assumptions in UI.',
    ],
  );
}

CalcResult<double> trueHorizontalDistance({
  required double lineOfSightYards,
  required double angleDegrees,
}) {
  requireFinitePositive('LOS distance', lineOfSightYards);
  final rad = angleDegrees.abs() * math.pi / 180.0;
  final horiz = lineOfSightYards * math.cos(rad);
  return CalcResult(
    value: horiz,
    formulaId: 'shot_angle',
    formulaDisplay: 'Horizontal distance = LOS × cos(angle)',
    steps: [
      'LOS = ${lineOfSightYards.toStringAsFixed(1)} yd',
      'Angle = ${angleDegrees.toStringAsFixed(1)}°',
      'Horizontal ≈ ${horiz.toStringAsFixed(1)} yd',
    ],
    assumptions: [
      'Angle measured from horizontal; uphill/downhill treated symmetrically for distance.',
    ],
    limitations: [
      'Does not automatically adjust pin for gravity along the slope path.',
    ],
    safetyNotes: [
      'Practice angled shots; do not invent steep-angle hunting shots from math alone.',
    ],
    citation: Citations.gravityDrop,
  );
}
