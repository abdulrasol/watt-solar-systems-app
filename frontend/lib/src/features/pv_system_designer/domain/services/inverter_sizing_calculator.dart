import 'dart:math' as math;

import 'package:solar_hub/src/features/pv_system_designer/domain/entities/inverter_spec.dart';

/// Validates a DC panel array against an inverter's MPPT voltage window and
/// max input current, and estimates a sensible series/parallel string
/// layout automatically — the kind of check a real design tool must do
/// before a layout can be considered installable, which this feature did
/// not previously perform at all.
///
/// Simplification note: Voc-at-cold and Vmp-at-hot are estimated from a
/// single linear temperature coefficient applied to STC (25°C) ratings,
/// which is the standard simplified approach used by most sizing
/// calculators. For a bankable/permit-ready design, always confirm against
/// the exact inverter and module datasheets.
class InverterSizingCalculator {
  const InverterSizingCalculator();

  static const double _defaultVocTempCoeffPercentPerC = -0.29;
  static const double _defaultVmpTempCoeffPercentPerC = -0.38;
  static const double _stcTempC = 25.0;

  StringSizingResult calculate({
    required InverterSpec inverter,
    required int panelCount,
    required double panelVocV,
    required double panelVmpV,
    required double panelIscA,
    required double coldDesignTempC,
    required double hotDesignTempC,
    /// The array's STC nameplate DC size in kW (e.g. `panelCount *
    /// panelPowerW / 1000`), supplied by the caller since it already
    /// knows the real per-panel wattage — used for the DC:AC ratio check.
    required double dcArrayKw,
    double? vocTempCoeffPercentPerC,
    double? vmpTempCoeffPercentPerC,
  }) {
    final vocCoeff = vocTempCoeffPercentPerC ?? _defaultVocTempCoeffPercentPerC;
    final vmpCoeff = vmpTempCoeffPercentPerC ?? _defaultVmpTempCoeffPercentPerC;

    final vocAtCold = panelVocV * (1 + (vocCoeff / 100.0) * (coldDesignTempC - _stcTempC));
    final vmpAtHot = panelVmpV * (1 + (vmpCoeff / 100.0) * (hotDesignTempC - _stcTempC));

    // Longest series string that still keeps cold-Voc under the inverter's
    // max DC input voltage, and at least keeps hot-Vmp inside the MPPT
    // window's lower bound.
    final maxPanelsByVoc = vocAtCold > 0 ? (inverter.maxDcInputVoltage / vocAtCold).floor() : 0;
    final minPanelsByMppt = vmpAtHot > 0 ? (inverter.mpptMinVoltage / vmpAtHot).ceil() : 0;
    final maxPanelsByMppt = vmpAtHot > 0 ? (inverter.mpptMaxVoltage / vmpAtHot).floor() : 0;

    int panelsPerString = maxPanelsByMppt.clamp(1, math.max(1, maxPanelsByVoc)).toInt();
    if (panelsPerString < minPanelsByMppt) panelsPerString = minPanelsByMppt;
    if (panelsPerString < 1) panelsPerString = 1;

    final maxStringCapacity = inverter.mpptCount * inverter.maxStringsPerMppt;
    int parallelStrings = panelsPerString > 0 ? (panelCount / panelsPerString).ceil() : 0;
    final warnings = <String>[];
    if (parallelStrings > maxStringCapacity) {
      warnings.add(
        'Array needs $parallelStrings strings but this inverter supports at most $maxStringCapacity '
        '(${inverter.mpptCount} MPPT × ${inverter.maxStringsPerMppt} strings) — choose a larger inverter or split the array.',
      );
      parallelStrings = maxStringCapacity;
    }

    final stringVocAtCold = panelsPerString * vocAtCold;
    final stringVmpAtHot = panelsPerString * vmpAtHot;
    final stringIsc = panelIscA;

    final vocWithinLimit = stringVocAtCold <= inverter.maxDcInputVoltage;
    final vmpWithinMpptWindow = stringVmpAtHot >= inverter.mpptMinVoltage && stringVmpAtHot <= inverter.mpptMaxVoltage;

    final stringsPerMppt = inverter.mpptCount > 0 ? (parallelStrings / inverter.mpptCount).ceil() : parallelStrings;
    final currentPerMppt = stringsPerMppt * stringIsc;
    final currentWithinLimit = currentPerMppt <= inverter.maxInputCurrentPerMppt;

    final dcAcRatio = inverter.ratedAcPowerKw > 0 ? dcArrayKw / inverter.ratedAcPowerKw : 0.0;
    final dcAcRatioReasonable = dcAcRatio >= 1.0 && dcAcRatio <= 1.35;

    if (!vocWithinLimit) {
      warnings.add(
        'String Voc at ${coldDesignTempC.toStringAsFixed(0)}°C (${stringVocAtCold.toStringAsFixed(0)} V) exceeds the inverter\'s '
        'max DC input voltage (${inverter.maxDcInputVoltage.toStringAsFixed(0)} V) — reduce panels per string.',
      );
    }
    if (!vmpWithinMpptWindow) {
      warnings.add(
        'String Vmp at ${hotDesignTempC.toStringAsFixed(0)}°C (${stringVmpAtHot.toStringAsFixed(0)} V) falls outside the MPPT window '
        '(${inverter.mpptMinVoltage.toStringAsFixed(0)}–${inverter.mpptMaxVoltage.toStringAsFixed(0)} V) — adjust panels per string.',
      );
    }
    if (!currentWithinLimit) {
      warnings.add(
        'Combined string current per MPPT (${currentPerMppt.toStringAsFixed(1)} A) exceeds the inverter\'s limit '
        '(${inverter.maxInputCurrentPerMppt.toStringAsFixed(1)} A) — use fewer parallel strings per MPPT or a larger inverter.',
      );
    }
    if (!dcAcRatioReasonable) {
      warnings.add(
        'DC:AC ratio is ${dcAcRatio.toStringAsFixed(2)} — typical designs target 1.0–1.35; outside this range the array may be '
        'significantly under- or over-sized relative to the inverter, or you may see heavy inverter clipping.',
      );
    }

    return StringSizingResult(
      inverter: inverter,
      panelsPerString: panelsPerString,
      parallelStrings: parallelStrings,
      stringVocAtColdTemp: stringVocAtCold,
      stringVmpAtHotTemp: stringVmpAtHot,
      stringIscA: stringIsc,
      dcArrayKw: dcArrayKw,
      dcAcRatio: dcAcRatio,
      vocWithinLimit: vocWithinLimit,
      vmpWithinMpptWindow: vmpWithinMpptWindow,
      currentWithinLimit: currentWithinLimit,
      dcAcRatioReasonable: dcAcRatioReasonable,
      warnings: warnings,
    );
  }
}
