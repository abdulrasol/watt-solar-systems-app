import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/store/models/delivery_option_model.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:solar_hub/utils/toast_service.dart';

class DeliveryOptionsController extends GetxController {
  final SupabaseService _db = SupabaseService();

  final options = <DeliveryOptionModel>[].obs;
  final isLoading = false.obs;

  Future<void> fetchOptions(String companyId) async {
    try {
      isLoading.value = true;
      final response = await _db.client.from('delivery_options').select().eq('company_id', companyId).order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(response);
      options.assignAll(data.map((e) => DeliveryOptionModel.fromJson(e)).toList());
    } catch (e) {
      debugPrint('Error fetching delivery options: $e');
      ToastService.error('Error', 'Failed to load delivery options');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createOption(DeliveryOptionModel option) async {
    try {
      isLoading.value = true;
      // Exclude ID to let DB generate it (if uuid) or ensure ID is null logic
      // But Model has ID. If new, ID might be null or generated.
      // We should probably strip ID if it's null, or let Supabase ignore it if gen_random_uuid() is default.
      final json = option.toJson();
      if (option.id == null) {
        json.remove('id');
      }
      // Remove created_at to let DB handle it
      json.remove('created_at');

      await _db.client.from('delivery_options').insert(json);
      ToastService.success('Success', 'Delivery option added');
      await fetchOptions(option.companyId);
      return true;
    } catch (e) {
      debugPrint('Error creating delivery option: $e');
      ToastService.error('Error', 'Failed to add delivery option');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateOption(DeliveryOptionModel option) async {
    if (option.id == null) return false;
    try {
      isLoading.value = true;
      final json = option.toJson();
      json.remove('created_at'); // Don't update creation time

      await _db.client.from('delivery_options').update(json).eq('id', option.id!);

      ToastService.success('Success', 'Delivery option updated');
      // Optimistic update
      final index = options.indexWhere((e) => e.id == option.id);
      if (index != -1) {
        options[index] = option;
      } else {
        fetchOptions(option.companyId);
      }
      return true;
    } catch (e) {
      debugPrint('Error updating delivery option: $e');
      ToastService.error('Error', 'Failed to update delivery option');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteOption(String id) async {
    try {
      isLoading.value = true;
      await _db.client.from('delivery_options').delete().eq('id', id);
      options.removeWhere((e) => e.id == id);
      ToastService.success('Deleted', 'Delivery option removed');
    } catch (e) {
      debugPrint('Error deleting delivery option: $e');
      ToastService.error('Error', 'Failed to delete option');
    } finally {
      isLoading.value = false;
    }
  }
}
