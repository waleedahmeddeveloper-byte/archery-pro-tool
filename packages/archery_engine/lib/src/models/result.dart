import '../references/citations.dart';

/// Structured calculator output with transparency fields required by Arcus UX.
class CalcResult<T> {
  const CalcResult({
    required this.value,
    required this.formulaId,
    required this.formulaDisplay,
    required this.steps,
    required this.assumptions,
    required this.limitations,
    required this.safetyNotes,
    required this.citation,
    this.warnings = const [],
    this.metadata = const {},
  });

  final T value;
  final String formulaId;
  final String formulaDisplay;
  final List<String> steps;
  final List<String> assumptions;
  final List<String> limitations;
  final List<String> safetyNotes;
  final FormulaCitation citation;
  final List<String> warnings;
  final Map<String, Object?> metadata;
}

class ValidationException implements Exception {
  ValidationException(this.message);
  final String message;

  @override
  String toString() => 'ValidationException: $message';
}

void requireFinitePositive(String name, double value, {bool allowZero = false}) {
  if (value.isNaN || value.isInfinite) {
    throw ValidationException('$name must be a finite number.');
  }
  if (allowZero) {
    if (value < 0) throw ValidationException('$name must be ≥ 0.');
  } else if (value <= 0) {
    throw ValidationException('$name must be > 0.');
  }
}

void requireFiniteNonNegative(String name, double value) {
  requireFinitePositive(name, value, allowZero: true);
}

void requireFiniteNumber(String name, double value) {
  if (value.isNaN || value.isInfinite) {
    throw ValidationException('$name must be a finite number.');
  }
}
