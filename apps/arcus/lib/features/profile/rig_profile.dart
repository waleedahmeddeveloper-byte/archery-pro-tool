import 'dart:convert';

import 'package:archery_engine/archery_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Saved bow + arrow setup used by Setup Assistant and calculators.
class RigProfile {
  const RigProfile({
    required this.name,
    required this.bowType,
    required this.camStyle,
    required this.drawWeightPounds,
    required this.drawLengthInches,
    required this.iboFps,
    required this.letOffPercent,
    required this.gpi,
    required this.shaftLengthInches,
    required this.pointGrains,
    required this.insertGrains,
    required this.collarGrains,
    required this.nockGrains,
    required this.wrapGrains,
    required this.vaneGrainsEach,
    this.vaneCount = 3,
  });

  final String name;
  final BowType bowType;
  final CamStyle camStyle;
  final double drawWeightPounds;
  final double drawLengthInches;
  final double iboFps;
  final double letOffPercent;
  final double gpi;
  final double shaftLengthInches;
  final double pointGrains;
  final double insertGrains;
  final double collarGrains;
  final double nockGrains;
  final double wrapGrains;
  final double vaneGrainsEach;
  final int vaneCount;

  ArrowComponents get components => ArrowComponents(
        gpi: gpi,
        shaftLengthInches: shaftLengthInches,
        pointGrains: pointGrains,
        insertGrains: insertGrains,
        outsertOrCollarGrains: collarGrains,
        nockGrains: nockGrains,
        wrapGrains: wrapGrains,
        vaneGrainsEach: vaneGrainsEach,
        vaneCount: vaneCount,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'bowType': bowType.name,
        'camStyle': camStyle.name,
        'drawWeightPounds': drawWeightPounds,
        'drawLengthInches': drawLengthInches,
        'iboFps': iboFps,
        'letOffPercent': letOffPercent,
        'gpi': gpi,
        'shaftLengthInches': shaftLengthInches,
        'pointGrains': pointGrains,
        'insertGrains': insertGrains,
        'collarGrains': collarGrains,
        'nockGrains': nockGrains,
        'wrapGrains': wrapGrains,
        'vaneGrainsEach': vaneGrainsEach,
        'vaneCount': vaneCount,
      };

  factory RigProfile.fromJson(Map<String, dynamic> json) {
    BowType bow = BowType.compound;
    for (final v in BowType.values) {
      if (v.name == json['bowType']) bow = v;
    }
    CamStyle cam = CamStyle.standard;
    for (final v in CamStyle.values) {
      if (v.name == json['camStyle']) cam = v;
    }
    return RigProfile(
      name: json['name'] as String? ?? 'Saved rig',
      bowType: bow,
      camStyle: cam,
      drawWeightPounds: (json['drawWeightPounds'] as num).toDouble(),
      drawLengthInches: (json['drawLengthInches'] as num).toDouble(),
      iboFps: (json['iboFps'] as num).toDouble(),
      letOffPercent: (json['letOffPercent'] as num?)?.toDouble() ?? 80,
      gpi: (json['gpi'] as num).toDouble(),
      shaftLengthInches: (json['shaftLengthInches'] as num).toDouble(),
      pointGrains: (json['pointGrains'] as num).toDouble(),
      insertGrains: (json['insertGrains'] as num?)?.toDouble() ?? 0,
      collarGrains: (json['collarGrains'] as num?)?.toDouble() ?? 0,
      nockGrains: (json['nockGrains'] as num?)?.toDouble() ?? 0,
      wrapGrains: (json['wrapGrains'] as num?)?.toDouble() ?? 0,
      vaneGrainsEach: (json['vaneGrainsEach'] as num?)?.toDouble() ?? 0,
      vaneCount: (json['vaneCount'] as num?)?.toInt() ?? 3,
    );
  }
}

class RigProfileStore {
  RigProfileStore({SharedPreferences? prefs}) : _prefs = prefs;

  static const prefsKey = 'arcus_active_rig_profile_v1';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensure() async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<void> save(RigProfile profile) async {
    final prefs = await _ensure();
    await prefs.setString(prefsKey, jsonEncode(profile.toJson()));
  }

  Future<RigProfile?> load() async {
    final prefs = await _ensure();
    final raw = prefs.getString(prefsKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return RigProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await _ensure();
    await prefs.remove(prefsKey);
  }
}
