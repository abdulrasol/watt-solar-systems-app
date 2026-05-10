import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_city.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_country.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/admin_repository.dart';


class AdminAddressState {
  final bool isCountriesLoading;
  final bool isCitiesLoading;
  final bool isMoreCitiesLoading;
  final bool hasMoreCities;
  final String? error;
  final List<AdminCountry> countries;
  final List<AdminCity> cities;
  final int cityPage;

  AdminAddressState({
    this.isCountriesLoading = false,
    this.isCitiesLoading = false,
    this.isMoreCitiesLoading = false,
    this.hasMoreCities = true,
    this.error,
    this.countries = const [],
    this.cities = const [],
    this.cityPage = 1,
  });

  AdminAddressState copyWith({
    bool? isCountriesLoading,
    bool? isCitiesLoading,
    bool? isMoreCitiesLoading,
    bool? hasMoreCities,
    String? error,
    List<AdminCountry>? countries,
    List<AdminCity>? cities,
    int? cityPage,
  }) {
    return AdminAddressState(
      isCountriesLoading: isCountriesLoading ?? this.isCountriesLoading,
      isCitiesLoading: isCitiesLoading ?? this.isCitiesLoading,
      isMoreCitiesLoading: isMoreCitiesLoading ?? this.isMoreCitiesLoading,
      hasMoreCities: hasMoreCities ?? this.hasMoreCities,
      error: error ?? this.error,
      countries: countries ?? this.countries,
      cities: cities ?? this.cities,
      cityPage: cityPage ?? this.cityPage,
    );
  }
}

class AdminAddressController extends Notifier<AdminAddressState> {
  late AdminRepository _repository;

  @override
  AdminAddressState build() {
    _repository = getIt<AdminRepository>();
    return AdminAddressState();
  }

  Future<void> fetchCountries() async {
    state = state.copyWith(isCountriesLoading: true, error: null);
    try {
      final countries = await _repository.listCountries(pageSize: 100); // Usually not many countries
      state = state.copyWith(isCountriesLoading: false, countries: countries);
    } catch (e) {
      state = state.copyWith(isCountriesLoading: false, error: e.toString());
    }
  }

  Future<void> fetchCities({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isCitiesLoading: true,
        hasMoreCities: true,
        cityPage: 1,
        error: null,
        cities: [],
      );
    } else {
      if (state.isMoreCitiesLoading || !state.hasMoreCities) return;
      state = state.copyWith(isMoreCitiesLoading: true, error: null);
    }

    try {
      final cities = await _repository.listCities(
        page: state.cityPage,
        pageSize: 12,
      );
      state = state.copyWith(
        isCitiesLoading: false,
        isMoreCitiesLoading: false,
        cities: isRefresh ? cities : [...state.cities, ...cities],
        hasMoreCities: cities.length >= 12,
      );
    } catch (e) {
      state = state.copyWith(isCitiesLoading: false, isMoreCitiesLoading: false, error: e.toString());
    }
  }

  Future<void> fetchNextCitiesPage() async {
    if (state.isMoreCitiesLoading || !state.hasMoreCities) return;
    state = state.copyWith(cityPage: state.cityPage + 1);
    await fetchCities();
  }

  // Country CRUD
  Future<void> createCountry(Map<String, dynamic> data) async {
    try {
      final newCountry = await _repository.createCountry(data);
      state = state.copyWith(countries: [newCountry, ...state.countries]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateCountry(int id, Map<String, dynamic> data) async {
    try {
      final updatedCountry = await _repository.updateCountry(id, data);
      state = state.copyWith(
        countries: state.countries.map((c) => c.id == id ? updatedCountry : c).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // City CRUD
  Future<void> createCity(Map<String, dynamic> data) async {
    try {
      final newCity = await _repository.createCity(data);
      state = state.copyWith(cities: [newCity, ...state.cities]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateCity(int id, Map<String, dynamic> data) async {
    try {
      final updatedCity = await _repository.updateCity(id, data);
      state = state.copyWith(
        cities: state.cities.map((c) => c.id == id ? updatedCity : c).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteCity(int id) async {
    try {
      await _repository.deleteCity(id);
      state = state.copyWith(
        cities: state.cities.where((c) => c.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final adminAddressProvider = NotifierProvider<AdminAddressController, AdminAddressState>(() {
  return AdminAddressController();
});
