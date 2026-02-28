import 'package:get/get.dart';
import 'package:solar_hub/features/store/models/product_model.dart';
import 'package:solar_hub/models/company_model.dart';
import 'package:solar_hub/features/systems/models/system_model.dart';
import 'package:solar_hub/features/systems/controllers/systems_controller.dart';
import 'package:solar_hub/services/supabase_service.dart';

class StoreController extends GetxController {
  final _dbService = SupabaseService();

  // Observables
  final products = <ProductModel>[].obs;
  final companies = <CompanyModel>[].obs;
  final categories = <String>[].obs;
  final companySystems = <SystemModel>[].obs;

  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedCategory = ''.obs;
  final sortOption = 'newest'.obs;

  // Persistent filter state for this controller instance
  String? _currentShopId;

  @override
  void onInit() {
    super.onInit();
    // Setup listeners
    ever(sortOption, (_) => fetchProducts(category: selectedCategory.value, shopId: _currentShopId));
    ever(selectedCategory, (_) => fetchProducts(category: selectedCategory.value, shopId: _currentShopId));
  }

  @override
  void onReady() {
    super.onReady();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    isLoading.value = true;
    try {
      await refreshData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await Future.wait([fetchProducts(), fetchCompanies(), fetchCategories()]);
  }

  Future<void> fetchProducts({String? category, String? shopId}) async {
    try {
      // Update persistent state if a new shopId is provided
      if (shopId != null) {
        _currentShopId = shopId;
      }

      // Use the provided shopId OR the persistent one
      final targetShopId = shopId ?? _currentShopId;

      // Build query
      dynamic query = _dbService.client
          .from('products')
          .select('''
        *,
        *,
        *,
        companies!inner(name, status, currency_id, currencies(*)),
        product_options(
          *,
          product_option_values(*)
        )
      ''')
          .eq('status', 'active')
          .eq('companies.status', 'active')
          .eq('companies.allows_b2c', true);

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (targetShopId != null && targetShopId.isNotEmpty) {
        query = query.eq('company_id', targetShopId);
      }

      if (searchQuery.isNotEmpty) {
        query = query.ilike('name', '%${searchQuery.value}%');
      }

      // Sorting
      if (sortOption.value == 'price_asc') {
        query = query.order('retail_price', ascending: true);
      } else if (sortOption.value == 'price_desc') {
        query = query.order('retail_price', ascending: false);
      } else {
        query = query.order('created_at', ascending: false);
      }

      final response = await query.limit(50);
      final data = List<Map<String, dynamic>>.from(response);
      products.assignAll(data.map((e) => ProductModel.fromJson(e)).toList());
    } catch (e) {
      // print('Error fetching products: $e');
    }
  }

  Future<void> fetchCompanies() async {
    try {
      final response = await _dbService.client.from('companies').select().eq('status', 'active').eq('allows_b2c', true).limit(20);
      final data = List<Map<String, dynamic>>.from(response);
      companies.assignAll(data.map((e) => CompanyModel.fromJson(e)).toList());
    } catch (e) {
      // print('Error fetching companies: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      // Supabase distinct query workaround or simple fetch
      // For now, fetching distinct categories from active products
      await _dbService.client.rpc('get_distinct_categories');
      // Note: If RPC doesn't exist, we fallback to client-side extraction or simple list
      // Fallback manual extraction:
      // final allProds = await _dbService.client.from('products').select('category').eq('status', 'active');
      // final uniqueCats = allProds.map((e) => e['category'] as String).toSet().toList();
    } catch (e) {
      // Manual fallback if RPC is missing
      _manualfetchCategories();
    }
  }

  Future<void> _manualfetchCategories() async {
    try {
      final response = await _dbService.client.from('products').select('category').eq('status', 'active').limit(100);
      final List data = response as List;
      final uniqueCats = data.map((e) => e['category'] as String?).where((e) => e != null).cast<String>().toSet().toList();
      categories.assignAll(uniqueCats);
    } catch (e) {
      // print('Error fetching categories: $e');
      // Fallback static categories
      categories.assignAll(['Solar Panels', 'Batteries', 'Inverters', 'Accessories']);
    }
  }

  void search(String query) {
    searchQuery.value = query;
    fetchProducts(category: selectedCategory.value); // Refresh with search
  }

  Future<void> fetchSystems(String companyId) async {
    try {
      final systemsController = Get.put(SystemsController());
      final systems = await systemsController.fetchSystemsUnified(type: SystemFilterType.storeProfile, id: companyId);
      companySystems.assignAll(systems);
    } catch (e) {
      // print('Error fetching company systems: $e');
    }
  }

  void filterByCategory(String category) {
    if (selectedCategory.value == category) {
      selectedCategory.value = ''; // toggle off
    } else {
      selectedCategory.value = category;
    }
    fetchProducts(category: selectedCategory.value);
  }
}
