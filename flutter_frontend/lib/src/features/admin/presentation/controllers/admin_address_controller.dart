import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/src/core/di/get_it.dart';
import 'package:watt/src/features/admin/domain/models/admin_city.dart';
import 'package:watt/src/features/admin/domain/models/admin_country.dart';
import 'package:watt/src/features/admin/domain/repositories/admin_repository.dart';


class AdminAddressState {
  final bool isCountriesLoading;
  final bool isCitiesLoading;
  final String? error;
  final List<AdminCountry> countries;
  final List<AdminCity> cities;

  AdminAddressState({
    this.isCountriesLoading = false,
    this.isCitiesLoading = false,
    this.error,
    this.countries = const [],
    this.cities = const [],
  });

  AdminAddressState copyWith({
    bool? isCountriesLoading,
    bool? isCitiesLoading,
    String? error,
    List<AdminCountry>? countries,
    List<AdminCity>? cities,
  }) {
    return AdminAddressState(
      isCountriesLoading: isCountriesLoading ?? this.isCountriesLoading,
      isCitiesLoading: isCitiesLoading ?? this.isCitiesLoading,
      error: error ?? this.error,
      countries: countries ?? this.countries,
      cities: cities ?? this.cities,
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
      final countries = await _repository.listCountries(); 
      state = state.copyWith(isCountriesLoading: false, countries: countries);
    } catch (e) {
      state = state.copyWith(isCountriesLoading: false, error: e.toString());
    }
  }

  Future<void> fetchCities({int? countryId}) async {
    state = state.copyWith(isCitiesLoading: true, error: null);

    try {
      final cities = await _repository.listCities(countryId: countryId);
      state = state.copyWith(
        isCitiesLoading: false,
        cities: cities,
      );
    } catch (e) {
      state = state.copyWith(isCitiesLoading: false, error: e.toString());
    }
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

  Future<void> deleteCountry(int id) async {
    try {
      await _repository.deleteCountry(id);
      state = state.copyWith(
        countries: state.countries.where((c) => c.id != id).toList(),
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
