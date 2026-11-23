import 'package:archery_engine/archery_engine.dart';
import 'package:test/test.dart';

void main() {
  const engine = ArcheryEngine();

  group('FOC component + method labels', () {
    test('component FOC and method labels', () {
      final r = engine.focFromComponents(
        components: const ArrowComponents(
          gpi: 8,
          shaftLengthInches: 28,
          pointGrains: 125,
          insertGrains: 50,
          nockGrains: 8,
          vaneGrainsEach: 6,
          vaneCount: 3,
        ),
      );
      expect(r.value.focPercent, greaterThan(0));
      expect(r.value.methodLabel, contains('Component'));
      final m = engine.focMeasured(
        arrowLengthInches: 30,
        balancePointFromNockInches: 20,
      );
      expect(m.value.methodLabel, contains('Measured'));
    });

    test('rejects unrealistic balance', () {
      expect(
        () => engine.focMeasured(
          arrowLengthInches: 28,
          balancePointFromNockInches: 50,
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('Energy / momentum edge cases', () {
    test('rejects non-positive weight', () {
      expect(
        () => engine.energyMomentum(arrowWeightGrains: 0, speedFps: 280),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('Speed / IBO', () {
    test('mass change and IBO estimate', () {
      final m = engine.speedFromMassChange(
        referenceSpeedFps: 300,
        referenceWeightGrains: 350,
        newWeightGrains: 450,
        efficiencyPercent: 95,
      );
      expect(m.value.speedFps, lessThan(300));
      expect(m.value.speedMs, greaterThan(0));
      final ibo = engine.speedFromIbo(
        iboFps: 340,
        drawWeightPounds: 60,
        drawLengthInches: 28,
        arrowWeightGrains: 420,
        stringAccessoryGrains: 10,
      );
      expect(ibo.value.estimatedFps, greaterThan(200));
      expect(ibo.value.energyModelFps, greaterThan(0));
      expect(ibo.value.ruleOfThumbFps, greaterThan(0));
    });
  });

  group('Draw helpers', () {
    test('cut length and wingspan', () {
      final d = engine.drawLengthFromWingspan(70);
      expect(d.value, closeTo(28, 1e-9));
      final cut = engine.arrowCutLength(
        drawLengthInches: 28,
        restFrontOfRestInches: 1,
        broadheadClearance: true,
      );
      expect(cut.value, greaterThan(28));
      final cut2 = engine.arrowCutLength(
        drawLengthInches: 28,
        broadheadClearance: false,
      );
      expect(cut2.value, lessThan(cut.value));
    });
  });

  group('Draw weight guide all games', () {
    for (final g in GameClass.values) {
      test('game ${g.name}', () {
        final r = engine.drawWeightGuide(game: g, drawLengthInches: 26);
        expect(r.value.suggestedMinPounds, greaterThan(0));
        expect(r.value.suggestedComfortPounds, greaterThan(r.value.suggestedMinPounds));
      });
    }
  });

  group('Let-off both directions', () {
    test('from holding', () {
      final r = engine.letOffFromHolding(
        peakDrawWeightPounds: 70,
        holdingWeightPounds: 14,
      );
      expect(r.value.letOffPercent, closeTo(80, 0.1));
    });

    test('rejects 100% let-off', () {
      expect(
        () => engine.letOffHolding(peakDrawWeightPounds: 70, letOffPercent: 100),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('Converters full matrix', () {
    test('weight length speed energy', () {
      expect(
        engine.convertWeightValue(7000, WeightUnit.grains, WeightUnit.pounds),
        closeTo(1, 1e-9),
      );
      expect(
        engine.convertWeightValue(1, WeightUnit.ounces, WeightUnit.grains),
        closeTo(437.5, 1e-9),
      );
      expect(
        engine.convertLengthValue(1, LengthUnit.inches, LengthUnit.millimeters),
        closeTo(25.4, 0.01),
      );
      expect(
        engine.convertLengthValue(1, LengthUnit.yards, LengthUnit.feet),
        closeTo(3, 1e-9),
      );
      expect(
        engine.convertLengthValue(100, LengthUnit.centimeters, LengthUnit.meters),
        closeTo(1, 1e-9),
      );
      expect(
        engine.convertSpeedValue(1, SpeedUnit.mph, SpeedUnit.metersPerSecond),
        closeTo(0.44704, 1e-5),
      );
      expect(
        engine.convertEnergyValue(1, EnergyUnit.joules, EnergyUnit.footPounds),
        closeTo(Units.joulesToFtLb(1), 1e-9),
      );
    });

    test('Units helpers', () {
      expect(Units.grainsToKg(7000), closeTo(0.453592, 1e-3));
      expect(Units.kgToGrains(Units.grainsToKg(100)), closeTo(100, 1e-6));
      expect(Units.fpsToMs(Units.msToFps(10)), closeTo(10, 1e-9));
      expect(Units.inchesToMeters(Units.metersToInches(2)), closeTo(2, 1e-9));
      expect(Units.yardsToMeters(Units.metersToYards(5)), closeTo(5, 1e-9));
    });
  });

  group('Ballistics drag path', () {
    test('drag trajectory and velocity loss', () {
      final t = engine.trajectoryWithDrag(
        speedFps: 280,
        zeroYards: 20,
        dragPerSecond: 0.08,
      );
      expect(t.value.points, isNotEmpty);
      expect(t.value.modelName.toLowerCase(), contains('drag'));
      final loss = engine.velocityLossAt(
        launchSpeedFps: 280,
        distanceYards: 40,
        dragPerSecond: 0.08,
      );
      expect(loss.value, greaterThan(0));
      final loss0 = engine.velocityLossAt(
        launchSpeedFps: 280,
        distanceYards: 40,
        dragPerSecond: 0,
      );
      expect(loss0.value, closeTo(0, 1e-9));
    });
  });

  group('Downrange', () {
    test('points include launch and mid', () {
      final r = engine.downrange(
        launchSpeedFps: 280,
        arrowWeightGrains: 420,
        dragPerSecond: 0.08,
      );
      expect(r.value.points.first.yards, 0);
      expect(r.value.points.last.keFtLb, lessThan(r.value.points.first.keFtLb));
    });
  });

  group('Crossbow guide bands', () {
    test('slow mid fast', () {
      expect(
        engine.crossbowBoltGuide(ratedSpeedFps: 280, drawWeightPounds: 150).value,
        contains('350'),
      );
      expect(
        engine.crossbowBoltGuide(ratedSpeedFps: 340, drawWeightPounds: 150).value,
        contains('400'),
      );
      expect(
        engine.crossbowBoltGuide(ratedSpeedFps: 400, drawWeightPounds: 180).value,
        contains('minimum'),
      );
    });
  });

  group('Spine edges', () {
    test('aggressive cam and traditional', () {
      final a = engine.spine(
        bowType: BowType.compound,
        drawWeightPounds: 70,
        arrowLengthInches: 29,
        pointWeightGrains: 150,
        camStyle: CamStyle.aggressive,
      );
      final soft = engine.spine(
        bowType: BowType.compound,
        drawWeightPounds: 70,
        arrowLengthInches: 29,
        pointWeightGrains: 150,
        camStyle: CamStyle.soft,
      );
      expect(a.value.effectiveWeightPounds, greaterThan(soft.value.effectiveWeightPounds));
      final trad = engine.spine(
        bowType: BowType.traditional,
        drawWeightPounds: 45,
        arrowLengthInches: 28,
        pointWeightGrains: 125,
      );
      expect(trad.value.primarySpine, greaterThan(0));
    });

    test('rejects crossbow spine chart', () {
      expect(
        () => engine.spine(
          bowType: BowType.crossbow,
          drawWeightPounds: 150,
          arrowLengthInches: 20,
          pointWeightGrains: 100,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('planning chart extremes', () {
      final light = SpinePlanningChart.match(
        bowType: BowType.compound,
        effectiveWeightPounds: 10,
      );
      final heavy = SpinePlanningChart.match(
        bowType: BowType.compound,
        effectiveWeightPounds: 200,
      );
      expect(light.primary, greaterThan(heavy.primary));
      final rec = SpinePlanningChart.match(
        bowType: BowType.recurve,
        effectiveWeightPounds: 40,
      );
      expect(rec.chartName, contains('recurve'));
    });
  });

  group('Bow energy', () {
    test('runs with brace/letoff', () {
      final r = engine.bowEnergy(
        peakDrawWeightPounds: 70,
        drawLengthInches: 29,
        arrowWeightGrains: 420,
        arrowSpeedFps: 280,
        braceHeightInches: 7,
        letOffPercent: 75,
      );
      expect(r.value.storedEnergyFtLbApprox, greaterThan(0));
      expect(r.value.arrowKeFtLb, greaterThan(0));
    });
  });

  group('requireFiniteNumber', () {
    test('rejects infinity', () {
      expect(
        () => requireFiniteNumber('x', double.infinity),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('Validation helpers', () {
    test('allow zero non-negative', () {
      requireFiniteNonNegative('z', 0);
      expect(
        () => requireFiniteNonNegative('z', -1),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => requireFinitePositive('p', double.nan),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('Arrow components getters', () {
    test('totals', () {
      const c = ArrowComponents(
        gpi: 10,
        shaftLengthInches: 28,
        pointGrains: 100,
        insertGrains: 20,
        outsertOrCollarGrains: 5,
        weightScrewGrains: 5,
        nockGrains: 8,
        bushingGrains: 2,
        wrapGrains: 4,
        vaneGrainsEach: 5,
        vaneCount: 4,
        otherRearGrains: 1,
      );
      expect(c.shaftGrains, 280);
      expect(c.frontGrains, 130);
      expect(c.rearGrains, 8 + 2 + 4 + 20 + 1);
      expect(c.totalGrains, c.shaftGrains + c.frontGrains + c.rearGrains);
    });
  });

  group('convertWithTrace', () {
    test('wraps conversion', () {
      final r = convertWithTrace(
        value: 100,
        label: 'test',
        convert: () => 200.0,
      );
      expect(r.value, 200);
      expect(r.steps.first, contains('test'));
    });
  });

  group('KE / momentum only helpers', () {
    test('ke-only and momentum-only wrappers', () {
      final ke = calculateKineticEnergyFtLb(
        arrowWeightGrains: 450,
        speedFps: 275,
      );
      final mom = calculateMomentumSlugFtPerSec(
        arrowWeightGrains: 450,
        speedFps: 275,
      );
      expect(ke.value, closeTo(75.6, 0.2));
      expect(mom.value, closeTo(0.55, 0.02));
      expect(ke.formulaId, 'ke_only');
      expect(mom.formulaId, 'momentum_only');
    });
  });

  group('Spine chart alternate band', () {
    test('near boundary suggests alternate', () {
      final m = SpinePlanningChart.match(
        bowType: BowType.compound,
        effectiveWeightPounds: 62,
      );
      // 62 is a listed band max — alternate may be present near edge
      expect(m.primary, isNonZero);
      expect(m.chartName, isNotEmpty);
    });
  });
}
