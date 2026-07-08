import 'package:flutter_test/flutter_test.dart';
import 'package:solar_hub/src/features/calculations/domain/entities/calculated_system.dart';

void main() {
  test('parseCalculatedSystems ignores malformed cache entries', () {
    final raw = [
      {
        'id': '1',
        'title': 'System 1',
        'date': '2026-01-01T00:00:00.000Z',
        'appliances': const [],
        'dailyUsageKWh': 1.2,
        'recommendedPanels': 2,
        'totalPanelCapacityKw': 1.1,
        'totalBatteryCapacityAh': '100Ah @ 12V',
        'recommendedInverterSize': 2.0,
        'recommendedBatteries': 1,
        'recommendedControllerSize': 10,
        'peakLoadW': 300.0,
        'acSystemVoltage': 230.0,
        'acLoadCurrent': 1.3,
        'systemCalcSingleBatteryVoltage': 12.0,
        'batteryUnitCapacityAh': 100.0,
        'pvDerating': 0.78,
        'inverterSafetyFactor': 1.3,
        'systemBatteryType': 'lithium',
        'batterySeriesCount': 1,
        'batteryParallelCount': 1,
        'requiredBatteryAh': 100.0,
        'requiredBatteryKWh': 1.2,
        'practicalBatteryNeedKWh': 1.0,
        'effectiveBatteryNeedWh': 900.0,
        'averageLoadW': 120.0,
        'gridCoverageFactor': 1.0,
        'gridCycleHours': 0.0,
        'calculationMode': 'fullEnergy',
        'loadInputUnit': 'ampere',
        'directAcLoadInput': 10.0,
        'gridOnHours': 2.0,
        'gridOffHours': 4.0,
        'rechargePercentage': 0.0,
        'batteryReservePercent': 20.0,
        'autonomyHours': 4.0,
        'sunPeakHours': 5.0,
        'systemVoltage': 12.0,
      },
      'bad-entry',
      {'id': 'broken'},
    ];

    final systems = parseCalculatedSystems(raw);

    expect(systems, hasLength(1));
    expect(systems.single.id, '1');
  });
}
