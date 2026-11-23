import 'package:archery_engine/archery_engine.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../catalog/calculator_catalog.dart';
import 'widgets/calculator_scaffold.dart';
import 'widgets/foc_visual.dart';

typedef _FieldMap = Map<String, TextEditingController>;

class GenericCalculatorPage extends StatefulWidget {
  const GenericCalculatorPage({super.key, required this.calcId});

  final String calcId;

  @override
  State<GenericCalculatorPage> createState() => _GenericCalculatorPageState();
}

class _GenericCalculatorPageState extends State<GenericCalculatorPage> {
  final _engine = const ArcheryEngine();
  late final CalculatorDef? _def;
  late _FieldMap _fields;
  BowType _bowType = BowType.compound;
  CamStyle _camStyle = CamStyle.standard;
  GameClass _game = GameClass.deer;
  CalcResult<dynamic>? _result;
  String? _headline;
  Widget? _extra;
  String? _error;

  @override
  void initState() {
    super.initState();
    _def = CalculatorCatalog.byId(widget.calcId);
    _fields = _defaultFields(widget.calcId);
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  double _d(String key) => parseDouble(_fields[key]!.text) ?? double.nan;

  void _reset() {
    final defaults = _defaultFieldValues(widget.calcId);
    for (final e in defaults.entries) {
      _fields[e.key]?.text = e.value;
    }
    setState(() {
      _result = null;
      _headline = null;
      _extra = null;
      _error = null;
    });
  }

  void _calc() {
    setState(() {
      _error = null;
      _extra = null;
      try {
        final out = _run(widget.calcId);
        _result = out.$1;
        _headline = out.$2;
        _extra = out.$3;
      } catch (e) {
        _result = null;
        _headline = null;
        _extra = null;
        _error = e.toString().replaceFirst('ValidationException: ', '');
      }
    });
  }

  (CalcResult<dynamic>, String, Widget?) _run(String id) {
    switch (id) {
      case 'foc':
      case 'balance':
        final r = _engine.focMeasured(
          arrowLengthInches: _d('length'),
          balancePointFromNockInches: _d('balance'),
        );
        return (
          r,
          '${r.value.focPercent.toStringAsFixed(2)}% FOC',
          FocVisual(
            lengthInches: _d('length'),
            balanceInches: _d('balance'),
            focPercent: r.value.focPercent,
          ),
        );
      case 'foc-components':
      case 'component-builder':
        final c = _components();
        final foc = _engine.focFromComponents(components: c);
        final wt = _engine.arrowWeight(
          components: c,
          drawWeightPounds: _d('draw'),
        );
        return (
          foc,
          '${foc.value.focPercent.toStringAsFixed(2)}% FOC · ${wt.value.totalGrains.toStringAsFixed(1)} gr',
          Text(
            'Shaft ${wt.value.shaftGrains.toStringAsFixed(1)} · Front ${wt.value.frontGrains.toStringAsFixed(1)} · Rear ${wt.value.rearGrains.toStringAsFixed(1)}',
          ),
        );
      case 'arrow-weight':
      case 'component-weight':
        final wt = _engine.arrowWeight(
          components: _components(),
          drawWeightPounds: _d('draw'),
        );
        return (
          wt,
          '${wt.value.totalGrains.toStringAsFixed(1)} gr'
              '${wt.value.grainsPerPound == null ? '' : ' · ${wt.value.grainsPerPound!.toStringAsFixed(2)} gpp'}',
          Text(
            'Shaft ${wt.value.shaftGrains.toStringAsFixed(1)} · Front ${wt.value.frontGrains.toStringAsFixed(1)} · Rear ${wt.value.rearGrains.toStringAsFixed(1)}',
          ),
        );
      case 'gpi':
        final gpi = _d('gpi');
        final len = _d('length');
        final shaft = gpi * len;
        final r = CalcResult(
          value: shaft,
          formulaId: 'gpi_shaft',
          formulaDisplay: 'Shaft grains = GPI × length',
          steps: [
            '${gpi.toStringAsFixed(2)} × ${len.toStringAsFixed(2)} = ${shaft.toStringAsFixed(2)} gr',
          ],
          assumptions: ['Catalog GPI is nominal; weigh finished shafts when possible.'],
          limitations: ['Ignores glue and wrap unless entered elsewhere.'],
          safetyNotes: const [],
          citation: Citations.arrowWeightSum,
        );
        return (r, '${shaft.toStringAsFixed(1)} gr shaft', null);
      case 'arrow-length':
        final r = _engine.arrowCutLength(drawLengthInches: _d('drawLen'));
        return (r, '${r.value.toStringAsFixed(2)} in suggested cut', null);
      case 'point-weight':
        final tip = _d('point') + _d('insert');
        final r = CalcResult(
          value: tip,
          formulaId: 'point_front',
          formulaDisplay: 'Front mass = point + insert (+ collar if entered)',
          steps: [
            'Point ${_d('point').toStringAsFixed(1)} + insert ${_d('insert').toStringAsFixed(1)} = ${tip.toStringAsFixed(1)} gr',
          ],
          assumptions: const ['Weights are as listed by the manufacturer.'],
          limitations: const ['Does not include outsert or glue unless added.'],
          safetyNotes: const [],
          citation: Citations.arrowWeightSum,
        );
        return (r, '${tip.toStringAsFixed(1)} gr front tip mass', null);
      case 'gpp':
        final r = _engine.grainsPerPound(
          totalGrains: _d('total'),
          drawWeightPounds: _d('draw'),
        );
        return (r, '${r.value.toStringAsFixed(2)} gpp', null);
      case 'point-foc':
        final r = _engine.pointWeightForFoc(
          arrowLengthInches: _d('length'),
          currentTotalGrains: _d('total'),
          currentFocPercent: _d('foc'),
          targetFocPercent: _d('targetFoc'),
        );
        return (r, '${r.value.toStringAsFixed(1)} gr tip change', null);
      case 'ibo-speed':
        final r = _engine.speedFromIbo(
          iboFps: _d('ibo'),
          drawWeightPounds: _d('draw'),
          drawLengthInches: _d('drawLen'),
          arrowWeightGrains: _d('weight'),
          stringAccessoryGrains: _d('string'),
        );
        return (r, '${r.value.estimatedFps.toStringAsFixed(1)} fps est.', null);
      case 'speed-mass':
        final r = _engine.speedFromMassChange(
          referenceSpeedFps: _d('refSpeed'),
          referenceWeightGrains: _d('refWeight'),
          newWeightGrains: _d('newWeight'),
          efficiencyPercent: _d('eff'),
        );
        return (r, '${r.value.speedFps.toStringAsFixed(1)} fps', null);
      case 'fps-mph':
        final fps = _d('fps');
        final mph = _engine.convertSpeedValue(fps, SpeedUnit.fps, SpeedUnit.mph);
        final ms = _engine.convertSpeedValue(fps, SpeedUnit.fps, SpeedUnit.metersPerSecond);
        final r = CalcResult(
          value: mph,
          formulaId: 'fps_mph',
          formulaDisplay: '1 fps = 0.681818… mph · 1 fps = 0.3048 m/s',
          steps: [
            '${fps.toStringAsFixed(1)} fps = ${mph.toStringAsFixed(2)} mph',
            '${fps.toStringAsFixed(1)} fps = ${ms.toStringAsFixed(2)} m/s',
          ],
          assumptions: const ['Exact SI conversions.'],
          limitations: const [],
          safetyNotes: const [],
          citation: Citations.unitConversions,
        );
        return (r, '${mph.toStringAsFixed(2)} mph · ${ms.toStringAsFixed(2)} m/s', null);
      case 'draw-weight':
        final r = _engine.drawWeightGuide(game: _game, drawLengthInches: _d('drawLen'));
        return (
          r,
          '${r.value.suggestedMinPounds.toStringAsFixed(0)}–${r.value.suggestedComfortPounds.toStringAsFixed(0)} lb band',
          Text(r.value.notes),
        );
      case 'draw-length':
        final r = _engine.drawLengthFromWingspan(_d('wingspan'));
        return (r, '${r.value.toStringAsFixed(2)} in draw (est.)', null);
      case 'bow-efficiency':
      case 'stored-energy':
        final r = _engine.bowEnergy(
          peakDrawWeightPounds: _d('draw'),
          drawLengthInches: _d('drawLen'),
          arrowWeightGrains: _d('weight'),
          arrowSpeedFps: _d('speed'),
          braceHeightInches: _d('brace'),
          letOffPercent: _d('letoff'),
        );
        return (
          r,
          '${r.value.efficiencyPercent.toStringAsFixed(1)}% eff · ${r.value.storedEnergyFtLbApprox.toStringAsFixed(1)} ft-lb stored',
          Text('Arrow KE ${r.value.arrowKeFtLb.toStringAsFixed(1)} ft-lb'),
        );
      case 'let-off':
        final r = _engine.letOffHolding(
          peakDrawWeightPounds: _d('draw'),
          letOffPercent: _d('letoff'),
        );
        return (r, '${r.value.holdingWeightPounds.toStringAsFixed(1)} lb holding', null);
      case 'ke-momentum':
      case 'ke':
      case 'momentum':
      case 'xbow-ke':
      case 'xbow-momentum':
        final r = _engine.energyMomentum(
          arrowWeightGrains: _d('weight'),
          speedFps: _d('speed'),
        );
        final head = id.contains('momentum') && !id.contains('ke')
            ? '${r.value.momentumSlugFtPerSec.toStringAsFixed(3)} slug·ft/s'
            : id.contains('ke') && !id.contains('momentum')
                ? '${r.value.keFtLb.toStringAsFixed(2)} ft-lb'
                : '${r.value.keFtLb.toStringAsFixed(2)} ft-lb · ${r.value.momentumSlugFtPerSec.toStringAsFixed(3)} slug·ft/s';
        return (r, head, null);
      case 'drop':
      case 'trajectory':
      case 'xbow-trajectory':
        final sight = _fields.containsKey('sight') ? _d('sight') : 3.5;
        final r = _d('drag') > 0
            ? _engine.trajectoryWithDrag(
                speedFps: _d('speed'),
                zeroYards: _d('zero'),
                dragPerSecond: _d('drag'),
              )
            : _engine.trajectoryGravity(
                speedFps: _d('speed'),
                zeroYards: _d('zero'),
                sightHeightInches: sight,
              );
        return (r, 'Trajectory table', _dropChart(r.value));
      case 'sight-pin':
        final r = _engine.sightPinGaps(
          speedFps: _d('speed'),
          zeroYards: _d('zero'),
          peepToSightInches: _d('peep'),
        );
        return (
          r,
          '${r.value.gapsInches.length} pin gaps',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: r.value.gapsInches
                .map(
                  (g) => Text(
                    '${g.fromYd.toStringAsFixed(0)}→${g.toYd.toStringAsFixed(0)} yd · ${g.gapInches.toStringAsFixed(3)} in gap',
                  ),
                )
                .toList(),
          ),
        );
      case 'shot-angle':
      case 'distance-comp':
        final r = _engine.shotAngleDistance(
          lineOfSightYards: _d('los'),
          angleDegrees: _d('angle'),
        );
        return (r, '${r.value.toStringAsFixed(2)} yd horizontal', null);
      case 'velocity-loss':
        final r = _engine.velocityLossAt(
          launchSpeedFps: _d('speed'),
          distanceYards: _d('dist'),
          dragPerSecond: _d('drag'),
        );
        return (r, '${r.value.toStringAsFixed(1)} fps lost', null);
      case 'downrange':
        final r = _engine.downrange(
          launchSpeedFps: _d('speed'),
          arrowWeightGrains: _d('weight'),
          dragPerSecond: _d('drag'),
        );
        return (
          r,
          'Downrange table',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: r.value.points
                .map(
                  (p) => Text(
                    '${p.yards.toStringAsFixed(0)} yd · ${p.speedFps.toStringAsFixed(0)} fps · ${p.keFtLb.toStringAsFixed(1)} ft-lb · ${p.momentumSlugFtPerSec.toStringAsFixed(3)} mom',
                  ),
                )
                .toList(),
          ),
        );
      case 'spine':
      case 'dynamic-spine':
      case 'spine-assistant':
      case 'spine-compound':
      case 'spine-recurve':
      case 'spine-traditional':
        final bow = switch (id) {
          'spine-compound' => BowType.compound,
          'spine-recurve' => BowType.recurve,
          'spine-traditional' => BowType.traditional,
          _ => _bowType,
        };
        final r = _engine.spine(
          bowType: bow,
          drawWeightPounds: _d('draw'),
          arrowLengthInches: _d('length'),
          pointWeightGrains: _d('point'),
          camStyle: _camStyle,
        );
        return (
          r,
          'Spine ${r.value.primarySpine}'
              '${r.value.alternateSpine == null ? '' : ' / ${r.value.alternateSpine}'}',
          Text(r.value.chartName),
        );
      case 'static-spine':
      case 'spine-chart':
        final r = CalcResult(
          value: 'static',
          formulaId: 'static_spine_explainer',
          formulaDisplay:
              'Static spine = deflection (in) × 1000 under AMO test (≈1.94 lb mid-span on 28 in supports)',
          steps: const [
            'A stamped “400” spine deflects ~0.400 in under the AMO static test.',
            'Lower number = stiffer shaft. Dynamic behavior still depends on bow, length, and tip mass.',
            'Use the dynamic spine tools for planning — then paper-tune.',
          ],
          assumptions: const [
            'Manufacturer stamp uses their published test; confirm their chart.',
          ],
          limitations: const [
            'Static spine alone does not select an arrow for your bow.',
          ],
          safetyNotes: const [
            'Never shoot a shaft that is clearly too weak for your draw weight.',
          ],
          citation: Citations.spinePlanning,
        );
        return (r, 'Static spine explainer', _spineChartTable(_bowType));
      case 'point-adj':
      case 'length-adj':
      case 'cam-adj':
        final base = _engine.spine(
          bowType: _bowType,
          drawWeightPounds: _d('draw'),
          arrowLengthInches: _d('length'),
          pointWeightGrains: _d('point'),
          camStyle: _camStyle,
        );
        return (
          base,
          'Effective planning spine ${base.value.primarySpine}',
          Text(
            'Length, tip mass, and cam style shift the effective load used against ${base.value.chartName}.',
          ),
        );
      case 'xbow-speed':
      case 'xbow-ballistics':
        final r = _engine.crossbowSpeed(
          ratedSpeedFps: _d('ratedSpeed'),
          ratedBoltGrains: _d('ratedWeight'),
          yourBoltGrains: _d('yourWeight'),
        );
        Widget? extra;
        if (id == 'xbow-ballistics') {
          final traj = _engine.trajectoryGravity(
            speedFps: r.value.estimatedFps,
            zeroYards: 20,
          );
          extra = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KE ${r.value.keFtLb.toStringAsFixed(1)} ft-lb · Mom ${r.value.momentumSlugFtPerSec.toStringAsFixed(3)}',
              ),
              const SizedBox(height: 8),
              _dropChart(traj.value),
            ],
          );
        }
        return (r, '${r.value.estimatedFps.toStringAsFixed(1)} fps est.', extra);
      case 'xbow-weight':
        final total = _d('shaft') + _d('point') + _d('nock') + _d('vanes');
        final guide = _engine.crossbowBoltGuide(
          ratedSpeedFps: _d('ratedSpeed'),
          drawWeightPounds: _d('draw'),
        );
        final r = CalcResult(
          value: total,
          formulaId: 'xbow_bolt_weight',
          formulaDisplay: 'Bolt = shaft + tip + nock + vanes (+ inserts)',
          steps: [
            'Total = ${total.toStringAsFixed(1)} gr',
            guide.value,
          ],
          assumptions: guide.assumptions,
          limitations: guide.limitations,
          safetyNotes: guide.safetyNotes,
          citation: guide.citation,
        );
        return (r, '${total.toStringAsFixed(1)} gr bolt', Text(guide.value));
      case 'xbow-guide':
        final r = _engine.crossbowBoltGuide(
          ratedSpeedFps: _d('ratedSpeed'),
          drawWeightPounds: _d('draw'),
        );
        return (r, 'Bolt guidance', Text(r.value));
      case 'converter':
        return _runConverter();
      default:
        throw ValidationException('Unknown calculator: $id');
    }
  }

  (CalcResult<dynamic>, String, Widget?) _runConverter() {
    final kind = _fields['kind']!.text.trim().toLowerCase();
    final value = _d('value');
    String display;
    List<String> steps;
    switch (kind) {
      case 'weight':
        final g = _engine.convertWeightValue(value, WeightUnit.grains, WeightUnit.grams);
        final oz = _engine.convertWeightValue(value, WeightUnit.grains, WeightUnit.ounces);
        display = '${g.toStringAsFixed(3)} g · ${oz.toStringAsFixed(4)} oz';
        steps = ['${value.toStringAsFixed(1)} gr → $display'];
      case 'length':
        final mm = _engine.convertLengthValue(value, LengthUnit.inches, LengthUnit.millimeters);
        final cm = _engine.convertLengthValue(value, LengthUnit.inches, LengthUnit.centimeters);
        display = '${mm.toStringAsFixed(2)} mm · ${cm.toStringAsFixed(2)} cm';
        steps = ['${value.toStringAsFixed(2)} in → $display'];
      case 'speed':
        final mph = _engine.convertSpeedValue(value, SpeedUnit.fps, SpeedUnit.mph);
        final ms = _engine.convertSpeedValue(value, SpeedUnit.fps, SpeedUnit.metersPerSecond);
        display = '${mph.toStringAsFixed(2)} mph · ${ms.toStringAsFixed(2)} m/s';
        steps = ['${value.toStringAsFixed(1)} fps → $display'];
      case 'energy':
        final j = _engine.convertEnergyValue(value, EnergyUnit.footPounds, EnergyUnit.joules);
        display = '${j.toStringAsFixed(2)} J';
        steps = ['${value.toStringAsFixed(2)} ft-lb → $display'];
      case 'angle':
        final rad = value * 3.141592653589793 / 180;
        display = '${rad.toStringAsFixed(4)} rad';
        steps = ['${value.toStringAsFixed(2)}° × π/180 = $display'];
      case 'distance':
        final m = value * 0.9144;
        final ft = value * 3;
        display = '${m.toStringAsFixed(2)} m · ${ft.toStringAsFixed(1)} ft';
        steps = ['${value.toStringAsFixed(1)} yd → $display'];
      default:
        throw ValidationException(
          'Kind must be weight, length, speed, energy, angle, or distance',
        );
    }
    final r = CalcResult(
      value: display,
      formulaId: 'converter_$kind',
      formulaDisplay: 'Dimensionally correct SI / imperial conversion',
      steps: steps,
      assumptions: const ['Exact published conversion factors.'],
      limitations: const [],
      safetyNotes: const [],
      citation: Citations.unitConversions,
    );
    return (r, display, null);
  }

  ArrowComponents _components() => ArrowComponents(
        gpi: _d('gpi'),
        shaftLengthInches: _d('length'),
        pointGrains: _d('point'),
        insertGrains: _d('insert'),
        outsertOrCollarGrains: _fields.containsKey('collar') ? _d('collar') : 0,
        nockGrains: _d('nock'),
        wrapGrains: _fields.containsKey('wrap') ? _d('wrap') : 0,
        vaneGrainsEach: _d('vane'),
        vaneCount: (_fields.containsKey('vaneCount')
                ? parseDouble(_fields['vaneCount']!.text)
                : 3)
            ?.round() ??
            3,
      );

  Widget _dropChart(TrajectoryResult traj) {
        final spots = traj.points
        .map((p) => FlSpot(p.distanceYards, -p.dropInchesFromLineOfSight))
        .toList();
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              axisNameWidget: const Text('Yards'),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) => Text(v.toInt().toString()),
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: const Text('Drop (in)'),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) => Text((-v).toInt().toString()),
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }

  Widget _spineChartTable(BowType bow) {
    final name = bow == BowType.compound
        ? SpinePlanningChart.compoundChartName
        : SpinePlanningChart.recurveChartName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        const Text(
          'Use Dynamic Spine / Spine Selection with your draw weight, length, tip, and cam. Charts are planning aids — confirm with manufacturer specs and paper tuning.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final def = _def;
    if (def == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: Center(child: Text('Unknown calculator: ${widget.calcId}')),
      );
    }

    final relatedTitles = def.relatedIds
        .map(CalculatorCatalog.byId)
        .whereType<CalculatorDef>()
        .map((e) => e.title)
        .toList();

    return CalculatorScaffold(
      title: def.title,
      intro: def.subtitle,
      breadcrumb: [
        'Home',
        CalculatorCatalog.categoryLabel(def.category),
        def.title,
      ],
      faqs: def.faqs,
      examples: def.examples,
      onCalculate: _calc,
      onReset: _reset,
      related: relatedTitles,
      onRelatedTap: (title) {
        final match = CalculatorCatalog.items.where((e) => e.title == title);
        if (match.isNotEmpty) context.push(match.first.route);
      },
      inputs: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildInputs(def.id),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
      resultPanel: _result == null
          ? null
          : ResultBreakdown(
              headline: _headline ?? 'Result',
              result: _result!,
              extra: _extra,
            ),
    );
  }

  List<Widget> _buildInputs(String id) {
    final widgets = <Widget>[];
    for (final e in _fields.entries) {
      if (e.key == 'kind') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropdownButtonFormField<String>(
              initialValue: e.value.text,
              items: const [
                DropdownMenuItem(value: 'weight', child: Text('Weight (grains in)')),
                DropdownMenuItem(value: 'length', child: Text('Length (inches in)')),
                DropdownMenuItem(value: 'speed', child: Text('Speed (fps in)')),
                DropdownMenuItem(value: 'energy', child: Text('Energy (ft-lb in)')),
                DropdownMenuItem(value: 'angle', child: Text('Angle (degrees in)')),
                DropdownMenuItem(value: 'distance', child: Text('Distance (yards in)')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => e.value.text = v);
              },
              decoration: const InputDecoration(labelText: 'Conversion kind'),
            ),
          ),
        );
        continue;
      }
      widgets.add(
        NumberField(
          label: _labelFor(e.key),
          controller: e.value,
          suffix: _suffixFor(e.key),
          helper: _helperFor(e.key),
        ),
      );
    }

    if ({
      'spine',
      'dynamic-spine',
      'spine-assistant',
      'point-adj',
      'length-adj',
      'cam-adj',
      'static-spine',
      'spine-chart',
    }.contains(id)) {
      widgets.insert(
        0,
        DropdownButtonFormField<BowType>(
          initialValue: _bowType,
          items: const [
            DropdownMenuItem(value: BowType.compound, child: Text('Compound')),
            DropdownMenuItem(value: BowType.recurve, child: Text('Recurve')),
            DropdownMenuItem(value: BowType.traditional, child: Text('Traditional')),
          ],
          onChanged: (v) => setState(() => _bowType = v ?? BowType.compound),
          decoration: const InputDecoration(labelText: 'Bow type'),
        ),
      );
      widgets.insert(
        1,
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: DropdownButtonFormField<CamStyle>(
            initialValue: _camStyle,
            items: const [
              DropdownMenuItem(value: CamStyle.standard, child: Text('Standard cam')),
              DropdownMenuItem(value: CamStyle.aggressive, child: Text('Aggressive cam')),
              DropdownMenuItem(value: CamStyle.soft, child: Text('Soft cam')),
            ],
            onChanged: (v) => setState(() => _camStyle = v ?? CamStyle.standard),
            decoration: const InputDecoration(labelText: 'Cam style'),
          ),
        ),
      );
    }

    if (id == 'draw-weight') {
      widgets.insert(
        0,
        DropdownButtonFormField<GameClass>(
          initialValue: _game,
          items: GameClass.values
              .map(
                (g) => DropdownMenuItem(
                  value: g,
                  child: Text(g.name),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _game = v ?? GameClass.deer),
          decoration: const InputDecoration(labelText: 'Game class'),
        ),
      );
    }

    return widgets;
  }

  String _labelFor(String key) => switch (key) {
        'length' => 'Arrow / shaft length',
        'balance' => 'Balance point from nock',
        'gpi' => 'GPI',
        'point' => 'Point weight',
        'insert' => 'Insert weight',
        'collar' => 'Collar / outsert',
        'nock' => 'Nock weight',
        'wrap' => 'Wrap weight',
        'vane' => 'Vane weight each',
        'vaneCount' => 'Vane count',
        'draw' => 'Draw weight',
        'drawLen' => 'Draw length',
        'total' => 'Total arrow weight',
        'foc' => 'Current FOC %',
        'targetFoc' => 'Target FOC %',
        'ibo' => 'IBO rating',
        'weight' => 'Arrow / bolt weight',
        'string' => 'String accessory mass',
        'refSpeed' => 'Reference speed',
        'refWeight' => 'Reference weight',
        'newWeight' => 'New weight',
        'eff' => 'Efficiency %',
        'fps' => 'Speed',
        'wingspan' => 'Wingspan',
        'speed' => 'Speed',
        'brace' => 'Brace height',
        'letoff' => 'Let-off %',
        'zero' => 'Zero distance',
        'drag' => 'Drag factor /s',
        'sight' => 'Sight height',
        'peep' => 'Peep to sight',
        'los' => 'Line-of-sight distance',
        'angle' => 'Angle',
        'dist' => 'Distance',
        'ratedSpeed' => 'Rated speed',
        'ratedWeight' => 'Rated bolt weight',
        'yourWeight' => 'Your bolt weight',
        'shaft' => 'Shaft weight',
        'vanes' => 'Vanes total',
        'value' => 'Value',
        _ => key,
      };

  String? _suffixFor(String key) => switch (key) {
        'length' || 'balance' || 'drawLen' || 'wingspan' || 'brace' || 'peep' => 'in',
        'gpi' => 'gr/in',
        'point' ||
        'insert' ||
        'collar' ||
        'nock' ||
        'wrap' ||
        'vane' ||
        'total' ||
        'weight' ||
        'string' ||
        'refWeight' ||
        'newWeight' ||
        'ratedWeight' ||
        'yourWeight' ||
        'shaft' ||
        'vanes' =>
          'gr',
        'draw' => 'lb',
        'foc' || 'targetFoc' || 'eff' || 'letoff' => '%',
        'ibo' ||
        'refSpeed' ||
        'fps' ||
        'speed' ||
        'ratedSpeed' =>
          'fps',
        'zero' || 'los' || 'dist' => 'yd',
        'angle' => '°',
        'drag' => '/s',
        'sight' => 'in',
        'vaneCount' => null,
        _ => null,
      };

  String? _helperFor(String key) => switch (key) {
        'balance' => 'Nock throat to fulcrum with arrow level.',
        'length' => 'Nock throat to end of shaft (AMO length).',
        'drag' => '0 = gravity-only model. ~0.08 is a mild planning drag.',
        'letoff' => 'Percent of peak weight held at full draw.',
        _ => null,
      };
}

Map<String, String> _defaultFieldValues(String id) {
  switch (id) {
    case 'foc':
    case 'balance':
      return {'length': '29', 'balance': '18.2'};
    case 'foc-components':
    case 'component-builder':
    case 'arrow-weight':
    case 'component-weight':
      return {
        'gpi': '8.5',
        'length': '28',
        'point': '125',
        'insert': '50',
        'collar': '0',
        'nock': '8',
        'wrap': '5',
        'vane': '6',
        'vaneCount': '3',
        'draw': '60',
      };
    case 'gpi':
      return {'gpi': '8.5', 'length': '28'};
    case 'arrow-length':
      return {'drawLen': '28'};
    case 'point-weight':
      return {'point': '125', 'insert': '50'};
    case 'gpp':
      return {'total': '420', 'draw': '60'};
    case 'point-foc':
      return {'length': '29', 'total': '420', 'foc': '10', 'targetFoc': '14'};
    case 'ibo-speed':
      return {
        'ibo': '335',
        'draw': '60',
        'drawLen': '28',
        'weight': '420',
        'string': '0',
      };
    case 'speed-mass':
      return {
        'refSpeed': '300',
        'refWeight': '350',
        'newWeight': '450',
        'eff': '95',
      };
    case 'fps-mph':
      return {'fps': '280'};
    case 'draw-weight':
      return {'drawLen': '28'};
    case 'draw-length':
      return {'wingspan': '70'};
    case 'bow-efficiency':
    case 'stored-energy':
      return {
        'draw': '70',
        'drawLen': '29',
        'weight': '420',
        'speed': '280',
        'brace': '6.5',
        'letoff': '80',
      };
    case 'let-off':
      return {'draw': '70', 'letoff': '80'};
    case 'ke-momentum':
    case 'ke':
    case 'momentum':
    case 'xbow-ke':
    case 'xbow-momentum':
      return {'weight': '420', 'speed': '280'};
    case 'drop':
    case 'trajectory':
    case 'xbow-trajectory':
      return {'speed': '280', 'zero': '20', 'drag': '0', 'sight': '3.5'};
    case 'sight-pin':
      return {'speed': '280', 'zero': '20', 'peep': '28'};
    case 'shot-angle':
    case 'distance-comp':
      return {'los': '40', 'angle': '30'};
    case 'velocity-loss':
      return {'speed': '280', 'dist': '40', 'drag': '0.08'};
    case 'downrange':
      return {'speed': '280', 'weight': '420', 'drag': '0.08'};
    case 'spine':
    case 'dynamic-spine':
    case 'spine-assistant':
    case 'spine-compound':
    case 'spine-recurve':
    case 'spine-traditional':
    case 'point-adj':
    case 'length-adj':
    case 'cam-adj':
      return {'draw': '55', 'length': '28', 'point': '125'};
    case 'static-spine':
    case 'spine-chart':
      return {};
    case 'xbow-speed':
    case 'xbow-ballistics':
      return {'ratedSpeed': '400', 'ratedWeight': '400', 'yourWeight': '450'};
    case 'xbow-weight':
      return {
        'shaft': '250',
        'point': '100',
        'nock': '10',
        'vanes': '30',
        'ratedSpeed': '400',
        'draw': '150',
      };
    case 'xbow-guide':
      return {'ratedSpeed': '400', 'draw': '150'};
    case 'converter':
      return {'kind': 'weight', 'value': '450'};
    default:
      return {};
  }
}

_FieldMap _defaultFields(String id) {
  final raw = _defaultFieldValues(id);
  return {
    for (final e in raw.entries) e.key: TextEditingController(text: e.value),
  };
}
