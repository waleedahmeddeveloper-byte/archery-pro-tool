/// Pure-Dart archery calculation engine.
///
/// All public APIs use explicit units at the edges. Internal helpers prefer
/// SI where it simplifies ballistics (meters, kilograms, seconds).
library;

export 'src/models/result.dart';
export 'src/models/units.dart';
export 'src/models/components.dart';
export 'src/formulas/arrow_weight.dart';
export 'src/formulas/foc.dart';
export 'src/formulas/energy.dart';
export 'src/formulas/speed.dart';
export 'src/formulas/draw.dart';
export 'src/formulas/spine.dart';
export 'src/formulas/ballistics.dart';
export 'src/formulas/converters.dart';
export 'src/formulas/let_off.dart';
export 'src/charts/spine_planning_chart.dart';
export 'src/references/citations.dart';
export 'src/engine.dart';
