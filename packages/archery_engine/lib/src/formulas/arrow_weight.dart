import '../models/components.dart';
import '../models/result.dart';
import '../references/citations.dart';

class ArrowWeightResult {
  const ArrowWeightResult({
    required this.totalGrains,
    required this.shaftGrains,
    required this.frontGrains,
    required this.rearGrains,
    required this.grainsPerPound,
    required this.minimumSuggestedGrains,
  });

  final double totalGrains;
  final double shaftGrains;
  final double frontGrains;
  final double rearGrains;
  final double? grainsPerPound;
  final double? minimumSuggestedGrains;
}

/// Total arrow weight from GPI × length + components.
CalcResult<ArrowWeightResult> calculateArrowWeight({
  required ArrowComponents components,
  double? drawWeightPounds,
  double minimumGpp = 5.0,
}) {
  requireFinitePositive('GPI', components.gpi);
  requireFinitePositive('shaft length', components.shaftLengthInches);
  requireFiniteNonNegative('point', components.pointGrains);
  requireFiniteNonNegative('insert', components.insertGrains);
  if (components.vaneCount < 0) {
    throw ValidationException('vane count must be ≥ 0');
  }
  if (drawWeightPounds != null) {
    requireFinitePositive('draw weight', drawWeightPounds);
  }

  final total = components.totalGrains;
  final gpp =
      drawWeightPounds == null ? null : total / drawWeightPounds;
  final minGrains =
      drawWeightPounds == null ? null : drawWeightPounds * minimumGpp;

  final warnings = <String>[];
  if (gpp != null && gpp < minimumGpp) {
    warnings.add(
      'Calculated GPP (${gpp.toStringAsFixed(2)}) is below the ${minimumGpp.toStringAsFixed(0)} gpp safety floor. Check your bow manual.',
    );
  }

  return CalcResult(
    value: ArrowWeightResult(
      totalGrains: total,
      shaftGrains: components.shaftGrains,
      frontGrains: components.frontGrains,
      rearGrains: components.rearGrains,
      grainsPerPound: gpp,
      minimumSuggestedGrains: minGrains,
    ),
    formulaId: 'arrow_weight_sum',
    formulaDisplay:
        'Total = (GPI × shaft length) + point + insert + rear components',
    steps: [
      'Shaft = ${components.gpi} GPI × ${components.shaftLengthInches} in = ${components.shaftGrains.toStringAsFixed(2)} gr',
      'Front components = ${components.frontGrains.toStringAsFixed(2)} gr',
      'Rear components = ${components.rearGrains.toStringAsFixed(2)} gr',
      'Total = ${total.toStringAsFixed(2)} gr',
      if (gpp != null) 'GPP = ${total.toStringAsFixed(2)} ÷ ${drawWeightPounds!.toStringAsFixed(1)} = ${gpp.toStringAsFixed(2)}',
    ],
    assumptions: [
      'Catalog GPI and component weights may differ from a grain scale by 5–10 gr due to glue/wrap variance.',
      'Use a weighed finished arrow for FOC, KE, and momentum when possible.',
    ],
    limitations: [
      'Does not include unlisted adhesives or custom wraps unless entered.',
    ],
    safetyNotes: [
      'Never shoot below the bow manufacturer’s minimum arrow weight (often 5 gpp).',
      Citations.gppSafety.notes,
    ],
    citation: Citations.gppSafety,
    warnings: warnings,
  );
}

double calculateGpp({
  required double totalGrains,
  required double drawWeightPounds,
}) {
  requireFinitePositive('total grains', totalGrains);
  requireFinitePositive('draw weight', drawWeightPounds);
  return totalGrains / drawWeightPounds;
}

/// GPP with the same safety warnings used by [calculateArrowWeight].
CalcResult<double> calculateGppResult({
  required double totalGrains,
  required double drawWeightPounds,
  double minimumGpp = 5.0,
}) {
  final gpp = calculateGpp(
    totalGrains: totalGrains,
    drawWeightPounds: drawWeightPounds,
  );
  final warnings = <String>[];
  if (gpp < minimumGpp) {
    warnings.add(
      'Calculated GPP (${gpp.toStringAsFixed(2)}) is below the ${minimumGpp.toStringAsFixed(0)} gpp safety floor. Check your bow manual.',
    );
  }
  return CalcResult(
    value: gpp,
    formulaId: 'gpp',
    formulaDisplay: 'GPP = total arrow grains ÷ draw weight (lb)',
    steps: [
      '${totalGrains.toStringAsFixed(1)} ÷ ${drawWeightPounds.toStringAsFixed(1)} = ${gpp.toStringAsFixed(2)} gpp',
    ],
    assumptions: const [
      'Use finished-arrow weight and peak draw weight.',
    ],
    limitations: const [
      'Manufacturer minimums override this number.',
    ],
    safetyNotes: [
      'Never shoot below the bow manufacturer’s minimum arrow weight (often 5 gpp).',
    ],
    warnings: warnings,
    citation: Citations.gppSafety,
  );
}
