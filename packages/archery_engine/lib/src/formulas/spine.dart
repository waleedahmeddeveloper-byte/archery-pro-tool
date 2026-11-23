import '../charts/spine_planning_chart.dart';
import '../models/components.dart';
import '../models/result.dart';
import '../references/citations.dart';

class SpineSelectionResult {
  const SpineSelectionResult({
    required this.effectiveWeightPounds,
    required this.primarySpine,
    required this.alternateSpine,
    required this.chartName,
    required this.bowType,
  });

  final double effectiveWeightPounds;
  final int primarySpine;
  final int? alternateSpine;
  final String chartName;
  final BowType bowType;
}

CalcResult<SpineSelectionResult> selectSpine({
  required BowType bowType,
  required double drawWeightPounds,
  required double arrowLengthInches,
  required double pointWeightGrains,
  CamStyle camStyle = CamStyle.standard,
}) {
  requireFinitePositive('draw weight', drawWeightPounds);
  requireFinitePositive('arrow length', arrowLengthInches);
  requireFinitePositive('point weight', pointWeightGrains);
  if (bowType == BowType.crossbow) {
    throw ValidationException(
      'Use bolt-selection guidance for crossbows; compound/recurve spine charts do not apply directly.',
    );
  }

  var effective = drawWeightPounds;
  final lengthAdj = (arrowLengthInches - 28.0) * 4.0;
  final pointAdj = ((pointWeightGrains - 100.0) / 25.0) * 3.0;
  effective += lengthAdj + pointAdj;

  if (bowType == BowType.compound) {
    effective += switch (camStyle) {
      CamStyle.aggressive => 5.0,
      CamStyle.soft => -3.0,
      CamStyle.standard => 0.0,
    };
  }

  final match = SpinePlanningChart.match(
    bowType: bowType,
    effectiveWeightPounds: effective,
  );

  return CalcResult(
    value: SpineSelectionResult(
      effectiveWeightPounds: effective,
      primarySpine: match.primary,
      alternateSpine: match.alternate,
      chartName: match.chartName,
      bowType: bowType,
    ),
    formulaId: 'spine_effective_weight',
    formulaDisplay:
        'Effective wt = DW + 4×(L−28) + 3×((point−100)/25) + cam adj',
    steps: [
      'Draw weight = ${drawWeightPounds.toStringAsFixed(1)} lb',
      'Length adjustment = 4 × (${arrowLengthInches.toStringAsFixed(2)} − 28) = ${lengthAdj.toStringAsFixed(1)} lb',
      'Point adjustment = 3 × ((${pointWeightGrains.toStringAsFixed(0)} − 100) / 25) = ${pointAdj.toStringAsFixed(1)} lb',
      if (bowType == BowType.compound)
        'Cam adjustment (${camStyle.name}) applied',
      'Effective weight = ${effective.toStringAsFixed(1)} lb',
      'Chart: ${match.chartName} → spine ${match.primary}${match.alternate == null ? '' : ' (also try ${match.alternate})'}',
    ],
    assumptions: [
      'Uses Arcus planning chart bands, not a reproduced manufacturer chart.',
      'Static spine number is deflection ×1000 under AMO test conditions.',
    ],
    limitations: [
      'Two shafts stamped the same spine are not identical across brands.',
      'Dynamic spine also depends on string, rest, release, and centershot.',
    ],
    safetyNotes: [
      'Verify on the current Easton, Gold Tip, Victory, Black Eagle, or Carbon Express chart for your exact model before buying or cutting.',
      'Bare-shaft and paper tune before hunting.',
    ],
    citation: Citations.spineHeuristic,
    metadata: {
      'chart': match.chartName,
      'primarySpine': match.primary,
      'alternateSpine': match.alternate,
    },
  );
}
