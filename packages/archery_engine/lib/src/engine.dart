import 'formulas/arrow_weight.dart';
import 'formulas/ballistics.dart';
import 'formulas/bow_energy.dart';
import 'formulas/converters.dart';
import 'formulas/crossbow.dart';
import 'formulas/downrange.dart';
import 'formulas/draw.dart';
import 'formulas/draw_weight.dart';
import 'formulas/energy.dart';
import 'formulas/foc.dart';
import 'formulas/let_off.dart';
import 'formulas/point_foc.dart';
import 'formulas/sight_pin.dart';
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

  CalcResult<double> arrowCutLength({
    required double drawLengthInches,
    double restFrontOfRestInches = 1.0,
    bool broadheadClearance = true,
  }) =>
      suggestArrowCutLength(
        drawLengthInches: drawLengthInches,
        restFrontOfRestInches: restFrontOfRestInches,
        broadheadClearance: broadheadClearance,
      );

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

  CalcResult<LetOffResult> letOffFromHolding({
    required double peakDrawWeightPounds,
    required double holdingWeightPounds,
  }) =>
      letOffFromHoldingWeight(
        peakDrawWeightPounds: peakDrawWeightPounds,
        holdingWeightPounds: holdingWeightPounds,
      );

  CalcResult<BowEnergyResult> bowEnergy({
    required double peakDrawWeightPounds,
    required double drawLengthInches,
    required double arrowWeightGrains,
    required double arrowSpeedFps,
    double braceHeightInches = 6.5,
    double letOffPercent = 80,
  }) =>
      calculateBowEnergy(
        peakDrawWeightPounds: peakDrawWeightPounds,
        drawLengthInches: drawLengthInches,
        arrowWeightGrains: arrowWeightGrains,
        arrowSpeedFps: arrowSpeedFps,
        braceHeightInches: braceHeightInches,
        letOffPercent: letOffPercent,
      );

  CalcResult<DownrangeResult> downrange({
    required double launchSpeedFps,
    required double arrowWeightGrains,
    double dragPerSecond = 0.08,
    List<double> distancesYards = const [0, 20, 30, 40, 50, 60],
  }) =>
      calculateDownrange(
        launchSpeedFps: launchSpeedFps,
        arrowWeightGrains: arrowWeightGrains,
        dragPerSecond: dragPerSecond,
        distancesYards: distancesYards,
      );

  CalcResult<double> velocityLossAt({
    required double launchSpeedFps,
    required double distanceYards,
    double dragPerSecond = 0.08,
  }) =>
      velocityLoss(
        launchSpeedFps: launchSpeedFps,
        distanceYards: distanceYards,
        dragPerSecond: dragPerSecond,
      );

  CalcResult<SightPinGapResult> sightPinGaps({
    required double speedFps,
    required double zeroYards,
    required double peepToSightInches,
    List<double> distancesYards = const [20, 30, 40, 50, 60],
  }) =>
      calculateSightPinGaps(
        speedFps: speedFps,
        zeroYards: zeroYards,
        peepToSightInches: peepToSightInches,
        distancesYards: distancesYards,
      );

  CalcResult<CrossbowSpeedResult> crossbowSpeed({
    required double ratedSpeedFps,
    required double ratedBoltGrains,
    required double yourBoltGrains,
  }) =>
      estimateCrossbowSpeed(
        ratedSpeedFps: ratedSpeedFps,
        ratedBoltGrains: ratedBoltGrains,
        yourBoltGrains: yourBoltGrains,
      );

  CalcResult<String> crossbowBoltGuide({
    required double ratedSpeedFps,
    required double drawWeightPounds,
  }) =>
      crossbowBoltSelectionGuide(
        ratedSpeedFps: ratedSpeedFps,
        drawWeightPounds: drawWeightPounds,
      );

  CalcResult<double> pointWeightForFoc({
    required double arrowLengthInches,
    required double currentTotalGrains,
    required double currentFocPercent,
    required double targetFocPercent,
  }) =>
      pointWeightForTargetFoc(
        arrowLengthInches: arrowLengthInches,
        currentTotalGrains: currentTotalGrains,
        currentFocPercent: currentFocPercent,
        targetFocPercent: targetFocPercent,
      );

  CalcResult<DrawWeightGuideResult> drawWeightGuide({
    required GameClass game,
    required double drawLengthInches,
  }) =>
      suggestDrawWeight(game: game, drawLengthInches: drawLengthInches);

  CalcResult<double> grainsPerPound({
    required double totalGrains,
    required double drawWeightPounds,
  }) =>
      calculateGppResult(
        totalGrains: totalGrains,
        drawWeightPounds: drawWeightPounds,
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
