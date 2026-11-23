import '../models/components.dart';
import '../models/result.dart';
import '../references/citations.dart';

enum FocMethod { measuredBalancePoint, componentEstimate }

class FocResult {
  const FocResult({
    required this.focPercent,
    required this.method,
    required this.arrowLengthInches,
    required this.balancePointInches,
    this.totalGrains,
  });

  final double focPercent;
  final FocMethod method;
  final double arrowLengthInches;
  final double balancePointInches;
  final double? totalGrains;

  String get methodLabel => switch (method) {
        FocMethod.measuredBalancePoint => 'Measured balance-point (AMO)',
        FocMethod.componentEstimate => 'Component-based estimate',
      };
}

/// AMO/ATA FOC from measured balance point.
CalcResult<FocResult> calculateFocMeasured({
  required double arrowLengthInches,
  required double balancePointFromNockInches,
}) {
  requireFinitePositive('arrow length', arrowLengthInches);
  requireFinitePositive('balance point', balancePointFromNockInches);
  if (balancePointFromNockInches > arrowLengthInches * 1.5) {
    throw ValidationException(
      'Balance point looks unrealistic vs arrow length. Measure from nock throat.',
    );
  }

  final mid = arrowLengthInches / 2.0;
  final foc = ((balancePointFromNockInches - mid) / arrowLengthInches) * 100.0;

  return CalcResult(
    value: FocResult(
      focPercent: foc,
      method: FocMethod.measuredBalancePoint,
      arrowLengthInches: arrowLengthInches,
      balancePointInches: balancePointFromNockInches,
    ),
    formulaId: 'foc_amo_measured',
    formulaDisplay: 'FOC% = ((A − L/2) / L) × 100',
    steps: [
      'L = ${arrowLengthInches.toStringAsFixed(3)} in',
      'A = ${balancePointFromNockInches.toStringAsFixed(3)} in',
      'Midpoint L/2 = ${mid.toStringAsFixed(3)} in',
      'FOC = ((${balancePointFromNockInches.toStringAsFixed(3)} − ${mid.toStringAsFixed(3)}) / ${arrowLengthInches.toStringAsFixed(3)}) × 100 = ${foc.toStringAsFixed(2)}%',
    ],
    assumptions: [
      'Arrow fully assembled (point, insert, nock, fletching).',
      'L measured nock throat → end of shaft (not tip of point).',
      'A measured nock throat → balance fulcrum.',
    ],
    limitations: [
      'Measurement error of 1/8 in on a 29 in arrow shifts FOC by ~0.4 points.',
    ],
    safetyNotes: [
      'High FOC with a weak dynamic spine can destabilize broadheads. Recheck spine after >25 gr tip changes.',
      'Results are for planning; verify flight with field points and broadheads.',
    ],
    citation: Citations.focAmo,
    metadata: {'method': 'measured'},
  );
}

/// Rough component-based FOC estimate treating shaft mass as uniform and
/// concentrating front/rear component masses at tip and nock.
///
/// This is explicitly labeled as an **estimate**, not a substitute for a
/// physical balance measurement.
CalcResult<FocResult> calculateFocFromComponents({
  required ArrowComponents components,
}) {
  requireFinitePositive('GPI', components.gpi);
  requireFinitePositive('shaft length', components.shaftLengthInches);

  final L = components.shaftLengthInches;
  final shaft = components.shaftGrains;
  final front = components.frontGrains;
  final rear = components.rearGrains;
  final total = components.totalGrains;
  if (total <= 0) {
    throw ValidationException('Total arrow mass must be > 0');
  }

  // Uniform shaft CM at L/2; front mass at tip (L); rear mass at nock (0).
  final moment = shaft * (L / 2.0) + front * L + rear * 0.0;
  final balance = moment / total;
  final foc = ((balance - L / 2.0) / L) * 100.0;

  return CalcResult(
    value: FocResult(
      focPercent: foc,
      method: FocMethod.componentEstimate,
      arrowLengthInches: L,
      balancePointInches: balance,
      totalGrains: total,
    ),
    formulaId: 'foc_component_estimate',
    formulaDisplay:
        'Estimate balance from component masses; then FOC% = ((A − L/2) / L) × 100',
    steps: [
      'Shaft mass ${shaft.toStringAsFixed(2)} gr at mid-shaft',
      'Front mass ${front.toStringAsFixed(2)} gr at tip',
      'Rear mass ${rear.toStringAsFixed(2)} gr at nock',
      'Estimated balance A = ${balance.toStringAsFixed(3)} in',
      'FOC ≈ ${foc.toStringAsFixed(2)}% (component estimate)',
    ],
    assumptions: [
      'Shaft density treated as uniform along cut length.',
      'Front components lumped at shaft tip; rear at nock throat.',
      'Ignores wrap/vane longitudinal distribution detail.',
    ],
    limitations: [
      'Can disagree with a scale/balance measurement by 1–3 FOC points.',
      'Always prefer measured balance-point FOC for hunting builds.',
    ],
    safetyNotes: [
      'Label shown in UI must remain “component estimate”.',
      'Validate with physical FOC measurement before hunting.',
    ],
    citation: Citations.focAmo,
    warnings: [
      'Method: component-based estimate (not measured balance point).',
    ],
    metadata: {'method': 'component_estimate'},
  );
}
