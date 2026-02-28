import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:solar_hub/models/company_model.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:solar_hub/controllers/currency_controller.dart';
import 'package:solar_hub/models/currency_model.dart';

class CompanyController extends GetxController {
  final _dbService = SupabaseService();

  // Observable state
  final company = Rxn<CompanyModel>();
  final currentRole = RxnString(); // Keep for backward compat (first role or legacy)
  final currentRoles = <String>[].obs; // NEW: Multiple roles support
  final isLoading = false.obs;
  final stats = <String, dynamic>{}.obs;

  /// Helper to check if user has any of the specified roles
  bool hasAnyRole(List<String> requiredRoles) {
    if (currentRoles.isEmpty && currentRole.value != null) {
      // Fallback to single role if roles array is empty
      return requiredRoles.contains(currentRole.value);
    }
    return currentRoles.any((r) => requiredRoles.contains(r));
  }

  /// Get the effective currency for the current company
  CurrencyModel get effectiveCurrency {
    final currencyController = Get.find<CurrencyController>();
    if (company.value?.currencyId != null) {
      return currencyController.getCurrencyById(company.value!.currencyId) ?? currencyController.defaultCurrency ?? _fallbackCurrency;
    }
    return currencyController.defaultCurrency ?? _fallbackCurrency;
  }

  final _fallbackCurrency = CurrencyModel(id: 'manual', name: 'US Dollar', code: 'USD', symbol: '\$');

  @override
  void onInit() {
    super.onInit();
    // Fetch initially
    fetchMyCompany();

    // Listen to Auth changes to re-fetch or clear
    // Assuming AuthController has an observable 'user' or similar
    // We can use Supabase auth state change listener as a robust fallback
    _dbService.client.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        fetchMyCompany();
      } else {
        company.value = null;
        currentRole.value = null;
        currentRoles.clear();
        stats.clear();
      }
    });
  }

  Future<void> fetchMyCompany() async {
    isLoading.value = true;
    try {
      final userId = _dbService.client.auth.currentUser?.id;
      if (userId == null) {
        company.value = null;
        currentRole.value = null;
        currentRoles.clear();
        return;
      }
      debugPrint('server @fetchMyCompany: Checking for user $userId');

      // Step 1: Fetch Member Row ONLY (No join yet)
      final memberResponse = await _dbService.client.from('company_members').select().eq('user_id', userId).maybeSingle();

      if (memberResponse == null) {
        debugPrint('server @fetchMyCompany: No member row found for user $userId. CHECK RLS POLICIES.');
        company.value = null;
        currentRole.value = null;
        currentRoles.clear();

        // Optional: Add the fallback logic here if needed, but for now let's focus on the primary path
        return;
      }

      debugPrint('server @fetchMyCompany: Found member row: $memberResponse');
      final companyId = memberResponse['company_id'];

      // Handle roles - try 'roles' array first, fallback to 'role'
      if (memberResponse['roles'] != null) {
        currentRoles.assignAll(List<String>.from(memberResponse['roles']));
        currentRole.value = currentRoles.isNotEmpty ? currentRoles.first : null;
      } else if (memberResponse['role'] != null) {
        currentRole.value = memberResponse['role'] as String?;
        currentRoles.assignAll([currentRole.value ?? 'staff']);
      } else {
        currentRoles.assignAll(['staff']);
        currentRole.value = 'staff';
      }
      debugPrint('server @fetchMyCompany: Roles = $currentRoles');

      if (companyId != null) {
        // Step 2: Fetch Company Details
        final companyResponse = await _dbService.client.from('companies').select().eq('id', companyId).maybeSingle();

        if (companyResponse != null) {
          debugPrint('server @fetchMyCompany: Found company: ${companyResponse['name']}');
          company.value = CompanyModel.fromJson(companyResponse);
          await fetchStats(company.value!.id);
        } else {
          debugPrint('server @fetchMyCompany: Member exists but Company $companyId not found!');
        }
      }
    } catch (e) {
      debugPrint('server error @fetchMyCompany: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStats(String companyId) async {
    try {
      // Parallel fetch for stats (Optimization)

      // 1. Products Count
      // 2. Pending Orders
      // 3. Pending Orders

      // Using `count` property in select for efficiency
      final productsCount = await _dbService.client.from('products').count().eq('company_id', companyId).eq('status', 'active');
      final ordersCount = await _dbService.client.from('orders').count().eq('seller_company_id', companyId).eq('status', 'pending');

      // 4. Inventory Value
      // Fetch all products with cost_price and stock_quantity to calculate total value
      final productsRes = await _dbService.client.from('products').select('cost_price, stock_quantity').eq('company_id', companyId).eq('status', 'active');

      double inventoryValue = 0.0;
      for (var p in productsRes) {
        final cost = (p['cost_price'] as num?)?.toDouble() ?? 0.0;
        final qty = (p['stock_quantity'] as num?)?.toInt() ?? 0;
        inventoryValue += (cost * qty);
      }

      final requestsCount = await _dbService.client.from('offer_requests').count().eq('status', 'open');

      stats.value = {
        'products': productsCount,
        'pending_orders': ordersCount,
        'open_requests': requestsCount,
        'inventory_value': inventoryValue,
        'sales_today': 0.0,
      };
      debugPrint('server @fetchStats: $stats');
    } catch (e) {
      debugPrint('server error @fetchStats: $e');
    }
  }

  Future<void> updateCompanyCurrency(String currencyId) async {
    if (company.value == null) return;
    try {
      isLoading.value = true;
      await _dbService.client.from('companies').update({'currency_id': currencyId}).eq('id', company.value!.id);

      // Update local
      company.value = CompanyModel(
        id: company.value!.id,
        name: company.value!.name,
        tier: company.value!.tier,
        description: company.value!.description,
        logoUrl: company.value!.logoUrl,
        address: company.value!.address,
        contactPhone: company.value!.contactPhone,
        currencyId: currencyId,
        balance: company.value!.balance,
        status: company.value!.status,
        createdAt: company.value!.createdAt,
        updatedAt: DateTime.now(),
        allowsB2B: company.value!.allowsB2B,
        allowsB2C: company.value!.allowsB2C,
      );
    } catch (e) {
      debugPrint("Error updating currency: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
