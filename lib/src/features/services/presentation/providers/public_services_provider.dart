import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/services/network_status_service.dart';
import 'package:solar_hub/src/features/auth/domain/entities/city.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/shared/domain/service_type.dart';
import 'package:solar_hub/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:solar_hub/src/features/services/domain/entities/public_companies_query.dart';
import 'package:solar_hub/src/features/services/domain/repositories/public_services_repository.dart';
import 'package:equatable/equatable.dart';

final publicServiceTypesProvider = FutureProvider<List<ServiceType>>((
  ref,
) async {
  return getIt<PublicServicesRepository>().getTypes();
});

class ServicesCompaniesState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<City> cities;
  final List<Company> companies;
  final ServiceType type;
  final PublicCompaniesQuery query;
  final int totalItems;

  const ServicesCompaniesState({
    this.isLoading = false,
    this.error,
    this.cities = const [],
    this.companies = const [],
    required this.type,
    this.query = const PublicCompaniesQuery(),
    this.totalItems = 0,
  });

  ServicesCompaniesState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<City>? cities,
    List<Company>? companies,
    ServiceType? type,
    PublicCompaniesQuery? query,
    int? totalItems,
  }) {
    return ServicesCompaniesState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      cities: cities ?? this.cities,
      companies: companies ?? this.companies,
      type: type ?? this.type,
      query: query ?? this.query,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    cities,
    companies,
    type,
    query,
    totalItems,
  ];
}

class ServicesCompaniesNotifier extends Notifier<ServicesCompaniesState> {
  final ServiceType type;

  ServicesCompaniesNotifier(this.type);

  late final PublicServicesRepository _repository;
  late final AuthRepository _authRepository;
  late final NetworkStatusService _networkStatus;
  Timer? _debounce;

  @override
  ServicesCompaniesState build() {
    _repository = getIt<PublicServicesRepository>();
    _authRepository = getIt<AuthRepository>();
    _networkStatus = getIt<NetworkStatusService>();

    ref.onDispose(() => _debounce?.cancel());
    Future.microtask(_initialize);

    return ServicesCompaniesState(
      type: type,
      query: PublicCompaniesQuery(serviceId: type.id == 0 ? null : type.id),
    );
  }

  Future<void> _initialize() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      List<City> cities = const [];
      try {
        cities = await _authRepository.getCities();
      } catch (_) {
        cities = const [];
      }

      final selectedCity = _resolveSelectedCity(cities);
      state = state.copyWith(
        cities: cities,
        query: state.query.copyWith(
          cityId: selectedCity?.id,
          clearCityId: selectedCity == null && cities.isNotEmpty,
        ),
      );
      await _fetchCompanies();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _networkStatus.userMessageFor(
          e,
          fallback: 'Could not load service companies.',
        ),
      );
    }
  }

  City? _resolveSelectedCity(List<City> cities) {
    final desiredId = state.query.cityId;
    if (desiredId == null) return null;
    for (final city in cities) {
      if (city.id == desiredId) return city;
    }
    return null;
  }

  Future<void> refresh() => _fetchCompanies();

  Future<void> selectCity(City? city) async {
    state = state.copyWith(
      query: state.query.copyWith(cityId: city?.id, clearCityId: city == null),
    );
    await _fetchCompanies();
  }

  void updateSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      state = state.copyWith(query: state.query.copyWith(search: value));
      unawaited(_fetchCompanies());
    });
  }

  Future<void> _fetchCompanies() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.getCompanies(state.query);
      state = state.copyWith(
        isLoading: false,
        companies: result.items,
        totalItems: result.count,
      );
      if (result.items.isNotEmpty) {}
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _networkStatus.userMessageFor(
          e,
          fallback: 'Could not load service companies.',
        ),
        companies: const [],
        totalItems: 0,
      );
    }
  }
}

final servicesCompaniesProvider =
    NotifierProvider.family<
      ServicesCompaniesNotifier,
      ServicesCompaniesState,
      ServiceType
    >(ServicesCompaniesNotifier.new);

final publicCompanyDetailsProvider = FutureProvider.family<Company, int>((
  ref,
  companyId,
) async {
  return getIt<PublicServicesRepository>().getCompanyDetails(companyId);
});
