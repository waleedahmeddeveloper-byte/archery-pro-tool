import 'package:archery_engine/archery_engine.dart';
import 'package:test/test.dart';

void main() {
  const engine = ArcheryEngine();

  group('FOC measured (Easton/AMO worked pattern)', () {
    test('A=20 L=30 => 16.666...', () {
      final r = engine.focMeasured(
        arrowLengthInches: 30,
        balancePointFromNockInches: 20,
      );
      expect(r.value.focPercent, closeTo(16.6667, 0.001));
      expect(r.value.method, FocMethod.measuredBalancePoint);
      expect(r.citation.id, 'foc_amo');
    });

    test('rejects non-positive length', () {
      expect(
        () => engine.focMeasured(
          arrowLengthInches: 0,
          balancePointFromNockInches: 10,
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('Kinetic energy & momentum', () {
    test('450 gr @ 275 fps ≈ 75.6 ft-lb and 0.55 slug·ft/s', () {
      final r = engine.energyMomentum(
        arrowWeightGrains: 450,
        speedFps: 275,
      );
      expect(r.value.keFtLb, closeTo(75.58, 0.05));
      expect(r.value.momentumSlugFtPerSec, closeTo(0.549, 0.002));
    });

    test('400 gr @ 290 fps ≈ 74.72 ft-lb (published example band)', () {
      final r = engine.energyMomentum(
        arrowWeightGrains: 400,
        speedFps: 290,
      );
      expect(r.value.keFtLb, closeTo(74.72, 0.05));
    });
  });

  group('Arrow weight & GPP', () {
    test('GPI×length + components', () {
      final r = engine.arrowWeight(
        components: const ArrowComponents(
          gpi: 8.2,
          shaftLengthInches: 28,
          pointGrains: 125,
          insertGrains: 25,
          nockGrains: 8,
          vaneGrainsEach: 7,
          vaneCount: 3,
        ),
        drawWeightPounds: 60,
      );
      expect(r.value.totalGrains, closeTo(408.6, 0.05));
      expect(r.value.grainsPerPound, closeTo(6.81, 0.02));
      expect(r.warnings, isEmpty);
    });

    test('warns below 5 gpp', () {
      final r = engine.arrowWeight(
        components: const ArrowComponents(
          gpi: 7,
          shaftLengthInches: 28,
          pointGrains: 100,
        ),
        drawWeightPounds: 70,
      );
      expect(r.warnings, isNotEmpty);
    });
  });

  group('Speed scaling', () {
    test('300 fps 350->450 @95% ≈ 251.3', () {
      final r = engine.speedFromMassChange(
        referenceSpeedFps: 300,
        referenceWeightGrains: 350,
        newWeightGrains: 450,
        efficiencyPercent: 95,
      );
      expect(r.value.speedFps, closeTo(251.3, 0.5));
    });
  });

  group('Draw length', () {
    test('wingspan 70 => 28', () {
      final r = engine.drawLengthFromWingspan(70);
      expect(r.value, closeTo(28.0, 0.001));
    });
  });

  group('Spine heuristic examples', () {
    test('55 lb compound 28 in 125 gr → ~400 or 340 band', () {
      final r = engine.spine(
        bowType: BowType.compound,
        drawWeightPounds: 55,
        arrowLengthInches: 28,
        pointWeightGrains: 125,
      );
      expect(r.value.effectiveWeightPounds, closeTo(58, 0.1));
      expect([300, 340, 400], contains(r.value.primarySpine));
    });

    test('recurve 30 lb 28 in 100 gr → weak spine class', () {
      final r = engine.spine(
        bowType: BowType.recurve,
        drawWeightPounds: 30,
        arrowLengthInches: 28,
        pointWeightGrains: 100,
      );
      expect(r.value.primarySpine, greaterThanOrEqualTo(700));
    });
  });

  group('Trajectory', () {
    test('zero distance has near-zero LOS drop', () {
      final r = engine.trajectoryGravity(
        speedFps: 280,
        zeroYards: 20,
        distancesYards: const [20],
      );
      expect(r.value.points.single.dropInchesFromLineOfSight.abs(), lessThan(0.2));
    });

    test('40 yd drops more than 30 yd', () {
      final r = engine.trajectoryGravity(
        speedFps: 280,
        zeroYards: 20,
        distancesYards: const [30, 40],
      );
      expect(
        r.value.points[1].dropInchesFromLineOfSight,
        greaterThan(r.value.points[0].dropInchesFromLineOfSight),
      );
    });
  });

  group('Unit round-trips', () {
    test('grains ↔ grams', () {
      final g = engine.convertWeightValue(100, WeightUnit.grains, WeightUnit.grams);
      final back = engine.convertWeightValue(g, WeightUnit.grams, WeightUnit.grains);
      expect(back, closeTo(100, 1e-9));
    });

    test('fps ↔ m/s', () {
      final ms = engine.convertSpeedValue(280, SpeedUnit.fps, SpeedUnit.metersPerSecond);
      final back = engine.convertSpeedValue(ms, SpeedUnit.metersPerSecond, SpeedUnit.fps);
      expect(back, closeTo(280, 1e-9));
    });

    test('ft-lb ↔ J', () {
      final j = engine.convertEnergyValue(75.6, EnergyUnit.footPounds, EnergyUnit.joules);
      final back = engine.convertEnergyValue(j, EnergyUnit.joules, EnergyUnit.footPounds);
      expect(back, closeTo(75.6, 1e-9));
    });
  });

  group('Let-off', () {
    test('70 lb @ 80% let-off => 14 lb holding', () {
      final r = engine.letOffHolding(
        peakDrawWeightPounds: 70,
        letOffPercent: 80,
      );
      expect(r.value.holdingWeightPounds, closeTo(14, 0.01));
    });
  });

  group('Shot angle', () {
    test('40 yd LOS at 30° => ~34.6 yd horizontal', () {
      final r = engine.shotAngleDistance(
        lineOfSightYards: 40,
        angleDegrees: 30,
      );
      expect(r.value, closeTo(34.64, 0.05));
    });
  });

  group('Crossbow & bow energy', () {
    test('crossbow speed scales with sqrt mass', () {
      final r = engine.crossbowSpeed(
        ratedSpeedFps: 400,
        ratedBoltGrains: 400,
        yourBoltGrains: 450,
      );
      expect(r.value.estimatedFps, lessThan(400));
      expect(r.value.estimatedFps, greaterThan(370));
    });

    test('bow energy efficiency positive', () {
      final r = engine.bowEnergy(
        peakDrawWeightPounds: 70,
        drawLengthInches: 29,
        arrowWeightGrains: 420,
        arrowSpeedFps: 280,
      );
      expect(r.value.efficiencyPercent, greaterThan(50));
      expect(r.value.efficiencyPercent, lessThan(120));
    });
  });

  group('Sight pin & point FOC', () {
    test('pin gaps increase at longer distances', () {
      final r = engine.sightPinGaps(
        speedFps: 280,
        zeroYards: 20,
        peepToSightInches: 28,
      );
      expect(r.value.gapsInches.length, greaterThan(2));
      expect(
        r.value.gapsInches.last.gapInches,
        greaterThan(r.value.gapsInches.first.gapInches),
      );
    });

    test('point weight for higher FOC is positive', () {
      final r = engine.pointWeightForFoc(
        arrowLengthInches: 29,
        currentTotalGrains: 420,
        currentFocPercent: 10,
        targetFocPercent: 14,
      );
      expect(r.value, greaterThan(0));
    });
  });
}
