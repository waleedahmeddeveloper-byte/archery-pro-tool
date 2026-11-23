import '../models/result.dart';
import '../references/citations.dart';

enum GameClass { smallGame, turkey, deer, hog, blackBear, elk }

class DrawWeightGuideResult {
  const DrawWeightGuideResult({
    required this.suggestedMinPounds,
    required this.suggestedComfortPounds,
    required this.notes,
  });

  final double suggestedMinPounds;
  final double suggestedComfortPounds;
  final String notes;
}

/// Planning guidance only — not legal advice. Confirm state regulations.
CalcResult<DrawWeightGuideResult> suggestDrawWeight({
  required GameClass game,
  required double drawLengthInches,
}) {
  requireFinitePositive('draw length', drawLengthInches);

  final (minW, comfort, note) = switch (game) {
    GameClass.smallGame => (
        25.0,
        35.0,
        'Small-game setups prioritize control; still meet any local minimums.'
      ),
    GameClass.turkey => (
        40.0,
        50.0,
        'Turkey setups often need precise shot placement more than peak KE.'
      ),
    GameClass.deer => (
        40.0,
        55.0,
        'Common deer hunting window; verify state minimum draw weight.'
      ),
    GameClass.hog => (
        45.0,
        60.0,
        'Hogs can be tough — pair weight with stout broadheads and FOC.'
      ),
    GameClass.blackBear => (
        50.0,
        65.0,
        'Bear setups usually want heavier arrows and careful shot selection.'
      ),
    GameClass.elk => (
        50.0,
        70.0,
        'Elk-oriented builds often run heavier GPP and higher FOC; confirm laws.'
      ),
  };

  // Short draw lengths reduce stored energy — nudge comfort up slightly.
  final comfortAdj =
      drawLengthInches < 27 ? comfort + 5 : comfort;

  return CalcResult(
    value: DrawWeightGuideResult(
      suggestedMinPounds: minW,
      suggestedComfortPounds: comfortAdj,
      notes: note,
    ),
    formulaId: 'draw_weight_guide',
    formulaDisplay: 'Heuristic comfort bands by game class (not a physics formula)',
    steps: [
      'Game: ${game.name}',
      'Suggested minimum planning floor ≈ ${minW.toStringAsFixed(0)} lb',
      'Comfort planning window ≈ ${comfortAdj.toStringAsFixed(0)} lb',
      note,
    ],
    assumptions: [
      'Fitness, form, and local regulations override these bands.',
    ],
    limitations: [
      'Not legal advice. State charts change — verify before hunting.',
    ],
    safetyNotes: [
      'Never force a draw weight you cannot hold and shoot accurately.',
    ],
    citation: Citations.iboEnergyScale,
  );
}
