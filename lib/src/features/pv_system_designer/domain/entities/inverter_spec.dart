import 'package:flutter/foundation.dart';

/// A simplified string-inverter datasheet, holding just the fields needed
/// to validate a DC array design against the inverter's electrical limits
/// (MPPT voltage window, max input current, max DC input voltage) and to
/// estimate the DC:AC ratio.
@immutable
class InverterSpec {
  final String id;
  final String name;
  final double ratedAcPowerKw;
  final int mpptCount;
  final int maxStringsPerMppt;
  final double maxDcInputVoltage;
  final double mpptMinVoltage;
  final double mpptMaxVoltage;
  final double maxInputCurrentPerMppt;

  const InverterSpec({
    required this.id,
    required this.name,
    required this.ratedAcPowerKw,
    required this.mpptCount,
    required this.maxStringsPerMppt,
    required this.maxDcInputVoltage,
    required this.mpptMinVoltage,
    required this.mpptMaxVoltage,
    required this.maxInputCurrentPerMppt,
  });
}

/// Result of checking a proposed array/string configuration against an
/// [InverterSpec]'s electrical limits.
class StringSizingResult {
  const StringSizingResult({
    required this.inverter,
    required this.panelsPerString,
    required this.parallelStrings,
    required this.stringVocAtColdTemp,
    required this.stringVmpAtHotTemp,
    required this.stringIscA,
    required this.dcArrayKw,
    required this.dcAcRatio,
    required this.vocWithinLimit,
    required this.vmpWithinMpptWindow,
    required this.currentWithinLimit,
    required this.dcAcRatioReasonable,
    required this.warnings,
  });

  final InverterSpec inverter;
  final int panelsPerString;
  final int parallelStrings;
  final double stringVocAtColdTemp;
  final double stringVmpAtHotTemp;
  final double stringIscA;
  final double dcArrayKw;
  final double dcAcRatio;
  final bool vocWithinLimit;
  final bool vmpWithinMpptWindow;
  final bool currentWithinLimit;
  final bool dcAcRatioReasonable;
  final List<String> warnings;

  bool get isFullyCompliant => vocWithinLimit && vmpWithinMpptWindow && currentWithinLimit;
}
