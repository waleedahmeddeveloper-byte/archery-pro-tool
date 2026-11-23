/// Traceable references for every formula exposed by the engine.
class FormulaCitation {
  const FormulaCitation({
    required this.id,
    required this.title,
    required this.source,
    required this.url,
    required this.notes,
  });

  final String id;
  final String title;
  final String source;
  final String url;
  final String notes;
}

/// Canonical citations. Prefer manufacturer primary sources over tertiary blogs.
abstract final class Citations {
  static const focAmo = FormulaCitation(
    id: 'foc_amo',
    title: 'AMO-standard F.O.C. balance formula',
    source: 'Easton Archery FOC FAQ',
    url: 'https://eastonarchery.com/2022/03/faqs-about-arrow-f-o-c-front-of-center/',
    notes:
        'FOC% = 100 × (A − L/2) / L with L from nock throat to shaft end and A to balance point on a fully assembled arrow.',
  );

  static const keFtLb = FormulaCitation(
    id: 'ke_ftlbf',
    title: 'Arrow kinetic energy in foot-pounds',
    source: 'Industry archery form of ½mv² with grains/fps',
    url: 'https://eastonarchery.com/faqs/',
    notes:
        'KE (ft-lb) = grains × fps² ÷ 450240. Constant ≈ 2 × 7000 × 32.16. Some tools use 450800 (g=32.2); difference <0.2%.',
  );

  static const momentumSlug = FormulaCitation(
    id: 'momentum_slug',
    title: 'Arrow linear momentum',
    source: 'Physics p = mv with grains→slugs conversion',
    url: 'https://en.wikipedia.org/wiki/Momentum',
    notes:
        'Momentum (slug·ft/s) = grains × fps ÷ 225218 where 225218 ≈ 7000 × 32.174. SI: kg·m/s.',
  );

  static const drawLengthWingspan = FormulaCitation(
    id: 'draw_length_wingspan',
    title: 'Wingspan draw-length estimate',
    source: 'Common archery shop fitting heuristic',
    url: 'https://www.archerytrade.org/',
    notes:
        'Estimate = wingspan_inches ÷ 2.5. Must be confirmed at full draw with ATA method (pivot point + 1.75 in).',
  );

  static const speedMassRatio = FormulaCitation(
    id: 'speed_mass_ratio',
    title: 'Speed change with arrow mass at constant energy',
    source: 'Conservation of kinetic energy',
    url: 'https://en.wikipedia.org/wiki/Kinetic_energy',
    notes:
        'v = v_ref × √(m_ref / m_new) × efficiency. Assumes stored energy delivered is unchanged; chronograph to verify.',
  );

  static const iboEnergyScale = FormulaCitation(
    id: 'ibo_energy_scale',
    title: 'IBO rating adjusted to real setup (energy model)',
    source: 'IBO/ATA rating definition + energy scaling model',
    url: 'https://www.archerytrade.org/',
    notes:
        'IBO baseline commonly 70 lb / 30 in / 350 gr. Arcus scales KE then solves speed. Estimate only.',
  );

  static const spineHeuristic = FormulaCitation(
    id: 'spine_effective_weight',
    title: 'Effective draw-weight spine heuristic',
    source: 'Common shop adjustment used for planning charts',
    url: 'https://eastonarchery.com/',
    notes:
        '+4 lb per inch of arrow over 28 in; +3 lb per 25 gr point over 100 gr; cam style ±. Always confirm on the current manufacturer chart for the exact shaft model.',
  );

  static const gravityDrop = FormulaCitation(
    id: 'gravity_drop',
    title: 'Vacuum gravity drop',
    source: 'Newtonian free fall',
    url: 'https://en.wikipedia.org/wiki/Free_fall',
    notes:
        'drop = ½ g t² with t = distance/speed. Real arrows also lose speed to drag; optional Cd model is labeled separately.',
  );

  static const gppSafety = FormulaCitation(
    id: 'gpp_minimum',
    title: 'Grains-per-pound safety floor',
    source: 'IBO minimum arrow mass convention / bow manuals',
    url: 'https://www.archerytrade.org/',
    notes:
        'Many compounds specify ≥5 grains per pound of draw weight. Never shoot below the bow manufacturer minimum.',
  );
}
