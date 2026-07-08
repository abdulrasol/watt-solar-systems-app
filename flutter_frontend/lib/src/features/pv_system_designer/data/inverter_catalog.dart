import 'package:watt/src/features/pv_system_designer/domain/entities/inverter_spec.dart';

/// A small built-in catalog of common string/hybrid inverter power classes
/// with representative electrical limits, used to give users a real
/// starting point for string-sizing compliance checks without requiring a
/// full product database. Values are typical for each power class (based
/// on commonly available residential/commercial hybrid inverters) rather
/// than a specific manufacturer's exact datasheet — good enough to catch
/// gross sizing mistakes, not a substitute for the installer's final
/// datasheet check against the actual selected inverter.
class InverterCatalog {
  static const List<InverterSpec> all = [
    InverterSpec(
      id: 'gen_3kw',
      name: '3 kW Hybrid Inverter',
      ratedAcPowerKw: 3.0,
      mpptCount: 1,
      maxStringsPerMppt: 2,
      maxDcInputVoltage: 500,
      mpptMinVoltage: 90,
      mpptMaxVoltage: 450,
      maxInputCurrentPerMppt: 16,
    ),
    InverterSpec(
      id: 'gen_5kw',
      name: '5 kW Hybrid Inverter',
      ratedAcPowerKw: 5.0,
      mpptCount: 2,
      maxStringsPerMppt: 2,
      maxDcInputVoltage: 550,
      mpptMinVoltage: 90,
      mpptMaxVoltage: 500,
      maxInputCurrentPerMppt: 16,
    ),
    InverterSpec(
      id: 'gen_8kw',
      name: '8 kW Hybrid Inverter',
      ratedAcPowerKw: 8.0,
      mpptCount: 2,
      maxStringsPerMppt: 2,
      maxDcInputVoltage: 600,
      mpptMinVoltage: 120,
      mpptMaxVoltage: 550,
      maxInputCurrentPerMppt: 18,
    ),
    InverterSpec(
      id: 'gen_10kw',
      name: '10 kW Hybrid Inverter',
      ratedAcPowerKw: 10.0,
      mpptCount: 2,
      maxStringsPerMppt: 3,
      maxDcInputVoltage: 1000,
      mpptMinVoltage: 150,
      mpptMaxVoltage: 850,
      maxInputCurrentPerMppt: 20,
    ),
    InverterSpec(
      id: 'gen_15kw',
      name: '15 kW Three-Phase Inverter',
      ratedAcPowerKw: 15.0,
      mpptCount: 3,
      maxStringsPerMppt: 3,
      maxDcInputVoltage: 1000,
      mpptMinVoltage: 200,
      mpptMaxVoltage: 850,
      maxInputCurrentPerMppt: 22,
    ),
    InverterSpec(
      id: 'gen_25kw',
      name: '25 kW Three-Phase Inverter',
      ratedAcPowerKw: 25.0,
      mpptCount: 4,
      maxStringsPerMppt: 3,
      maxDcInputVoltage: 1100,
      mpptMinVoltage: 200,
      mpptMaxVoltage: 950,
      maxInputCurrentPerMppt: 26,
    ),
    InverterSpec(
      id: 'gen_50kw',
      name: '50 kW Three-Phase Inverter',
      ratedAcPowerKw: 50.0,
      mpptCount: 4,
      maxStringsPerMppt: 4,
      maxDcInputVoltage: 1100,
      mpptMinVoltage: 200,
      mpptMaxVoltage: 950,
      maxInputCurrentPerMppt: 30,
    ),
  ];

  /// Picks a reasonable default inverter for a given DC array size, aiming
  /// for a DC:AC ratio close to 1.15 (a common rule-of-thumb starting
  /// point) — purely a convenience default; the user can pick any other
  /// catalog entry.
  static InverterSpec suggestFor(double dcArrayKw) {
    if (dcArrayKw <= 0) return all.first;
    InverterSpec best = all.first;
    double bestScore = double.infinity;
    for (final inverter in all) {
      final ratio = dcArrayKw / inverter.ratedAcPowerKw;
      final score = (ratio - 1.15).abs();
      if (score < bestScore) {
        bestScore = score;
        best = inverter;
      }
    }
    return best;
  }

  static InverterSpec byId(String id) => all.firstWhere((i) => i.id == id, orElse: () => all.first);
}
