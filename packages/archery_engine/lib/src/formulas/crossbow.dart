import 'dart:math' as math;

import '../models/result.dart';
import '../references/citations.dart';
import 'energy.dart';

class CrossbowSpeedResult {
  const CrossbowSpeedResult({
    required this.estimatedFps,
    required this.keFtLb,
    required this.momentumSlugFtPerSec,
  });

  final double estimatedFps;
  final double keFtLb;
  final double momentumSlugFtPerSec;
}

/// Scale a published crossbow speed rating from a reference bolt weight.
CalcResult<CrossbowSpeedResult> estimateCrossbowSpeed({
  required double ratedSpeedFps,
  required double ratedBoltGrains,
  required double yourBoltGrains,
}) {
  requireFinitePositive('rated speed', ratedSpeedFps);
  requireFinitePositive('rated bolt', ratedBoltGrains);
  requireFinitePositive('your bolt', yourBoltGrains);

  final speed =
      ratedSpeedFps * math.sqrt(ratedBoltGrains / yourBoltGrains);
  final em = calculateEnergyAndMomentum(
    arrowWeightGrains: yourBoltGrains,
    speedFps: speed,
  );

  return CalcResult(
    value: CrossbowSpeedResult(
      estimatedFps: speed,
      keFtLb: em.value.keFtLb,
      momentumSlugFtPerSec: em.value.momentumSlugFtPerSec,
    ),
    formulaId: 'crossbow_speed',
    formulaDisplay:
        'v ≈ v_rated × √(w_rated / w_yours)  [constant-energy assumption]',
    steps: [
      'v = ${ratedSpeedFps.toStringAsFixed(0)} × √(${ratedBoltGrains.toStringAsFixed(0)}/${yourBoltGrains.toStringAsFixed(0)}) = ${speed.toStringAsFixed(1)} fps',
      'KE ≈ ${em.value.keFtLb.toStringAsFixed(1)} ft-lb',
      'Momentum ≈ ${em.value.momentumSlugFtPerSec.toStringAsFixed(3)} slug·ft/s',
    ],
    assumptions: [
      'Manufacturer rating energy roughly conserved when bolt mass changes.',
      'No cocking aid / string accessory mass modeled.',
    ],
    limitations: [
      'Crossbow manuals set minimum bolt weights — never go lighter.',
      'Estimate only; chronograph when possible.',
    ],
    safetyNotes: [
      'Shooting below the manufacturer minimum bolt weight risks dry-fire damage and injury.',
      'Always use manufacturer-approved bolts and tips.',
    ],
    citation: Citations.speedMassRatio,
  );
}

CalcResult<String> crossbowBoltSelectionGuide({
  required double ratedSpeedFps,
  required double drawWeightPounds,
}) {
  requireFinitePositive('rated speed', ratedSpeedFps);
  requireFinitePositive('draw weight', drawWeightPounds);

  String band;
  if (ratedSpeedFps < 300) {
    band = 'Often 350–400+ gr finished bolts on slower platforms — verify manual minimum.';
  } else if (ratedSpeedFps < 370) {
    band = 'Common hunting bolts often 400–450 gr finished; confirm manufacturer minimum.';
  } else {
    band = 'High-speed platforms still require the posted minimum mass — lighter is not safer.';
  }

  return CalcResult(
    value: band,
    formulaId: 'crossbow_bolt_guide',
    formulaDisplay: 'Guidance table by rated speed (not a formula)',
    steps: [
      'Rated speed ${ratedSpeedFps.toStringAsFixed(0)} fps, draw ${drawWeightPounds.toStringAsFixed(0)} lb',
      band,
    ],
    assumptions: [
      'General planning guidance only — manuals override this text.',
    ],
    limitations: [
      'Does not replace the crossbow’s owner manual minimum bolt weight.',
    ],
    safetyNotes: [
      'Never shoot below the minimum bolt weight printed by the manufacturer.',
    ],
    citation: Citations.gppSafety,
  );
}

double crossbowMinimumBoltGrainsHeuristic(double drawWeightPounds) {
  // Common shop heuristic floor — still subordinate to the manual.
  requireFinitePositive('draw weight', drawWeightPounds);
  return math.max(350.0, drawWeightPounds * 2.5);
}
