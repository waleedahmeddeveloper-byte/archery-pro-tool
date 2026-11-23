import '../models/result.dart';
import '../references/citations.dart';

CalcResult<double> estimateDrawLengthFromWingspan({
  required double wingspanInches,
}) {
  requireFinitePositive('wingspan', wingspanInches);
  final dl = wingspanInches / 2.5;
  return CalcResult(
    value: dl,
    formulaId: 'draw_length_wingspan',
    formulaDisplay: 'Draw length ≈ wingspan ÷ 2.5',
    steps: [
      'Wingspan = ${wingspanInches.toStringAsFixed(2)} in',
      'Estimate = ${wingspanInches.toStringAsFixed(2)} ÷ 2.5 = ${dl.toStringAsFixed(2)} in',
    ],
    assumptions: [
      'Fingertip-to-fingertip wingspan with arms outstretched.',
    ],
    limitations: [
      'Fitting estimate only — confirm at full draw.',
      'ATA draw length = distance to grip pivot + 1.75 in.',
    ],
    safetyNotes: [
      'Incorrect draw length can overstress shoulders and mistune spine.',
    ],
    citation: Citations.drawLengthWingspan,
  );
}

/// Simple arrow cut-length suggestion from draw length.
CalcResult<double> suggestArrowCutLength({
  required double drawLengthInches,
  double restFrontOfRestInches = 1.0,
  bool broadheadClearance = true,
}) {
  requireFinitePositive('draw length', drawLengthInches);
  var cut = drawLengthInches + restFrontOfRestInches;
  if (broadheadClearance) cut += 0.5;
  return CalcResult(
    value: cut,
    formulaId: 'arrow_cut_length',
    formulaDisplay:
        'Cut length ≈ draw length + rest overhang (+ broadhead clearance)',
    steps: [
      'Base = draw ${drawLengthInches.toStringAsFixed(2)} + overhang ${restFrontOfRestInches.toStringAsFixed(2)}',
      if (broadheadClearance) 'Added 0.5 in broadhead clearance',
      'Suggested cut ≈ ${cut.toStringAsFixed(2)} in',
    ],
    assumptions: [
      'Compound with arrow rest ahead of the berger hole; adjust for your rest.',
    ],
    limitations: [
      'Manufacturer and rest geometry vary — dry-fit before cutting.',
    ],
    safetyNotes: [
      'Never cut so short that a broadhead contacts the riser at full draw.',
    ],
    citation: Citations.drawLengthWingspan,
  );
}
