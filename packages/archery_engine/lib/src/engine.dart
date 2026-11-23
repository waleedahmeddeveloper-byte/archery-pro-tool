import 'formulas/arrow_weight.dart';
import 'formulas/ballistics.dart';
import 'formulas/converters.dart';
import 'formulas/draw.dart';
import 'formulas/energy.dart';
import 'formulas/foc.dart';
import 'formulas/let_off.dart';
import 'formulas/speed.dart';
import 'formulas/spine.dart';
import 'models/components.dart';
import 'models/result.dart';
import 'models/units.dart';

/// Facade used by the Flutter app and Setup Assistant.
class ArcheryEngine {
  const ArcheryEngine();

  CalcResult<ArrowWeightResult> arrowWeight({
    required ArrowComponents components,
    double? drawWeightPounds,
  }) =>
      calculateArrowWeight(
        components: components,
        drawWeightPounds: drawWeightPounds,
      );

  CalcResult<FocResult> focMeasured({
    required double arrowLengthInches,
    required double balancePointFromNockInches,
  }) =>
      calculateFocMeasured(
        arrowLengthInches: arrowLengthInches,
        balancePointFromNockInches: balancePointFromNockInches,
      );

  CalcResult<FocResult> focFromComponents({
    required ArrowComponents components,
  }) =>
      calculateFocFromComponents(components: components);

  CalcResult<EnergyMomentumResult> energyMomentum({
    required double arrowWeightGrains,
    required double speedFps,
  }) =>
      calculateEnergyAndMomentum(
        arrowWeightGrains: arrowWeightGrains,
        speedFps: speedFps,
      );

  CalcResult<SpeedEstimateResult> speedFromMassChange({
    required double referenceSpeedFps,
    required double referenceWeightGrains,
    required double newWeightGrains,
    double efficiencyPercent = 100,
  }) =>
      estimateSpeedFromMassChange(
        referenceSpeedFps: referenceSpeedFps,
        referenceWeightGrains: referenceWeightGrains,
        newWeightGrains: newWeightGrains,
        efficiencyPercent: efficiencyPercent,
      );

  CalcResult<IboSpeedResult> speedFromIbo({
    required double iboFps,
    required double drawWeightPounds,
    required double drawLengthInches,
    required double arrowWeightGrains,
    double stringAccessoryGrains = 0,
  }) =>
      estimateSpeedFromIbo(
        iboFps: iboFps,
        drawWeightPounds: drawWeightPounds,
        drawLengthInches: drawLengthInches,
        arrowWeightGrains: arrowWeightGrains,
        stringAccessoryGrains: stringAccessoryGrains,
      );

  CalcResult<double> drawLengthFromWingspan(double wingspanInches) =>
      estimateDrawLengthFromWingspan(wingspanInches: wingspanInches);

  CalcResult<SpineSelectionResult> spine({
    required BowType bowType,
    required double drawWeightPounds,
    required double arrowLengthInches,
    required double pointWeightGrains,
    CamStyle camStyle = CamStyle.standard,
  }) =>
      selectSpine(
        bowType: bowType,
        drawWeightPounds: drawWeightPounds,
        arrowLengthInches: arrowLengthInches,
        pointWeightGrains: pointWeightGrains,
        camStyle: camStyle,
      );

  CalcResult<TrajectoryResult> trajectoryGravity({
    required double speedFps,
    required double zeroYards,
    List<double> distancesYards = const [10, 20, 30, 40, 50, 60],
    double sightHeightInches = 3.5,
  }) =>
      calculateGravityTrajectory(
        speedFps: speedFps,
        zeroYards: zeroYards,
        distancesYards: distancesYards,
        sightHeightInches: sightHeightInches,
      );

  CalcResult<TrajectoryResult> trajectoryWithDrag({
    required double speedFps,
    required double zeroYards,
    double dragPerSecond = 0.08,
    List<double> distancesYards = const [10, 20, 30, 40, 50, 60],
  }) =>
      calculateDragAwareTrajectory(
        speedFps: speedFps,
        zeroYards: zeroYards,
        dragPerSecond: dragPerSecond,
        distancesYards: distancesYards,
      );

  CalcResult<double> shotAngleDistance({
    required double lineOfSightYards,
    required double angleDegrees,
  }) =>
      trueHorizontalDistance(
        lineOfSightYards: lineOfSightYards,
        angleDegrees: angleDegrees,
      );

  CalcResult<LetOffResult> letOffHolding({
    required double peakDrawWeightPounds,
    required double letOffPercent,
  }) =>
      holdingWeightFromLetOff(
        peakDrawWeightPounds: peakDrawWeightPounds,
        letOffPercent: letOffPercent,
      );

  double convertWeightValue(double value, WeightUnit from, WeightUnit to) =>
      convertWeight(value, from, to);

  double convertLengthValue(double value, LengthUnit from, LengthUnit to) =>
      convertLength(value, from, to);

  double convertSpeedValue(double value, SpeedUnit from, SpeedUnit to) =>
      convertSpeed(value, from, to);

  double convertEnergyValue(double value, EnergyUnit from, EnergyUnit to) =>
      convertEnergy(value, from, to);
}
