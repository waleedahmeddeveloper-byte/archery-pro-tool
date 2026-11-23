import '../models/result.dart';
import '../models/units.dart';
import '../references/citations.dart';

double convertWeight(double value, WeightUnit from, WeightUnit to) {
  requireFiniteNonNegative('weight', value);
  final grains = switch (from) {
    WeightUnit.grains => value,
    WeightUnit.grams => value / Units.gramsPerGrain,
    WeightUnit.ounces => value * 437.5,
    WeightUnit.pounds => value * Units.grainsPerPound,
  };
  return switch (to) {
    WeightUnit.grains => grains,
    WeightUnit.grams => grains * Units.gramsPerGrain,
    WeightUnit.ounces => grains / 437.5,
    WeightUnit.pounds => grains / Units.grainsPerPound,
  };
}

double convertLength(double value, LengthUnit from, LengthUnit to) {
  requireFiniteNonNegative('length', value);
  final meters = switch (from) {
    LengthUnit.meters => value,
    LengthUnit.inches => Units.inchesToMeters(value),
    LengthUnit.feet => Units.inchesToMeters(value * 12),
    LengthUnit.yards => Units.yardsToMeters(value),
    LengthUnit.millimeters => value / 1000.0,
    LengthUnit.centimeters => value / 100.0,
  };
  return switch (to) {
    LengthUnit.meters => meters,
    LengthUnit.inches => Units.metersToInches(meters),
    LengthUnit.feet => Units.metersToInches(meters) / 12.0,
    LengthUnit.yards => Units.metersToYards(meters),
    LengthUnit.millimeters => meters * 1000.0,
    LengthUnit.centimeters => meters * 100.0,
  };
}

double convertSpeed(double value, SpeedUnit from, SpeedUnit to) {
  requireFiniteNonNegative('speed', value);
  final ms = switch (from) {
    SpeedUnit.metersPerSecond => value,
    SpeedUnit.fps => Units.fpsToMs(value),
    SpeedUnit.mph => value * 0.44704,
  };
  return switch (to) {
    SpeedUnit.metersPerSecond => ms,
    SpeedUnit.fps => Units.msToFps(ms),
    SpeedUnit.mph => ms / 0.44704,
  };
}

double convertEnergy(double value, EnergyUnit from, EnergyUnit to) {
  requireFiniteNonNegative('energy', value);
  final joules = switch (from) {
    EnergyUnit.joules => value,
    EnergyUnit.footPounds => Units.ftLbToJoules(value),
  };
  return switch (to) {
    EnergyUnit.joules => joules,
    EnergyUnit.footPounds => Units.joulesToFtLb(joules),
  };
}

CalcResult<double> convertWithTrace({
  required double value,
  required String label,
  required double Function() convert,
}) {
  final out = convert();
  return CalcResult(
    value: out,
    formulaId: 'unit_convert',
    formulaDisplay: 'Dimensional unit conversion',
    steps: ['$label: $value → ${out.toStringAsFixed(6)}'],
    assumptions: const [],
    limitations: const [],
    safetyNotes: const [],
    citation: Citations.keFtLb,
  );
}
