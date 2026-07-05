import 'package:solar_hub/src/features/pv_system_designer/domain/entities/financial_estimate.dart';

/// Simple payback/ROI estimate for a designed system. Deliberately kept to
/// the handful of inputs a homeowner actually has at design time (cost,
/// local electricity rate) rather than a full cash-flow/financing model —
/// the goal is answering "roughly how many years until this pays for
/// itself", which the app previously couldn't answer at all.
class FinancialCalculator {
  const FinancialCalculator();

  FinancialEstimate estimate({
    required double firstYearKwh,
    required double annualDegradationPercent,
    required double systemCost,
    required double electricityRatePerKwh,
    int lifetimeYears = 25,
  }) {
    if (systemCost <= 0 || firstYearKwh <= 0 || electricityRatePerKwh <= 0) {
      return FinancialEstimate.empty().copyWithCost(systemCost, electricityRatePerKwh);
    }

    final degradation = annualDegradationPercent / 100.0;
    double cumulativeSavings = 0;
    double? paybackYears;
    double lifetimeSavings = 0;

    for (int year = 0; year < lifetimeYears; year++) {
      final yearKwh = firstYearKwh * (1 - degradation * year).clamp(0.0, 1.0);
      final yearSavings = yearKwh * electricityRatePerKwh;
      lifetimeSavings += yearSavings;

      if (paybackYears == null) {
        final before = cumulativeSavings;
        cumulativeSavings += yearSavings;
        if (cumulativeSavings >= systemCost) {
          // Linear interpolation within this year for a smoother estimate.
          final remaining = systemCost - before;
          final double fraction = yearSavings > 0 ? (remaining / yearSavings).clamp(0.0, 1.0).toDouble() : 1.0;
          paybackYears = year + fraction;
        }
      }
    }

    final annualSavingsYear1 = firstYearKwh * electricityRatePerKwh;

    return FinancialEstimate(
      systemCost: systemCost,
      annualSavings: annualSavingsYear1,
      paybackYears: paybackYears,
      lifetimeSavings: lifetimeSavings - systemCost,
      lifetimeYears: lifetimeYears,
      costPerWatt: 0,
      electricityRatePerKwh: electricityRatePerKwh,
    );
  }
}

extension on FinancialEstimate {
  FinancialEstimate copyWithCost(double cost, double rate) => FinancialEstimate(
        systemCost: cost,
        annualSavings: annualSavings,
        paybackYears: paybackYears,
        lifetimeSavings: lifetimeSavings,
        lifetimeYears: lifetimeYears,
        costPerWatt: costPerWatt,
        electricityRatePerKwh: rate,
      );
}
