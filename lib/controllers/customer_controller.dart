import 'package:get/get.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/models/customer_model.dart';
import 'package:solar_hub/models/currency_model.dart';
import 'package:solar_hub/services/supabase_service.dart';

class CustomerController extends GetxController {
  final _dbService = SupabaseService();
  final customers = <CustomerModel>[].obs;
  final isLoading = false.obs;

  CurrencyModel get effectiveCurrency => Get.find<CompanyController>().effectiveCurrency;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    final companyId = Get.find<CompanyController>().company.value?.id;
    if (companyId == null) return;

    isLoading.value = true;
    try {
      final response = await _dbService.client.from('customers').select().eq('company_id', companyId).order('full_name');

      final data = List<Map<String, dynamic>>.from(response);
      customers.assignAll(data.map((e) => CustomerModel.fromJson(e)).toList());
    } catch (e) {
      Get.snackbar('Error', 'Failed to load customers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addCustomer(CustomerModel customer) async {
    try {
      await _dbService.client.from('customers').insert(customer.toJson());
      await fetchCustomers();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add customer: $e');
      return false;
    }
  }

  Future<bool> updateCustomer(String id, Map<String, dynamic> updates) async {
    try {
      await _dbService.client.from('customers').update(updates).eq('id', id);
      await fetchCustomers();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update customer: $e');
      return false;
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _dbService.client.from('customers').delete().eq('id', id);
      customers.removeWhere((c) => c.id == id);
      Get.snackbar('Success', 'Customer deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete customer: $e');
    }
  }
}
