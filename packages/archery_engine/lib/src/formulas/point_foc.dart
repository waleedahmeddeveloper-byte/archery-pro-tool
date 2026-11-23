import '../models/result.dart';
import '../references/citations.dart';

/// Estimate point-weight change needed to move FOC toward a target.
///
/// Uses a lumped-mass approximation: adding Δm at the tip shifts the balance
/// point. This is a planning aid — re-measure FOC after changing hardware.
CalcResult<double> pointWeightForTargetFoc({
  required double arrowLengthInches,
  required double currentTotalGrains,
  required double currentFocPercent,
  required double targetFocPercent,
}) {
  requireFinitePositive('length', arrowLengthInches);
  requireFinitePositive('current total', currentTotalGrains);

  final L = arrowLengthInches;
  final currentA = (currentFocPercent / 100.0) * L + L / 2.0;
  final targetA = (targetFocPercent / 100.0) * L + L / 2.0;

  // Current moment about nock: M = m * A
  // After adding tip mass δ: (m+δ)*(approx tip at L) contribution:
  // New A' = (m*A + δ*L) / (m+δ) = targetA
  // m*A + δ*L = targetA*(m+δ)
  // δ*L - targetA*δ = targetA*m - m*A
  // δ*(L - targetA) = m*(targetA - A)
  final denom = L - targetA;
  if (denom.abs() < 1e-6) {
    throw ValidationException('Target FOC implies an unreachable balance point.');
  }
  final delta = currentTotalGrains * (targetA - currentA) / denom;

  return CalcResult(
    value: delta,
    formulaId: 'point_weight_for_foc',
    formulaDisplay:
        'Solve tip mass δ from A′ = (mA + δL)/(m+δ) for target FOC',
    steps: [
      'Current A ≈ ${currentA.toStringAsFixed(3)} in',
      'Target A ≈ ${targetA.toStringAsFixed(3)} in',
      'Suggested tip-mass change δ ≈ ${delta.toStringAsFixed(1)} gr '
          '(positive = add front weight)',
    ],
    assumptions: [
      'Added mass is treated as concentrated at the tip of the shaft.',
      'Shaft length held constant.',
    ],
    limitations: [
      'Inserts, weight screws, and broadhead CG differ from a tip point-mass.',
      'Always re-measure FOC and recheck spine after large tip changes.',
    ],
    safetyNotes: [
      'Large tip-weight increases weaken dynamic spine — bare-shaft tune after changes >25 gr.',
    ],
    citation: Citations.focAmo,
  );
}
