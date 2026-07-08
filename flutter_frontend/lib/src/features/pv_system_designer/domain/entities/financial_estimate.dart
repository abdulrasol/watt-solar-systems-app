import 'package:flutter/foundation.dart';

/// A simple financial summary (cost, annual savings, payback, lifetime
/// savings) for the designed system — the app previously showed energy
/// production numbers with no way to answer "is this worth it?".
@immutable
class FinancialEstimate {
  final double systemCost;
  final double annualSavings;
  final double? paybackYears;
  final double lifetimeSavings;
  final int lifetimeYears;
  final double costPerWatt;
  final double electricityRatePerKwh;

  const FinancialEstimate({
    required this.systemCost,
    required this.annualSavings,
    required this.paybackYears,
    required this.lifetimeSavings,
    required this.lifetimeYears,
    required this.costPerWatt,
    required this.electricityRatePerKwh,
  });

  factory FinancialEstimate.empty() => const FinancialEstimate(
        systemCost: 0,
        annualSavings: 0,
        paybackYears: null,
        lifetimeSavings: 0,
        lifetimeYears: 25,
        costPerWatt: 0,
        electricityRatePerKwh: 0,
      );
}
