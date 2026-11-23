import '../models/result.dart';
import '../models/units.dart';
import '../references/citations.dart';

class EnergyMomentumResult {
  const EnergyMomentumResult({
    required this.keFtLb,
    required this.keJoules,
    required this.momentumSlugFtPerSec,
    required this.momentumKgMPerSec,
  });

  final double keFtLb;
  final double keJoules;
  final double momentumSlugFtPerSec;
  final double momentumKgMPerSec;
}

CalcResult<EnergyMomentumResult> calculateEnergyAndMomentum({
  required double arrowWeightGrains,
  required double speedFps,
}) {
  requireFinitePositive('arrow weight', arrowWeightGrains);
  requireFinitePositive('speed', speedFps);

  final ke = (arrowWeightGrains * speedFps * speedFps) / Units.keDivisor;
  final mom = (arrowWeightGrains * speedFps) / Units.momentumDivisor;
  final keJ = Units.ftLbToJoules(ke);
  final momSi = mom * Units.slugFtPerSecToKgMPerSec;

  return CalcResult(
    value: EnergyMomentumResult(
      keFtLb: ke,
      keJoules: keJ,
      momentumSlugFtPerSec: mom,
      momentumKgMPerSec: momSi,
    ),
    formulaId: 'ke_momentum',
    formulaDisplay:
        'KE = (gr × fps²) / 450240 · Momentum = (gr × fps) / 225218',
    steps: [
      'gr = ${arrowWeightGrains.toStringAsFixed(1)}, fps = ${speedFps.toStringAsFixed(1)}',
      'fps² = ${(speedFps * speedFps).toStringAsFixed(1)}',
      'KE = ${arrowWeightGrains.toStringAsFixed(1)} × ${(speedFps * speedFps).toStringAsFixed(1)} / 450240 = ${ke.toStringAsFixed(2)} ft-lb',
      'KE = ${keJ.toStringAsFixed(2)} J',
      'Momentum = ${arrowWeightGrains.toStringAsFixed(1)} × ${speedFps.toStringAsFixed(1)} / 225218 = ${mom.toStringAsFixed(3)} slug·ft/s',
      'Momentum = ${momSi.toStringAsFixed(3)} kg·m/s',
    ],
    assumptions: [
      'Weight is finished-arrow grains on a scale.',
      'Speed is chronographed (preferred) or a carefully labeled estimate.',
    ],
    limitations: [
      'KE and momentum at the bow do not equal impact values after drag.',
      'Game “minimums” are hunter guidelines, not legal standards.',
    ],
    safetyNotes: [
      'Do not use inflated IBO speeds to invent hunting energy numbers.',
      'Shot placement and broadhead design matter more than a single metric.',
    ],
    citation: Citations.keFtLb,
  );
}

CalcResult<double> calculateKineticEnergyFtLb({
  required double arrowWeightGrains,
  required double speedFps,
}) {
  final both = calculateEnergyAndMomentum(
    arrowWeightGrains: arrowWeightGrains,
    speedFps: speedFps,
  );
  return CalcResult(
    value: both.value.keFtLb,
    formulaId: 'ke_only',
    formulaDisplay: both.formulaDisplay,
    steps: both.steps,
    assumptions: both.assumptions,
    limitations: both.limitations,
    safetyNotes: both.safetyNotes,
    citation: Citations.keFtLb,
  );
}

CalcResult<double> calculateMomentumSlugFtPerSec({
  required double arrowWeightGrains,
  required double speedFps,
}) {
  final both = calculateEnergyAndMomentum(
    arrowWeightGrains: arrowWeightGrains,
    speedFps: speedFps,
  );
  return CalcResult(
    value: both.value.momentumSlugFtPerSec,
    formulaId: 'momentum_only',
    formulaDisplay: both.formulaDisplay,
    steps: both.steps,
    assumptions: both.assumptions,
    limitations: both.limitations,
    safetyNotes: both.safetyNotes,
    citation: Citations.momentumSlug,
  );
}
