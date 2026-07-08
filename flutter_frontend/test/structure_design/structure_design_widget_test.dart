import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/features/calculations/presentation/screens/calculator_landing_page.dart';
import 'package:watt/src/features/structure_design/data/location_service.dart';
import 'package:watt/src/features/structure_design/presentation/providers/structure_design_controller.dart';
import 'package:watt/src/features/structure_design/presentation/screens/structure_design_screen.dart';

class _FakeLocationService implements LocationService {
  _FakeLocationService({this.error});

  final Object? error;

  @override
  Future<double> getCurrentLatitude() async {
    if (error != null) {
      throw error!;
    }
    return 33.3;
  }

  @override
  Future<GeoLocation> getCurrentLocation() async {
    if (error != null) {
      throw error!;
    }
    return const GeoLocation(latitude: 33.3, longitude: -117.5);
  }

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.whileInUse;
}

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this.path);

  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  late Directory storageDirectory;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    storageDirectory = Directory.systemTemp.createTempSync(
      'solar_hub_structure_test_',
    );
    PathProviderPlatform.instance = _FakePathProviderPlatform(
      storageDirectory.path,
    );
    await GetStorage.init();
  });

  tearDownAll(() {
    if (storageDirectory.existsSync()) {
      storageDirectory.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    await GetStorage().erase();
    await GetStorage().write('structure_design_wizard_help_viewed', true);
  });

  Future<void> pumpTestApp(
    WidgetTester tester,
    Widget child, {
    List<dynamic> overrides = const [],
  }) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, childWidget) {
          return ProviderScope(
            overrides: overrides.cast(),
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('ar')],
              locale: const Locale('en'),
              home: child,
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('structural tool appears on calculator landing page', (
    tester,
  ) async {
    await pumpTestApp(tester, const CalculatorLandingPage());

    expect(find.text('Structure Design'), findsOneWidget);
  });

  testWidgets('wizard renders all 3 steps', (tester) async {
    await pumpTestApp(tester, const StructureDesignScreen());

    expect(find.text('Site'), findsOneWidget);
    expect(find.text('Panels'), findsOneWidget);
    expect(find.text('Results'), findsOneWidget);
    expect(find.byKey(const Key('open_watt_drawing_button')), findsOneWidget);
  });

  testWidgets('input form validates required dimensions', (tester) async {
    await pumpTestApp(tester, const StructureDesignScreen());

    await tester.enterText(find.byKey(const Key('site_width_field')), '0');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a value greater than zero'), findsOneWidget);
  });

  testWidgets('first-time help dialog appears with structure guide key', (
    tester,
  ) async {
    await GetStorage().write('structure_design_wizard_help_viewed', false);
    await pumpTestApp(tester, const StructureDesignScreen());

    expect(find.text('Guide'), findsOneWidget);
  });

  testWidgets('results render geometry cards and sketch', (tester) async {
    await pumpTestApp(tester, const StructureDesignScreen());
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calculate'));
    await tester.pumpAndSettle();

    expect(find.text('Geometry Results'), findsOneWidget);
    expect(find.byKey(const Key('structure_sketch')), findsOneWidget);
    expect(find.text('Estimated BOM'), findsOneWidget);
    expect(find.text('Total steel length'), findsOneWidget);
    expect(find.byKey(const Key('save_watt_drawing_button')), findsOneWidget);
    expect(find.text('Save Watt Drawing'), findsWidgets);
  });

  testWidgets('results screen shows view full sketch button', (tester) async {
    await pumpTestApp(tester, const StructureDesignScreen());
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calculate'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('view_full_sketch_button')), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
  });

  testWidgets('tapping full sketch button opens full viewer', (tester) async {
    await pumpTestApp(tester, const StructureDesignScreen());
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calculate'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('view_full_sketch_button')),
    );
    await tester.tap(find.byKey(const Key('view_full_sketch_button')));
    await tester.pumpAndSettle();

    expect(find.text('Full Sketch'), findsOneWidget);
    expect(find.byKey(const Key('full_structure_sketch')), findsOneWidget);
    expect(find.text('Geometry dimensions'), findsOneWidget);
    expect(find.text('Total steel length'), findsWidgets);
  });

  testWidgets('switching row mode changes visible hint and stepped results', (
    tester,
  ) async {
    await pumpTestApp(tester, const StructureDesignScreen());
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('repeated frame on flat ground'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byKey(const Key('row_mode_field')));
    await tester.tap(find.byKey(const Key('row_mode_field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stepped rows'));
    await tester.pumpAndSettle();
    expect(find.textContaining('different support heights'), findsOneWidget);

    await tester.tap(find.text('Calculate'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('stepped_row_results')), findsOneWidget);
  });

  testWidgets('independent mode shows uniform leg explanation', (tester) async {
    await pumpTestApp(tester, const StructureDesignScreen());
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calculate'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('uniform_leg_explanation')), findsWidgets);
  });

  testWidgets(
    'full viewer shows repeated-frame messaging in independent mode',
    (tester) async {
      await pumpTestApp(tester, const StructureDesignScreen());
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calculate'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('view_full_sketch_button')),
      );
      await tester.tap(find.byKey(const Key('view_full_sketch_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('full_sketch_repeated_note')),
        findsOneWidget,
      );
    },
  );

  testWidgets('location unavailable falls back to manual latitude cleanly', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      const StructureDesignScreen(),
      overrides: [
        structureLocationServiceProvider.overrideWithValue(
          _FakeLocationService(
            error: const LocationException('Manual latitude only'),
          ),
        ),
      ],
    );

    await tester.ensureVisible(find.text('Use location'));
    await tester.tap(find.text('Use location'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('location_message')), findsOneWidget);
    expect(find.textContaining('Manual latitude only'), findsOneWidget);
  });
}
