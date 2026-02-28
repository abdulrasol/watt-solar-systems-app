import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:toastification/toastification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solar_hub/models/enums.dart';
import 'package:solar_hub/features/orders/controllers/company_order_controller.dart';

class OfferRequestsController extends GetxController {
  final _dbService = SupabaseService();
  final CompanyController companyController = Get.find<CompanyController>();

  // Open Requests Pagination
  final openRequests = <Map<String, dynamic>>[].obs;
  // Initialize as TRUE so initial build shows loader instead of "No items"
  final isRequestsLoading = true.obs;
  final isMoreRequestsLoading = false.obs;
  int _requestsPage = 0;
  final int _limit = 10;
  final hasMoreRequests = true.obs;

  // My Offers Pagination
  final myOffers = <Map<String, dynamic>>[].obs;
  final isOffersLoading = true.obs;
  final isMoreOffersLoading = false.obs;
  int _offersPage = 0;
  final hasMoreOffers = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Use isRefresh: true to trigger the correct loading state logic if needed,
    // but since we defaulted observables to true, we can just fetch.
    fetchOpenRequests(isRefresh: true);
  }

  // ==========================
  // 1. Fetch Open Requests
  // ==========================
  Future<void> fetchOpenRequests({bool isRefresh = false}) async {
    if (isRefresh) {
      _requestsPage = 0;
      hasMoreRequests.value = true;
      isRequestsLoading.value = true;
      // Don't clear immediately to avoid flicker if we want, but for pull-to-refresh we usually clear or replace.
      // If pull-to-refresh, we might NOT want to show full screen loader, but RefreshIndicator handles that.
      // logic: if refreshing, we are replacing list.
    } else {
      if (!hasMoreRequests.value) return;
      isMoreRequestsLoading.value = true;
    }

    try {
      final startIndex = _requestsPage * _limit;
      final endIndex = startIndex + _limit - 1;

      final response = await _dbService.client
          .from('offer_requests')
          .select('*, profiles(full_name, avatar_url)')
          .eq('status', 'open')
          .order('created_at', ascending: false)
          .range(startIndex, endIndex);

      final data = List<Map<String, dynamic>>.from(response);

      if (isRefresh) {
        openRequests.assignAll(data);
      } else {
        openRequests.addAll(data);
      }

      if (data.length < _limit) {
        hasMoreRequests.value = false;
      } else {
        _requestsPage++;
      }
    } catch (e) {
      // print("Error fetching requests: $e");
      toastification.show(
        title: Text('err_error'.tr),
        description: Text('failed_load_requests'.tr), // Need to add key
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
      );
    } finally {
      isRequestsLoading.value = false;
      isMoreRequestsLoading.value = false;
    }
  }

  // ==========================
  // 2. Fetch My Offers
  // ==========================
  Future<void> fetchMyOffers({bool isRefresh = false}) async {
    final companyId = companyController.company.value?.id;
    if (companyId == null) {
      isOffersLoading.value = false;
      return;
    }

    if (isRefresh) {
      _offersPage = 0;
      hasMoreOffers.value = true;
      isOffersLoading.value = true;
      myOffers.clear();
    } else {
      if (!hasMoreOffers.value) return;
      isMoreOffersLoading.value = true;
    }

    try {
      final startIndex = _offersPage * _limit;
      final endIndex = startIndex + _limit - 1;

      // Join with offer_requests to show what the offer was for
      final response = await _dbService.client
          .from('offers')
          .select('*, offer_requests(title, user_id)')
          .eq('company_id', companyId)
          .order('created_at', ascending: false)
          .range(startIndex, endIndex);

      final data = List<Map<String, dynamic>>.from(response);

      if (isRefresh) {
        myOffers.assignAll(data);
      } else {
        myOffers.addAll(data);
      }

      if (data.length < _limit) {
        hasMoreOffers.value = false;
      } else {
        _offersPage++;
      }
    } catch (e) {
      // print("Error fetching my offers: $e");
    } finally {
      isOffersLoading.value = false;
      isMoreOffersLoading.value = false;
    }
  }

  final isSubmitting = false.obs;

  // ==========================
  // 3. Submit Offer & Notify
  // ==========================
  Future<void> submitOffer(String requestId, Map<String, dynamic> offerData) async {
    isSubmitting.value = true;
    try {
      final user = _dbService.client.auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      await _dbService.client.from('offers').insert({
        'request_id': requestId,
        'company_id': offerData['company_id'],
        'price': offerData['price'],
        'notes': offerData['notes'],
        'pv_specs': offerData['pv_specs'] ?? {},
        'battery_specs': offerData['battery_specs'] ?? {},
        'inverter_specs': offerData['inverter_specs'] ?? {},
        'involves': offerData['involves'] ?? [],
        'status': 'pending',
      });

      // Notify User
      final requestUserId = offerData['request_user_id']; // Passed from UI
      if (requestUserId != null) {
        await _dbService.client.from('notifications').insert({
          'user_id': requestUserId,
          'title': 'New Offer Received',
          'body': '${offerData['company_name']} has sent you an offer.',
          'type': 'offer_received',
          'related_entity_id': requestId, // Request ID to nav to details
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Close bottom sheet first
      if (Get.isBottomSheetOpen ?? false) {
        if (Get.context != null) Navigator.of(Get.context!).pop();
      }

      // extensive delay to prevent GetX snackbar/overlay race conditions
      await Future.delayed(const Duration(milliseconds: 500));

      if (Get.context != null && Get.context!.mounted) {
        toastification.show(
          title: Text('success'.tr),
          description: Text('offer_submitted_success'.tr),
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Unique violation
        toastification.show(
          title: Text('err_error'.tr),
          description: Text('offer_exists_error'.tr),
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 4),
        );
      } else {
        // print("PG Error submitting offer: $e");
        toastification.show(
          title: Text('err_error'.tr),
          description: Text('offer_submit_error'.tr),
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // print("Error submitting offer: $e");
      toastification.show(
        title: Text('err_error'.tr),
        description: Text('offer_submit_error'.tr),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // ==========================
  // 4. Delete Offer
  // ==========================
  Future<void> deleteOffer(String offerId) async {
    try {
      final response = await _dbService.client.from('offers').delete().eq('id', offerId).select();

      if (response.isEmpty) {
        throw Exception("No rows deleted. Permission denied or item not found.");
      }

      // Close dialog safely
      if (Get.isDialogOpen ?? false) {
        Get.back();
      } else if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }

      // extensive delay to prevent GetX snackbar/overlay race conditions
      await Future.delayed(const Duration(milliseconds: 500));

      if (Get.context != null && Get.context!.mounted) {
        toastification.show(
          title: Text('success'.tr),
          description: Text('offer_deleted_success'.tr),
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }

      // Remove locally to avoid full refresh if possible, or just refresh
      myOffers.removeWhere((o) => o['id'] == offerId);
    } catch (e) {
      // print("Error deleting offer: $e");
      toastification.show(
        title: Text('err_error'.tr),
        description: Text('offer_delete_error'.tr),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  // ==========================
  // 6. USER SIDE: Fetch Offers for a Request
  // ==========================
  final requestOffers = <Map<String, dynamic>>[].obs;
  final isRequestOffersLoading = false.obs;

  Future<void> fetchOffersForRequest(String requestId) async {
    isRequestOffersLoading.value = true;
    try {
      final response = await _dbService.client
          .from('offers')
          .select('*, companies(name, logo_url, currencies(symbol))')
          .eq('request_id', requestId)
          .order('price', ascending: true); // Show cheapest first?

      requestOffers.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      // print("Error fetching offers for request: $e");
    } finally {
      isRequestOffersLoading.value = false;
    }
  }

  // ==========================
  // Check if I have an offer for a specific request (Robust)
  // ==========================
  Future<Map<String, dynamic>?> getMyOfferForRequest(String requestId) async {
    final companyId = companyController.company.value?.id;
    if (companyId == null) return null;

    try {
      final response = await _dbService.client
          .from('offers')
          .select('*')
          .eq('request_id', requestId)
          .eq('company_id', companyId)
          .maybeSingle(); // Returns null if not found
      return response;
    } catch (e) {
      // print("Error checking offer: $e");
      return null;
    }
  }

  // ==============================================================================
  // 5. Accept Offer (Creates Order)
  // ==============================================================================
  Future<void> acceptOffer(String offerId, String requestId) async {
    isSubmitting.value = true;
    try {
      final orderController = Get.put(CompanyOrderController());

      // 1. Fetch Offer & Request info
      final offerRes = await _dbService.client.from('offers').select('*, request:offer_requests(*)').eq('id', offerId).single();

      final offer = offerRes;
      final request = offer['request'] as Map<String, dynamic>;
      final price = (offer['price'] as num).toDouble();

      // 2. Determine if Buyer is a Company (B2B)
      final CompanyController companyController = Get.isRegistered<CompanyController>() ? Get.find<CompanyController>() : Get.put(CompanyController());

      // We need to ensure company loaded if we are the buyer
      if (companyController.company.value == null) {
        await companyController.fetchMyCompany(); // Attempt load
      }

      final buyerCompanyId = companyController.company.value?.id;
      final orderType = buyerCompanyId != null ? OrderType.b2b_supply : OrderType.online_order;

      // 3. Create Pending Order
      final orderId = await orderController.createOrder(
        items: [
          {
            'product_id': null, // Offer implies a custom bundle, usually not a single stock item ID unless mapped
            'quantity': 1,
            'unit_price': price,
            'total_line_price': price,
            'product_name_snapshot': request['title'] ?? 'Solar System Package',
            'selected_options': [],
          },
        ],
        totalAmount: price,
        orderType: orderType,
        sellerCompanyId: offer['company_id'],
        buyerUserId: request['user_id'],
        buyerCompanyId: buyerCompanyId, // <--- CRITICAL FOR B2B
        offerId: offer['id'],
        paymentMethod: 'system_offer',
      );
      if (orderId == null) {
        throw Exception("Failed to create order");
      }

      // 3. Update Statuses
      await _dbService.client.from('offers').update({'status': 'accepted'}).eq('id', offerId);
      await _dbService.client.from('offer_requests').update({'status': 'closed'}).eq('id', requestId);

      toastification.show(
        title: Text('success'.tr),
        description: Text('offer_accepted_order_created'.tr),
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 4),
      );

      // Refresh offers to update UI
      fetchOffersForRequest(requestId);
    } catch (e) {
      debugPrint("Error accepting offer: $e");
      toastification.show(
        title: Text('err_error'.tr),
        description: Text('offer_accept_error'.tr),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // ==========================
  // Chat logic moved to ChatController
  // ==========================
}
