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
    this.faqs = const [],
    this.examples = const [],
    this.relatedIds = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final CalculatorCategory category;
  final String route;
  final List<({String q, String a})> faqs;
  final List<String> examples;
  final List<String> relatedIds;
}

abstract final class CalculatorCatalog {
  static const items = <CalculatorDef>[
    // —— Arrow build ——
    CalculatorDef(
      id: 'foc',
      title: 'FOC (measured)',
      subtitle: 'AMO balance-point front-of-center',
      category: CalculatorCategory.arrowBuild,
      route: '/calc/foc',
      relatedIds: ['foc-components', 'arrow-weight', 'point-foc'],
      faqs: [
        (q: 'What is FOC?', a: 'Front-of-center is how far the balance point sits ahead of the shaft midpoint, as a percent of length.'),
        (q: 'What FOC should I hunt with?', a: 'Many compound hunting builds land near 10–15%. Higher FOC needs matched spine.'),
      ],
      examples: ['29 in shaft balancing at 18.2 in ≈ 12.8% FOC'],
    ),
    CalculatorDef(
      id: 'foc-components',
      title: 'FOC (component estimate)',
      subtitle: 'Estimate FOC from component masses',
      category: CalculatorCategory.arrowBuild,
      route: '/calc/foc-components',
      relatedIds: ['foc', 'arrow-weight'],
    ),
    CalculatorDef(
      id: 'arrow-weight',
      title: 'Arrow Weight',
      subtitle: 'Total grains, GPP, component breakdown',
      category: CalculatorCategory.arrowBuild,
      route: '/calc/arrow-weight',
      relatedIds: ['gpp', 'foc', 'ke-momentum'],
    ),
    CalculatorDef(
      id: 'component-weight',
      title: 'Arrow Component Weight',
      subtitle: 'Front vs rear contribution',
      category: CalculatorCategory.arrowBuild,
      route: '/calc/component-weight',
    ),
    CalculatorDef(
      id: 'gpi',
      title: 'GPI Calculator',
      subtitle: 'Shaft grains from GPI × length',
      category: CalculatorCategory.arrowBuild,
      route: '/calc/gpi',
    ),
    CalculatorDef(
      id: 'arrow-length',
      title: 'Arrow Length',
      subtitle: 'Cut-length suggestion from draw length',
      category: CalculatorCategory.arrowBuild,
      route: '/calc/arrow-length',
    ),
    CalculatorDef(
      id: 'point-weight',
      title: 'Point Weight Compare',
      subtitle: 'Tip + insert front mass',
      category: CalculatorCategory.arrowBuild,
      route: '/calc/point-weight',
    ),
    CalculatorDef(
      id: 'gpp',
      title: 'Arrow Weight to GPP',
      subtitle: 'Grains per pound of draw weight',
      category: CalculatorCategory.arrowBuild,
      route: '/calc/gpp',
    ),
    CalculatorDef(
      id: 'component-builder',
      title: 'Arrow Component Builder',
      subtitle: 'Full build: weight + FOC estimate',
      category: CalculatorCategory.arrowBuild,
      route: '/calc/component-builder',
    ),
    CalculatorDef(
      id: 'balance',
      title: 'Arrow Balance',
      subtitle: 'Balance point from measured FOC inputs',
      category: CalculatorCategory.arrowBuild,
      route: '/calc/balance',
    ),
    CalculatorDef(
      id: 'spine',
      title: 'Arrow Spine',
      subtitle: 'Planning spine with length/point/cam adj',
      category: CalculatorCategory.spineTuning,
      route: '/calc/spine',
    ),
    CalculatorDef(
      id: 'point-foc',
      title: 'Point Weight for FOC',
      subtitle: 'Tip mass change to hit a target FOC',
      category: CalculatorCategory.arrowBuild,
      route: '/calc/point-foc',
    ),

    // —— Bow performance ——
    CalculatorDef(
      id: 'ibo-speed',
      title: 'Bow / IBO Speed',
      subtitle: 'Adjust published IBO to your setup',
      category: CalculatorCategory.bowPerformance,
      route: '/calc/ibo-speed',
    ),
    CalculatorDef(
      id: 'speed-mass',
      title: 'Arrow Speed',
      subtitle: 'Speed change with arrow mass',
      category: CalculatorCategory.bowPerformance,
      route: '/calc/speed-mass',
    ),
    CalculatorDef(
      id: 'fps-mph',
      title: 'FPS to MPH',
      subtitle: 'Speed unit conversion',
      category: CalculatorCategory.bowPerformance,
      route: '/calc/fps-mph',
    ),
    CalculatorDef(
      id: 'draw-weight',
      title: 'Draw Weight Guide',
      subtitle: 'Planning bands by game class',
      category: CalculatorCategory.bowPerformance,
      route: '/calc/draw-weight',
    ),
    CalculatorDef(
      id: 'draw-length',
      title: 'Draw Length',
      subtitle: 'Wingspan estimate',
      category: CalculatorCategory.bowPerformance,
      route: '/calc/draw-length',
    ),
    CalculatorDef(
      id: 'bow-efficiency',
      title: 'Bow Efficiency',
      subtitle: 'Approx stored energy vs arrow KE',
      category: CalculatorCategory.bowPerformance,
      route: '/calc/bow-efficiency',
    ),
    CalculatorDef(
      id: 'let-off',
      title: 'Let-Off',
      subtitle: 'Holding weight from peak & let-off %',
      category: CalculatorCategory.bowPerformance,
      route: '/calc/let-off',
    ),
    CalculatorDef(
      id: 'stored-energy',
      title: 'Stored / Bow Energy',
      subtitle: 'Approximate stored energy & efficiency',
      category: CalculatorCategory.bowPerformance,
      route: '/calc/stored-energy',
    ),

    // —— Performance / hunting ——
    CalculatorDef(
      id: 'ke-momentum',
      title: 'Kinetic Energy & Momentum',
      subtitle: 'ft-lb, joules, slug·ft/s',
      category: CalculatorCategory.performance,
      route: '/calc/ke-momentum',
    ),
    CalculatorDef(
      id: 'ke',
      title: 'Kinetic Energy',
      subtitle: 'ft-lb and joules',
      category: CalculatorCategory.performance,
      route: '/calc/ke',
    ),
    CalculatorDef(
      id: 'momentum',
      title: 'Arrow Momentum',
      subtitle: 'slug·ft/s and kg·m/s',
      category: CalculatorCategory.performance,
      route: '/calc/momentum',
    ),
    CalculatorDef(
      id: 'drop',
      title: 'Arrow Drop',
      subtitle: 'Gravity trajectory vs LOS',
      category: CalculatorCategory.performance,
      route: '/calc/drop',
    ),
    CalculatorDef(
      id: 'trajectory',
      title: 'Arrow Trajectory',
      subtitle: 'Drop table with optional drag',
      category: CalculatorCategory.performance,
      route: '/calc/trajectory',
    ),
    CalculatorDef(
      id: 'sight-pin',
      title: 'Sight Pin Gap',
      subtitle: 'Approximate pin spacing',
      category: CalculatorCategory.performance,
      route: '/calc/sight-pin',
    ),
    CalculatorDef(
      id: 'shot-angle',
      title: 'Shot Angle',
      subtitle: 'True horizontal distance',
      category: CalculatorCategory.performance,
      route: '/calc/shot-angle',
    ),
    CalculatorDef(
      id: 'distance-comp',
      title: 'Distance Compensation',
      subtitle: 'Angled-shot horizontal distance',
      category: CalculatorCategory.performance,
      route: '/calc/distance-comp',
    ),
    CalculatorDef(
      id: 'velocity-loss',
      title: 'Velocity Loss',
      subtitle: 'Speed lost over distance',
      category: CalculatorCategory.performance,
      route: '/calc/velocity-loss',
    ),
    CalculatorDef(
      id: 'downrange',
      title: 'Downrange Energy & Momentum',
      subtitle: 'KE/momentum table by yardage',
      category: CalculatorCategory.performance,
      route: '/calc/downrange',
    ),

    // —— Spine ——
    CalculatorDef(
      id: 'dynamic-spine',
      title: 'Dynamic Spine (planning)',
      subtitle: 'Effective-weight spine for your bow',
      category: CalculatorCategory.spineTuning,
      route: '/calc/dynamic-spine',
    ),
    CalculatorDef(
      id: 'static-spine',
      title: 'Static Spine Explainer',
      subtitle: 'What the stamped spine number means',
      category: CalculatorCategory.spineTuning,
      route: '/calc/static-spine',
    ),
    CalculatorDef(
      id: 'spine-chart',
      title: 'Arrow Spine Chart',
      subtitle: 'Planning bands by effective weight',
      category: CalculatorCategory.spineTuning,
      route: '/calc/spine-chart',
    ),
    CalculatorDef(
      id: 'spine-compound',
      title: 'Compound Spine Chart',
      subtitle: 'Compound planning chart',
      category: CalculatorCategory.spineTuning,
      route: '/calc/spine-compound',
    ),
    CalculatorDef(
      id: 'spine-recurve',
      title: 'Recurve Spine Chart',
      subtitle: 'Recurve/traditional planning chart',
      category: CalculatorCategory.spineTuning,
      route: '/calc/spine-recurve',
    ),
    CalculatorDef(
      id: 'spine-traditional',
      title: 'Traditional Spine Chart',
      subtitle: 'Finger-bow planning chart',
      category: CalculatorCategory.spineTuning,
      route: '/calc/spine-traditional',
    ),
    CalculatorDef(
      id: 'point-adj',
      title: 'Point Weight Adjustment',
      subtitle: 'How tip mass shifts effective spine load',
      category: CalculatorCategory.spineTuning,
      route: '/calc/point-adj',
    ),
    CalculatorDef(
      id: 'length-adj',
      title: 'Arrow Length Adjustment',
      subtitle: 'How cut length shifts effective load',
      category: CalculatorCategory.spineTuning,
      route: '/calc/length-adj',
    ),
    CalculatorDef(
      id: 'cam-adj',
      title: 'Cam Type Adjustment',
      subtitle: 'Aggressive vs soft cam load shift',
      category: CalculatorCategory.spineTuning,
      route: '/calc/cam-adj',
    ),
    CalculatorDef(
      id: 'spine-assistant',
      title: 'Spine Selection Assistant',
      subtitle: 'Guided spine pick with chart name shown',
      category: CalculatorCategory.spineTuning,
      route: '/calc/spine-assistant',
    ),

    // —— Crossbow ——
    CalculatorDef(
      id: 'xbow-speed',
      title: 'Crossbow Speed',
      subtitle: 'Scale rated speed to your bolt weight',
      category: CalculatorCategory.crossbow,
      route: '/calc/xbow-speed',
    ),
    CalculatorDef(
      id: 'xbow-ke',
      title: 'Crossbow Kinetic Energy',
      subtitle: 'KE from bolt weight & speed',
      category: CalculatorCategory.crossbow,
      route: '/calc/xbow-ke',
    ),
    CalculatorDef(
      id: 'xbow-momentum',
      title: 'Crossbow Momentum',
      subtitle: 'Momentum from bolt weight & speed',
      category: CalculatorCategory.crossbow,
      route: '/calc/xbow-momentum',
    ),
    CalculatorDef(
      id: 'xbow-weight',
      title: 'Crossbow Bolt Weight',
      subtitle: 'Finished bolt grains + minimum heuristic',
      category: CalculatorCategory.crossbow,
      route: '/calc/xbow-weight',
    ),
    CalculatorDef(
      id: 'xbow-ballistics',
      title: 'Crossbow Ballistics',
      subtitle: 'Speed + KE + drop table',
      category: CalculatorCategory.crossbow,
      route: '/calc/xbow-ballistics',
    ),
    CalculatorDef(
      id: 'xbow-trajectory',
      title: 'Crossbow Trajectory',
      subtitle: 'Drop vs distance for bolts',
      category: CalculatorCategory.crossbow,
      route: '/calc/xbow-trajectory',
    ),
    CalculatorDef(
      id: 'xbow-guide',
      title: 'Bolt Selection Guide',
      subtitle: 'Minimum mass guidance (manual overrides)',
      category: CalculatorCategory.crossbow,
      route: '/calc/xbow-guide',
    ),

    // —— Converters ——
    CalculatorDef(
      id: 'converter',
      title: 'Unit Converter',
      subtitle: 'Weight, length, speed, energy, angle, distance',
      category: CalculatorCategory.converters,
      route: '/calc/converter',
    ),

    // —— Workflow ——
    CalculatorDef(
      id: 'assistant',
      title: 'Setup Assistant',
      subtitle: 'Guided bow + arrow workflow',
      category: CalculatorCategory.workflow,
      route: '/assistant',
    ),
  ];

  static CalculatorDef? byId(String id) {
    for (final i in items) {
      if (i.id == id) return i;
    }
    return null;
  }

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
