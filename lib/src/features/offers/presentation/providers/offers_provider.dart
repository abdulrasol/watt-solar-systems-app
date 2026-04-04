import 'package:flutter_riverpod/legacy.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import '../../domain/entities/solar_offer.dart';
import '../../domain/entities/solar_request.dart';
import '../../domain/entities/offers_filter.dart';
import '../../domain/repositories/offers_repository.dart';

class OffersState {
  final bool isLoading;
  final List<SolarRequest> userRequests;
  final bool userRequestsHasMore;
  final bool userRequestsIsMoreLoading;
  final OffersFilter userRequestsFilter;

  final List<SolarRequest> availableRequests;
  final bool availableRequestsHasMore;
  final bool availableRequestsIsMoreLoading;
  final OffersFilter availableRequestsFilter;

  final List<SolarRequest> adminRequests;
  final bool adminRequestsHasMore;
  final bool adminRequestsIsMoreLoading;
  final OffersFilter adminRequestsFilter;

  final List<SolarOffer> myOffers;
  final bool myOffersHasMore;
  final bool myOffersIsMoreLoading;
  final OffersFilter myOffersFilter;

  final List<SolarOffer> adminOffers;
  final bool adminOffersHasMore;
  final bool adminOffersIsMoreLoading;
  final OffersFilter adminOffersFilter;

  final List<SolarOffer> requestOffers;
  final bool requestOffersHasMore;
  final bool requestOffersIsMoreLoading;
  final OffersFilter requestOffersFilter;

  final Map<int, List<SolarOffer>> offersByRequest;
  final SolarOffer? selectedOffer;
  final SolarRequest? selectedRequest;
  final String? error;

  OffersState({
    required this.isLoading,
    this.userRequests = const [],
    this.userRequestsHasMore = true,
    this.userRequestsIsMoreLoading = false,
    required this.userRequestsFilter,
    this.availableRequests = const [],
    this.availableRequestsHasMore = true,
    this.availableRequestsIsMoreLoading = false,
    required this.availableRequestsFilter,
    this.adminRequests = const [],
    this.adminRequestsHasMore = true,
    this.adminRequestsIsMoreLoading = false,
    required this.adminRequestsFilter,
    this.myOffers = const [],
    this.myOffersHasMore = true,
    this.myOffersIsMoreLoading = false,
    required this.myOffersFilter,
    this.adminOffers = const [],
    this.adminOffersHasMore = true,
    this.adminOffersIsMoreLoading = false,
    required this.adminOffersFilter,
    this.requestOffers = const [],
    this.requestOffersHasMore = true,
    this.requestOffersIsMoreLoading = false,
    required this.requestOffersFilter,
    this.offersByRequest = const {},
    this.selectedOffer,
    this.selectedRequest,
    this.error,
  });

  OffersState copyWith({
    bool? isLoading,
    List<SolarRequest>? userRequests,
    bool? userRequestsHasMore,
    bool? userRequestsIsMoreLoading,
    OffersFilter? userRequestsFilter,
    List<SolarRequest>? availableRequests,
    bool? availableRequestsHasMore,
    bool? availableRequestsIsMoreLoading,
    OffersFilter? availableRequestsFilter,
    List<SolarRequest>? adminRequests,
    bool? adminRequestsHasMore,
    bool? adminRequestsIsMoreLoading,
    OffersFilter? adminRequestsFilter,
    List<SolarOffer>? myOffers,
    bool? myOffersHasMore,
    bool? myOffersIsMoreLoading,
    OffersFilter? myOffersFilter,
    List<SolarOffer>? adminOffers,
    bool? adminOffersHasMore,
    bool? adminOffersIsMoreLoading,
    OffersFilter? adminOffersFilter,
    List<SolarOffer>? requestOffers,
    bool? requestOffersHasMore,
    bool? requestOffersIsMoreLoading,
    OffersFilter? requestOffersFilter,
    Map<int, List<SolarOffer>>? offersByRequest,
    SolarOffer? selectedOffer,
    SolarRequest? selectedRequest,
    String? error,
  }) {
    return OffersState(
      isLoading: isLoading ?? this.isLoading,
      userRequests: userRequests ?? this.userRequests,
      userRequestsHasMore: userRequestsHasMore ?? this.userRequestsHasMore,
      userRequestsIsMoreLoading: userRequestsIsMoreLoading ?? this.userRequestsIsMoreLoading,
      userRequestsFilter: userRequestsFilter ?? this.userRequestsFilter,
      availableRequests: availableRequests ?? this.availableRequests,
      availableRequestsHasMore: availableRequestsHasMore ?? this.availableRequestsHasMore,
      availableRequestsIsMoreLoading: availableRequestsIsMoreLoading ?? this.availableRequestsIsMoreLoading,
      availableRequestsFilter: availableRequestsFilter ?? this.availableRequestsFilter,
      adminRequests: adminRequests ?? this.adminRequests,
      adminRequestsHasMore: adminRequestsHasMore ?? this.adminRequestsHasMore,
      adminRequestsIsMoreLoading: adminRequestsIsMoreLoading ?? this.adminRequestsIsMoreLoading,
      adminRequestsFilter: adminRequestsFilter ?? this.adminRequestsFilter,
      myOffers: myOffers ?? this.myOffers,
      myOffersHasMore: myOffersHasMore ?? this.myOffersHasMore,
      myOffersIsMoreLoading: myOffersIsMoreLoading ?? this.myOffersIsMoreLoading,
      myOffersFilter: myOffersFilter ?? this.myOffersFilter,
      adminOffers: adminOffers ?? this.adminOffers,
      adminOffersHasMore: adminOffersHasMore ?? this.adminOffersHasMore,
      adminOffersIsMoreLoading: adminOffersIsMoreLoading ?? this.adminOffersIsMoreLoading,
      adminOffersFilter: adminOffersFilter ?? this.adminOffersFilter,
      requestOffers: requestOffers ?? this.requestOffers,
      requestOffersHasMore: requestOffersHasMore ?? this.requestOffersHasMore,
      requestOffersIsMoreLoading: requestOffersIsMoreLoading ?? this.requestOffersIsMoreLoading,
      requestOffersFilter: requestOffersFilter ?? this.requestOffersFilter,
      offersByRequest: offersByRequest ?? this.offersByRequest,
      selectedOffer: selectedOffer ?? this.selectedOffer,
      selectedRequest: selectedRequest ?? this.selectedRequest,
      error: error,
    );
  }
}

final offersProvider = StateNotifierProvider<OffersNotifier, OffersState>(
  (ref) => OffersNotifier(getIt<OffersRepository>()),
);

class OffersNotifier extends StateNotifier<OffersState> {
  final OffersRepository _repository;
  OffersNotifier(this._repository)
    : super(
        OffersState(
          isLoading: false,
          userRequestsFilter: OffersFilter(),
          availableRequestsFilter: OffersFilter(),
          adminRequestsFilter: OffersFilter(),
          myOffersFilter: OffersFilter(),
          adminOffersFilter: OffersFilter(),
          requestOffersFilter: OffersFilter(),
        ),
      );

  // User Actions
  Future<void> getUserRequests({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        userRequestsFilter: state.userRequestsFilter.copyWith(page: 1),
        userRequestsHasMore: true,
      );
    } else {
      if (!state.userRequestsHasMore || state.userRequestsIsMoreLoading) return;
      state = state.copyWith(userRequestsIsMoreLoading: true, error: null);
    }

    final result = await _repository.getUserRequests(state.userRequestsFilter);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        userRequestsIsMoreLoading: false,
        error: failure.toString(),
      ),
      (requests) => state = state.copyWith(
        isLoading: false,
        userRequestsIsMoreLoading: false,
        userRequests:
            isRefresh ? requests : [...state.userRequests, ...requests],
        userRequestsHasMore: requests.length == state.userRequestsFilter.pageSize,
      ),
    );
  }

  Future<void> userRequestsNextPage() async {
    if (!state.userRequestsHasMore || state.userRequestsIsMoreLoading) return;
    state = state.copyWith(
      userRequestsFilter: state.userRequestsFilter.copyWith(
        page: state.userRequestsFilter.page + 1,
      ),
    );
    await getUserRequests();
  }

  Future<void> createRequest(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.createRequest(data);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.toString()),
      (request) {
        state = state.copyWith(
          isLoading: false,
          userRequests: [request, ...state.userRequests],
        );
      },
    );
  }

  Future<void> getOffersForRequest(int requestId, {bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        requestOffersFilter: state.requestOffersFilter.copyWith(page: 1),
        requestOffersHasMore: true,
      );
    } else {
      if (!state.requestOffersHasMore || state.requestOffersIsMoreLoading) return;
      state = state.copyWith(requestOffersIsMoreLoading: true, error: null);
    }

    final result = await _repository.getOffersForRequest(
      requestId,
      filter: state.requestOffersFilter,
    );
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        requestOffersIsMoreLoading: false,
        error: failure.toString(),
      ),
      (offers) {
        final newMap = Map<int, List<SolarOffer>>.from(state.offersByRequest);
        final currentOffers = isRefresh ? <SolarOffer>[] : (newMap[requestId] ?? []);
        final updatedOffers = [...currentOffers, ...offers];
        newMap[requestId] = updatedOffers;

        state = state.copyWith(
          isLoading: false,
          requestOffersIsMoreLoading: false,
          requestOffers: updatedOffers,
          offersByRequest: newMap,
          requestOffersHasMore: offers.length == state.requestOffersFilter.pageSize,
        );
      },
    );
  }

  Future<void> requestOffersNextPage(int requestId) async {
    if (!state.requestOffersHasMore || state.requestOffersIsMoreLoading) return;
    state = state.copyWith(
      requestOffersFilter: state.requestOffersFilter.copyWith(
        page: state.requestOffersFilter.page + 1,
      ),
    );
    await getOffersForRequest(requestId);
  }

  Future<void> respondToOffer(int offerId, String status) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.respondToOffer(offerId, status);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.toString()),
      (_) => state = state.copyWith(isLoading: false),
    );
  }

  // Company Actions
  Future<void> getAvailableRequests({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        availableRequestsFilter: state.availableRequestsFilter.copyWith(page: 1),
        availableRequestsHasMore: true,
      );
    } else {
      if (!state.availableRequestsHasMore || state.availableRequestsIsMoreLoading)
        return;
      state = state.copyWith(availableRequestsIsMoreLoading: true, error: null);
    }

    final result = await _repository.getAvailableRequests(
      state.availableRequestsFilter,
    );
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        availableRequestsIsMoreLoading: false,
        error: failure.toString(),
      ),
      (requests) => state = state.copyWith(
        isLoading: false,
        availableRequestsIsMoreLoading: false,
        availableRequests:
            isRefresh ? requests : [...state.availableRequests, ...requests],
        availableRequestsHasMore:
            requests.length == state.availableRequestsFilter.pageSize,
      ),
    );
  }

  Future<void> availableRequestsNextPage() async {
    if (!state.availableRequestsHasMore || state.availableRequestsIsMoreLoading)
      return;
    state = state.copyWith(
      availableRequestsFilter: state.availableRequestsFilter.copyWith(
        page: state.availableRequestsFilter.page + 1,
      ),
    );
    await getAvailableRequests();
  }

  Future<void> getMyOffers({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        myOffersFilter: state.myOffersFilter.copyWith(page: 1),
        myOffersHasMore: true,
      );
    } else {
      if (!state.myOffersHasMore || state.myOffersIsMoreLoading) return;
      state = state.copyWith(myOffersIsMoreLoading: true, error: null);
    }

    final result = await _repository.getMyOffers(state.myOffersFilter);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        myOffersIsMoreLoading: false,
        error: failure.toString(),
      ),
      (offers) => state = state.copyWith(
        isLoading: false,
        myOffersIsMoreLoading: false,
        myOffers: isRefresh ? offers : [...state.myOffers, ...offers],
        myOffersHasMore: offers.length == state.myOffersFilter.pageSize,
      ),
    );
  }

  Future<void> myOffersNextPage() async {
    if (!state.myOffersHasMore || state.myOffersIsMoreLoading) return;
    state = state.copyWith(
      myOffersFilter: state.myOffersFilter.copyWith(
        page: state.myOffersFilter.page + 1,
      ),
    );
    await getMyOffers();
  }

  Future<void> replyToRequest(int requestId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.replyToRequest(requestId, data);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.toString()),
      (offer) {
        state = state.copyWith(
          isLoading: false,
          myOffers: [offer, ...state.myOffers],
        );
      },
    );
  }

  Future<void> updateOffer(int offerId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.updateOffer(offerId, data);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.toString()),
      (offer) {
        final updatedList = state.myOffers
            .map((o) => o.id == offerId ? offer : o)
            .toList();
        state = state.copyWith(isLoading: false, myOffers: updatedList);
      },
    );
  }

  // Admin Actions
  Future<void> getAllRequests({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        adminRequestsFilter: state.adminRequestsFilter.copyWith(page: 1),
        adminRequestsHasMore: true,
      );
    } else {
      if (!state.adminRequestsHasMore || state.adminRequestsIsMoreLoading)
        return;
      state = state.copyWith(adminRequestsIsMoreLoading: true, error: null);
    }

    final result = await _repository.getAllRequests(state.adminRequestsFilter);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        adminRequestsIsMoreLoading: false,
        error: failure.toString(),
      ),
      (requests) => state = state.copyWith(
        isLoading: false,
        adminRequestsIsMoreLoading: false,
        adminRequests:
            isRefresh ? requests : [...state.adminRequests, ...requests],
        adminRequestsHasMore:
            requests.length == state.adminRequestsFilter.pageSize,
      ),
    );
  }

  Future<void> adminRequestsNextPage() async {
    if (!state.adminRequestsHasMore || state.adminRequestsIsMoreLoading) return;
    state = state.copyWith(
      adminRequestsFilter: state.adminRequestsFilter.copyWith(
        page: state.adminRequestsFilter.page + 1,
      ),
    );
    await getAllRequests();
  }

  Future<void> getAllOffers({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        adminOffersFilter: state.adminOffersFilter.copyWith(page: 1),
        adminOffersHasMore: true,
      );
    } else {
      if (!state.adminOffersHasMore || state.adminOffersIsMoreLoading) return;
      state = state.copyWith(adminOffersIsMoreLoading: true, error: null);
    }

    final result = await _repository.getAllOffers(state.adminOffersFilter);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        adminOffersIsMoreLoading: false,
        error: failure.toString(),
      ),
      (offers) => state = state.copyWith(
        isLoading: false,
        adminOffersIsMoreLoading: false,
        adminOffers: isRefresh ? offers : [...state.adminOffers, ...offers],
        adminOffersHasMore: offers.length == state.adminOffersFilter.pageSize,
      ),
    );
  }

  Future<void> adminOffersNextPage() async {
    if (!state.adminOffersHasMore || state.adminOffersIsMoreLoading) return;
    state = state.copyWith(
      adminOffersFilter: state.adminOffersFilter.copyWith(
        page: state.adminOffersFilter.page + 1,
      ),
    );
    await getAllOffers();
  }

  // Filter Updates
  void updateRequestsStatus(String? status) {
    state = state.copyWith(
      userRequestsFilter: state.userRequestsFilter.copyWith(status: status, page: 1),
      userRequestsHasMore: true,
    );
    getUserRequests(isRefresh: true);
  }

  void updateAvailableRequestsStatus(String? status) {
    state = state.copyWith(
      availableRequestsFilter: state.availableRequestsFilter.copyWith(status: status, page: 1),
      availableRequestsHasMore: true,
    );
    getAvailableRequests(isRefresh: true);
  }

  void updateMyOffersStatus(String? status) {
    state = state.copyWith(
      myOffersFilter: state.myOffersFilter.copyWith(status: status, page: 1),
      myOffersHasMore: true,
    );
    getMyOffers(isRefresh: true);
  }

  void updateAdminRequestsStatus(String? status) {
    state = state.copyWith(
      adminRequestsFilter: state.adminRequestsFilter.copyWith(status: status, page: 1),
      adminRequestsHasMore: true,
    );
    getAllRequests(isRefresh: true);
  }

  void updateAdminOffersStatus(String? status) {
    state = state.copyWith(
      adminOffersFilter: state.adminOffersFilter.copyWith(status: status, page: 1),
      adminOffersHasMore: true,
    );
    getAllOffers(isRefresh: true);
  }
}
