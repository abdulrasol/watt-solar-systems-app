import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/services/presentation/widgets/company_type_card.dart';
import 'package:solar_hub/src/shared/domain/service_type.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

void main() {
  testWidgets('renders narrow Arabic card without flex overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final previousOnError = FlutterError.onError;
    final reportedErrors = <FlutterErrorDetails>[];
    FlutterError.onError = reportedErrors.add;
    addTearDown(() {
      FlutterError.onError = previousOnError;
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ar'), Locale('en')],
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: SizedBox.square(
                  dimension: 177.7,
                  child: CompanyTypeCard(
                    type: const ServiceType(
                      id: 1,
                      name: 'حداد الواح شمسية',
                      description: 'حداد الواح شمسية',
                    ),
                    onTap: () {},
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    FlutterError.onError = previousOnError;
    expect(tester.takeException(), isNull);
    expect(
      reportedErrors.where(
        (details) =>
            details.exceptionAsString().contains('RenderFlex overflowed'),
      ),
      isEmpty,
    );
  });
}
