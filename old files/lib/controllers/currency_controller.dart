import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/models/currency_model.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:solar_hub/utils/toast_service.dart';

class CurrencyController extends GetxController {
  final _dbService = SupabaseService();

  final currencies = <CurrencyModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrencies();
  }

  Future<void> fetchCurrencies() async {
    isLoading.value = true;
    try {
      final response = await _dbService.client.from('currencies').select().order('name', ascending: true);

      final List<CurrencyModel> loaded = [];
      for (var item in response) {
        loaded.add(CurrencyModel.fromJson(item));
      }
      currencies.assignAll(loaded);
    } catch (e) {
      debugPrint('Error fetching currencies: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createCurrency(CurrencyModel currency) async {
    try {
      isLoading.value = true;
      final json = currency.toJson();
      json.remove('id'); // DB generates ID

      // If setting as default, ensure others are not default (better handled in backend trigger, but doing here for now)
      if (currency.isDefault) {
        await _clearDefaults();
      }

      await _dbService.client.from('currencies').insert(json);
      await fetchCurrencies();
      return true;
    } catch (e) {
      debugPrint('Error creating currency: $e');
      ToastService.error('Error', 'Failed to create currency');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateCurrency(CurrencyModel currency) async {
    try {
      isLoading.value = true;
      final json = currency.toJson();

      if (currency.isDefault) {
        await _clearDefaults();
      }

      await _dbService.client.from('currencies').update(json).eq('id', currency.id);

      // Update local
      final index = currencies.indexWhere((c) => c.id == currency.id);
      if (index != -1) {
        currencies[index] = currency;
      }
      // Re-fetch to be safe about defaults
      if (currency.isDefault) await fetchCurrencies();

      return true;
    } catch (e) {
      debugPrint('Error updating currency: $e');
      ToastService.error('Error', 'Failed to update currency');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _clearDefaults() async {
    await _dbService.client.from('currencies').update({'is_default': false}).neq('id', '00000000-0000-0000-0000-000000000000'); // Valid UUID format mostly
  }

  Future<bool> deleteCurrency(String id) async {
    try {
      isLoading.value = true;
      await _dbService.client.from('currencies').delete().eq('id', id);
      currencies.removeWhere((c) => c.id == id);
      return true;
    } catch (e) {
      debugPrint('Error deleting currency: $e');
      ToastService.error('Error', 'Failed to delete currency');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  CurrencyModel? get defaultCurrency => currencies.firstWhereOrNull((c) => c.isDefault);

  CurrencyModel? getCurrencyById(String? id) {
    if (id == null) return defaultCurrency;
    return currencies.firstWhereOrNull((c) => c.id == id) ?? defaultCurrency;
  }
}
