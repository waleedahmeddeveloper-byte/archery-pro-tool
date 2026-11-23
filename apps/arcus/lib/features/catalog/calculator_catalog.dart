enum CalculatorCategory {
  arrowBuild,
  bowPerformance,
  performance,
  spineTuning,
  crossbow,
  converters,
  workflow,
}

class CalculatorDef {
  const CalculatorDef({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.route,
  });

  final String id;
  final String title;
  final String subtitle;
  final CalculatorCategory category;
  final String route;
}

abstract final class CalculatorCatalog {
  static const items = <CalculatorDef>[
    CalculatorDef(
      id: 'foc_measured',
      title: 'FOC (measured)',
      subtitle: 'AMO balance-point front-of-center',
      category: CalculatorCategory.arrowBuild,
      route: '/calc/foc',
    ),
    CalculatorDef(
      id: 'arrow_weight',
      title: 'Arrow weight',
      subtitle: 'GPI, components, GPP',
      category: CalculatorCategory.arrowBuild,
      route: '/calc/arrow-weight',
    ),
    CalculatorDef(
      id: 'ke_momentum',
      title: 'Kinetic energy & momentum',
      subtitle: 'ft-lb, joules, slug·ft/s',
      category: CalculatorCategory.performance,
      route: '/calc/ke-momentum',
    ),
    CalculatorDef(
      id: 'speed_mass',
      title: 'Arrow speed (mass change)',
      subtitle: 'Estimate fps when arrow weight changes',
      category: CalculatorCategory.bowPerformance,
      route: '/calc/speed-mass',
    ),
    CalculatorDef(
      id: 'ibo_speed',
      title: 'Bow speed (IBO)',
      subtitle: 'Adjust published IBO to your setup',
      category: CalculatorCategory.bowPerformance,
      route: '/calc/ibo-speed',
    ),
    CalculatorDef(
      id: 'spine',
      title: 'Spine selection',
      subtitle: 'Planning chart with cam & point adjustments',
      category: CalculatorCategory.spineTuning,
      route: '/calc/spine',
    ),
    CalculatorDef(
      id: 'drop',
      title: 'Arrow drop / trajectory',
      subtitle: 'Gravity model with optional drag',
      category: CalculatorCategory.performance,
      route: '/calc/drop',
    ),
    CalculatorDef(
      id: 'draw_length',
      title: 'Draw length',
      subtitle: 'Wingspan estimate + confirmation notes',
      category: CalculatorCategory.bowPerformance,
      route: '/calc/draw-length',
    ),
    CalculatorDef(
      id: 'shot_angle',
      title: 'Shot angle',
      subtitle: 'True horizontal distance',
      category: CalculatorCategory.performance,
      route: '/calc/shot-angle',
    ),
    CalculatorDef(
      id: 'converter',
      title: 'Unit converter',
      subtitle: 'Weight, length, speed, energy',
      category: CalculatorCategory.converters,
      route: '/calc/converter',
    ),
    CalculatorDef(
      id: 'assistant',
      title: 'Setup Assistant',
      subtitle: 'Guided multi-step bow + arrow workflow',
      category: CalculatorCategory.workflow,
      route: '/assistant',
    ),
  ];

  static String categoryLabel(CalculatorCategory c) => switch (c) {
        CalculatorCategory.arrowBuild => 'Arrow building',
        CalculatorCategory.bowPerformance => 'Bow performance',
        CalculatorCategory.performance => 'Arrow performance',
        CalculatorCategory.spineTuning => 'Spine & tuning',
        CalculatorCategory.crossbow => 'Crossbow',
        CalculatorCategory.converters => 'Converters',
        CalculatorCategory.workflow => 'Workflow',
      };
}
