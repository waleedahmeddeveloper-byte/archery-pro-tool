/// Finished-arrow component breakdown in grains.
class ArrowComponents {
  const ArrowComponents({
    required this.gpi,
    required this.shaftLengthInches,
    this.pointGrains = 0,
    this.insertGrains = 0,
    this.outsertOrCollarGrains = 0,
    this.weightScrewGrains = 0,
    this.nockGrains = 0,
    this.bushingGrains = 0,
    this.wrapGrains = 0,
    this.vaneGrainsEach = 0,
    this.vaneCount = 0,
    this.otherRearGrains = 0,
  });

  final double gpi;
  final double shaftLengthInches;
  final double pointGrains;
  final double insertGrains;
  final double outsertOrCollarGrains;
  final double weightScrewGrains;
  final double nockGrains;
  final double bushingGrains;
  final double wrapGrains;
  final double vaneGrainsEach;
  final int vaneCount;
  final double otherRearGrains;

  double get shaftGrains => gpi * shaftLengthInches;

  double get frontGrains =>
      pointGrains + insertGrains + outsertOrCollarGrains + weightScrewGrains;

  double get rearGrains =>
      nockGrains +
      bushingGrains +
      wrapGrains +
      (vaneGrainsEach * vaneCount) +
      otherRearGrains;

  double get totalGrains => shaftGrains + frontGrains + rearGrains;
}

enum BowType { compound, recurve, traditional, crossbow }

enum CamStyle { standard, aggressive, soft }
