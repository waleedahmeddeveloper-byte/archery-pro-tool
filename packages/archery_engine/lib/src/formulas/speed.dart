import 'dart:math' as math;

import '../models/result.dart';
import '../models/units.dart';
import '../references/citations.dart';
import 'energy.dart';

class SpeedEstimateResult {
  const SpeedEstimateResult({
    required this.speedFps,
    required this.speedMs,
    required this.keFtLb,
    required this.momentumSlugFtPerSec,
  });

  final double speedFps;
  final double speedMs;
  final double keFtLb;
  final double momentumSlugFtPerSec;
}

/// Estimate speed when arrow mass changes at roughly constant delivered energy.
CalcResult<SpeedEstimateResult> estimateSpeedFromMassChange({
  required double referenceSpeedFps,
  required double referenceWeightGrains,
  required double newWeightGrains,
  double efficiencyPercent = 100,
}) {
  requireFinitePositive('reference speed', referenceSpeedFps);
  requireFinitePositive('reference weight', referenceWeightGrains);
  requireFinitePositive('new weight', newWeightGrains);
  requireFinitePositive('efficiency', efficiencyPercent);

  final eta = efficiencyPercent / 100.0;
  final speed =
      referenceSpeedFps *
      math.sqrt(referenceWeightGrains / newWeightGrains) *
      eta;
  final energy = calculateEnergyAndMomentum(
    arrowWeightGrains: newWeightGrains,
    speedFps: speed,
  );

  return CalcResult(
    value: SpeedEstimateResult(
      speedFps: speed,
      speedMs: Units.fpsToMs(speed),
      keFtLb: energy.value.keFtLb,
      momentumSlugFtPerSec: energy.value.momentumSlugFtPerSec,
    ),
    formulaId: 'speed_mass_ratio',
    formulaDisplay:
        'v = v_ref × √(w_ref / w_new) × (efficiency/100)',
    steps: [
      '√(w_ref/w_new) = √(${referenceWeightGrains.toStringAsFixed(1)}/${newWeightGrains.toStringAsFixed(1)}) = ${math.sqrt(referenceWeightGrains / newWeightGrains).toStringAsFixed(4)}',
      'v = ${referenceSpeedFps.toStringAsFixed(1)} × ${math.sqrt(referenceWeightGrains / newWeightGrains).toStringAsFixed(4)} × ${eta.toStringAsFixed(2)} = ${speed.toStringAsFixed(1)} fps',
      'KE ≈ ${energy.value.keFtLb.toStringAsFixed(2)} ft-lb',
    ],
    assumptions: [
      'Delivered bow energy is unchanged between the two arrows.',
      'Efficiency factor is a practical fudge — default 100% means pure √mass scaling.',
    ],
    limitations: [
      'Cannot replace a chronograph.',
      'Extremely light arrows may violate bow minimums and change efficiency.',
    ],
    safetyNotes: [
      'Respect manufacturer minimum arrow weight.',
      'Label UI output as an estimate.',
    ],
    citation: Citations.speedMassRatio,
  );
}

class IboSpeedResult {
  const IboSpeedResult({
    required this.estimatedFps,
    required this.energyModelFps,
    required this.ruleOfThumbFps,
  });

  final double estimatedFps;
  final double energyModelFps;
  final double ruleOfThumbFps;
}

/// Adjust published IBO speed toward a real hunting/target setup.
///
/// Energy model: derive KE at IBO (350 gr), scale by draw weight and a simple
/// power-stroke ratio proxy, then solve speed for the user's arrow (+ string
/// accessory grains). Also returns a classic shop rule-of-thumb for comparison.
CalcResult<IboSpeedResult> estimateSpeedFromIbo({
  required double iboFps,
  required double drawWeightPounds,
  required double drawLengthInches,
  required double arrowWeightGrains,
  double stringAccessoryGrains = 0,
  double braceHeightInches = 6.5,
}) {
  requireFinitePositive('IBO', iboFps);
  requireFinitePositive('draw weight', drawWeightPounds);
  requireFinitePositive('draw length', drawLengthInches);
  requireFinitePositive('arrow weight', arrowWeightGrains);
  requireFiniteNonNegative('string accessories', stringAccessoryGrains);

  // IBO energy into 350 gr test arrow.
  final iboKe = (350.0 * iboFps * iboFps) / Units.keDivisor;
  final powerStroke = math.max(0.1, drawLengthInches - 1.75 - braceHeightInches);
  const iboPowerStroke = 30.0 - 1.75 - 6.5; // ~21.75 in nominal
  final gpp = arrowWeightGrains / drawWeightPounds;
  final heavyArrowBonus = math.pow(gpp / 5.0, 0.1).toDouble();
  final scaledKe = iboKe *
      (drawWeightPounds / 70.0) *
      (powerStroke / iboPowerStroke) *
      heavyArrowBonus;
  final effectiveMass = arrowWeightGrains + stringAccessoryGrains;
  final energyFps =
      math.sqrt(scaledKe * Units.keDivisor / effectiveMass);

  // Shop rule of thumb vs 70/30/350.
  var thumb = iboFps;
  thumb -= (70.0 - drawWeightPounds) * 2.0;
  thumb -= (30.0 - drawLengthInches) * 10.0;
  thumb -= (arrowWeightGrains - 350.0) / 3.0;
  thumb -= stringAccessoryGrains / 3.0;

  final blended = (energyFps * 0.65) + (thumb * 0.35);

  return CalcResult(
    value: IboSpeedResult(
      estimatedFps: blended,
      energyModelFps: energyFps,
      ruleOfThumbFps: thumb,
    ),
    formulaId: 'ibo_to_real_speed',
    formulaDisplay:
        'Scale IBO KE by DW & power-stroke proxy; v = √(KE × 450240 / grains)',
    steps: [
      'IBO KE ≈ ${iboKe.toStringAsFixed(1)} ft-lb at 350 gr',
      'Power stroke proxy ≈ ${powerStroke.toStringAsFixed(2)} in',
      'Scaled KE ≈ ${scaledKe.toStringAsFixed(1)} ft-lb',
      'Energy-model speed ≈ ${energyFps.toStringAsFixed(1)} fps',
      'Rule-of-thumb speed ≈ ${thumb.toStringAsFixed(1)} fps',
      'Reported estimate (blend) ≈ ${blended.toStringAsFixed(1)} fps',
    ],
    assumptions: [
      'IBO baseline treated as 70 lb / 30 in / 350 gr / bare string.',
      'Brace height default 6.5 in if not measured.',
      'Blend weights energy model 65% / rule-of-thumb 35%.',
    ],
    limitations: [
      'Different cam profiles and bow efficiencies vary widely.',
      'Not a substitute for chronograph data.',
    ],
    safetyNotes: [
      'Always label as estimate in the UI.',
      'Do not use estimated fps alone for sight tapes without range confirmation.',
    ],
    citation: Citations.iboEnergyScale,
  );
}
