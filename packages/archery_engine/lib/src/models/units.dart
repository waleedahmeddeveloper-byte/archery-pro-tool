/// Unit conversion helpers. Prefer converting to SI at API edges for ballistics.
class Units {
  Units._();

  static const grainsPerPound = 7000.0;
  static const gramsPerGrain = 0.06479891;
  static const gravityFtPerSec2 = 32.174;
  /// Common archery KE divisor using g ≈ 32.16 (see Citations.keFtLb).
  static const keDivisor = 450240.0;
  /// Momentum divisor: 7000 × 32.174.
  static const momentumDivisor = 225218.0;
  static const feetPerMeter = 3.280839895;
  static const inchesPerMeter = 39.37007874;
  static const yardsPerMeter = 1.093613298;
  static const ftLbPerJoule = 0.737562149;
  static const slugFtPerSecToKgMPerSec = 4.448221615;

  static double grainsToKg(double grains) =>
      grains * gramsPerGrain / 1000.0;

  static double kgToGrains(double kg) =>
      kg * 1000.0 / gramsPerGrain;

  static double fpsToMs(double fps) => fps / feetPerMeter;

  static double msToFps(double ms) => ms * feetPerMeter;

  static double inchesToMeters(double inches) => inches / inchesPerMeter;

  static double metersToInches(double meters) => meters * inchesPerMeter;

  static double yardsToMeters(double yards) => yards / yardsPerMeter;

  static double metersToYards(double meters) => meters * yardsPerMeter;

  static double ftLbToJoules(double ftLb) => ftLb / ftLbPerJoule;

  static double joulesToFtLb(double joules) => joules * ftLbPerJoule;
}

enum WeightUnit { grains, grams, ounces, pounds }

enum LengthUnit { inches, feet, millimeters, centimeters, meters, yards }

enum SpeedUnit { fps, mph, metersPerSecond }

enum EnergyUnit { footPounds, joules }

enum AngleUnit { degrees, radians }
