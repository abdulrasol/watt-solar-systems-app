import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/services/domain/entities/public_companies_query.dart';
import 'package:solar_hub/src/features/services/domain/entities/public_companies_result.dart';
import 'package:solar_hub/src/features/services/domain/repositories/public_services_repository.dart';
import 'package:solar_hub/src/features/services/presentation/screens/company_details_screen.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/shared/domain/service_type.dart';

void main() {
  late _ThrowingPublicServicesRepository repository;

  setUp(() async {
    repository = _ThrowingPublicServicesRepository();
    await getIt.reset();
    getIt.registerSingleton<PublicServicesRepository>(repository);
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('company details error state can be pulled to refresh', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return const ProviderScope(
            child: MaterialApp(home: CompanyDetailsScreen(companyId: 42)),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    final callsBeforeRefresh = repository.getCompanyDetailsCalls;
    expect(callsBeforeRefresh, greaterThan(0));
    expect(find.byType(RefreshIndicator), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 500));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(repository.getCompanyDetailsCalls, greaterThan(callsBeforeRefresh));
  });
}

class _ThrowingPublicServicesRepository implements PublicServicesRepository {
  int getCompanyDetailsCalls = 0;

  @override
  Future<List<ServiceType>> getTypes({bool forceRefresh = false}) {
    throw UnimplementedError();
  }

  @override
  Future<PublicCompaniesResult> getCompanies(PublicCompaniesQuery query) {
    throw UnimplementedError();
  }

  @override
  Future<Company> getCompanyDetails(int companyId) async {
    getCompanyDetailsCalls += 1;
    throw Exception('Could not load company details');
  }
}
