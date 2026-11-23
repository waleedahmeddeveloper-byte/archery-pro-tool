import '../models/result.dart';
import '../references/citations.dart';

class LetOffResult {
  const LetOffResult({
    required this.holdingWeightPounds,
    required this.letOffPercent,
    required this.peakDrawWeightPounds,
  });

  final double holdingWeightPounds;
  final double letOffPercent;
  final double peakDrawWeightPounds;
}

CalcResult<LetOffResult> holdingWeightFromLetOff({
  required double peakDrawWeightPounds,
  required double letOffPercent,
}) {
  requireFinitePositive('peak draw', peakDrawWeightPounds);
  requireFinitePositive('let-off', letOffPercent, allowZero: true);
  if (letOffPercent >= 100) {
    throw ValidationException('Let-off must be < 100%.');
  }
  final holding = peakDrawWeightPounds * (1 - letOffPercent / 100.0);
  return CalcResult(
    value: LetOffResult(
      holdingWeightPounds: holding,
      letOffPercent: letOffPercent,
      peakDrawWeightPounds: peakDrawWeightPounds,
    ),
    formulaId: 'let_off_holding',
    formulaDisplay: 'Holding = peak × (1 − let-off/100)',
    steps: [
      'Holding = ${peakDrawWeightPounds.toStringAsFixed(1)} × (1 − ${letOffPercent.toStringAsFixed(1)}/100) = ${holding.toStringAsFixed(2)} lb',
    ],
    assumptions: [
      'Manufacturer let-off percentage at the cam’s designed valley.',
    ],
    limitations: [
      'Actual holding weight varies with draw-stop position and cam timing.',
    ],
    safetyNotes: [
      'Do not exceed manufacturer draw-weight limits when adjusting limb bolts.',
    ],
    citation: Citations.iboEnergyScale,
  );
}

CalcResult<LetOffResult> letOffFromHoldingWeight({
  required double peakDrawWeightPounds,
  required double holdingWeightPounds,
}) {
  requireFinitePositive('peak draw', peakDrawWeightPounds);
  requireFinitePositive('holding', holdingWeightPounds);
  if (holdingWeightPounds > peakDrawWeightPounds) {
    throw ValidationException('Holding weight cannot exceed peak draw weight.');
  }
  final letOff =
      (1 - holdingWeightPounds / peakDrawWeightPounds) * 100.0;
  return CalcResult(
    value: LetOffResult(
      holdingWeightPounds: holdingWeightPounds,
      letOffPercent: letOff,
      peakDrawWeightPounds: peakDrawWeightPounds,
    ),
    formulaId: 'let_off_from_holding',
    formulaDisplay: 'Let-off% = (1 − holding/peak) × 100',
    steps: [
      'Let-off = (1 − ${holdingWeightPounds.toStringAsFixed(2)}/${peakDrawWeightPounds.toStringAsFixed(1)}) × 100 = ${letOff.toStringAsFixed(1)}%',
    ],
    assumptions: const ['Measured with a bow scale at full draw valley.'],
    limitations: const ['Scale technique affects reading.'],
    safetyNotes: const ['Use a calibrated bow scale.'],
    citation: Citations.iboEnergyScale,
  );
}
