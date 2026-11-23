import 'dart:math' as math;

import '../models/result.dart';
import '../models/units.dart';
import '../references/citations.dart';

class BowEnergyResult {
  const BowEnergyResult({
    required this.storedEnergyFtLbApprox,
    required this.arrowKeFtLb,
    required this.efficiencyPercent,
  });

  final double storedEnergyFtLbApprox;
  final double arrowKeFtLb;
  final double efficiencyPercent;
}

/// Approximate stored energy using a triangular draw-force assumption.
///
/// Stored ≈ ½ × peak draw weight (lbf) × power stroke (ft).
/// This is a planning estimate — real cams store energy differently.
CalcResult<BowEnergyResult> calculateBowEnergy({
  required double peakDrawWeightPounds,
  required double drawLengthInches,
  required double arrowWeightGrains,
  required double arrowSpeedFps,
  double braceHeightInches = 6.5,
  double letOffPercent = 80,
}) {
  requireFinitePositive('peak draw', peakDrawWeightPounds);
  requireFinitePositive('draw length', drawLengthInches);
  requireFinitePositive('arrow weight', arrowWeightGrains);
  requireFinitePositive('arrow speed', arrowSpeedFps);
  requireFinitePositive('brace height', braceHeightInches);
  requireFiniteNonNegative('let-off', letOffPercent);

  final powerStrokeIn = math.max(0.1, drawLengthInches - 1.75 - braceHeightInches);
  final powerStrokeFt = powerStrokeIn / 12.0;
  // Holding weight at valley is lower; use average of peak and holding as crude area.
  final holding = peakDrawWeightPounds * (1 - letOffPercent / 100.0);
  final avgForce = (peakDrawWeightPounds + holding) / 2.0;
  final stored = avgForce * powerStrokeFt; // ft-lbf ≈ ft-lb
  final ke = (arrowWeightGrains * arrowSpeedFps * arrowSpeedFps) / Units.keDivisor;
  final eff = stored <= 0 ? 0.0 : (ke / stored) * 100.0;

  return CalcResult(
    value: BowEnergyResult(
      storedEnergyFtLbApprox: stored,
      arrowKeFtLb: ke,
      efficiencyPercent: eff,
    ),
    formulaId: 'bow_energy_efficiency',
    formulaDisplay:
        'Stored ≈ avg(peak, holding) × power_stroke_ft; Eff% = KE_arrow / Stored × 100',
    steps: [
      'Power stroke ≈ ${powerStrokeIn.toStringAsFixed(2)} in (${powerStrokeFt.toStringAsFixed(3)} ft)',
      'Holding @ ${letOffPercent.toStringAsFixed(0)}% let-off ≈ ${holding.toStringAsFixed(1)} lb',
      'Avg force ≈ ${avgForce.toStringAsFixed(1)} lb',
      'Stored ≈ ${stored.toStringAsFixed(1)} ft-lb',
      'Arrow KE = ${ke.toStringAsFixed(1)} ft-lb',
      'Efficiency ≈ ${eff.toStringAsFixed(1)}%',
    ],
    assumptions: [
      'Triangular/average draw-force approximation — not a measured force curve.',
      'Power stroke proxy = draw length − 1.75 − brace height.',
    ],
    limitations: [
      'Modern cams are not triangular; efficiency can be mis-estimated by several points.',
      'Requires chronographed speed for meaningful efficiency.',
    ],
    safetyNotes: [
      'Do not exceed manufacturer draw-weight or limb limits.',
    ],
    citation: Citations.iboEnergyScale,
  );
}
