import '../../../../core/services/dio.dart';
import '../../../../utils/app_urls.dart';
import '../../../../core/models/response.dart' as local;
import '../models/solar_request_model.dart';
import '../models/solar_offer_model.dart';
import '../models/involve_model.dart';
import '../../domain/entities/offers_filter.dart';
import 'offers_remote_data_source.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class OffersRemoteDataSourceImpl implements OffersRemoteDataSource {
  final DioService _dioService;

  OffersRemoteDataSourceImpl(this._dioService);

  @override
  Future<List<SolarRequestModel>> getUserRequests(OffersFilter? filter) async {
    try {
      final response = await _dioService.get(AppUrls.userRequests, queryParameters: filter?.query(), isPagination: true) as local.PaginationResponse;
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
      return (response.body as List).map((e) => SolarRequestModel.fromJson(e)).toList();
  } catch (e, stackTrace) {
      dPrint('getUserRequests error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<SolarRequestModel> createRequest(Map<String, dynamic> data) async {
    try {
      final response = await _dioService.post(AppUrls.createRequest, data: data);
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
      return SolarRequestModel.fromJson(response.body);
  } catch (e, stackTrace) {
      dPrint('createRequest error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<void> deleteRequest(int id) async {
    try {
      final response = await _dioService.delete(AppUrls.deleteRequest(id));
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
  } catch (e, stackTrace) {
      dPrint('deleteRequest error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<List<SolarOfferModel>> getOffersForRequest(int requestId, {OffersFilter? filter}) async {
    try {
      final response = await _dioService.get(AppUrls.requestOffers(requestId), queryParameters: filter?.query(), isPagination: true) as local.PaginationResponse;
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
      return (response.body as List).map((e) => SolarOfferModel.fromJson(e)).toList();
  } catch (e, stackTrace) {
      dPrint('getOffersForRequest error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<void> respondToOffer(int offerId, String responseStatus) async {
    try {
      final response = await _dioService.post(AppUrls.respondToOffer(offerId), data: {'state': responseStatus});
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
  } catch (e, stackTrace) {
      dPrint('respondToOffer error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<List<SolarRequestModel>> getAvailableRequests(OffersFilter? filter) async {
    try {
      final response = await _dioService.get(AppUrls.availableRequests, queryParameters: filter?.query(), isPagination: true) as local.PaginationResponse;
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
      return (response.body as List).map((e) => SolarRequestModel.fromJson(e)).toList();
  } catch (e, stackTrace) {
      dPrint('getAvailableRequests error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<SolarOfferModel> replyToRequest(int requestId, Map<String, dynamic> data) async {
    try {
      final response = await _dioService.post(AppUrls.replyToRequest(requestId), data: data);
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
      return SolarOfferModel.fromJson(response.body);
  } catch (e, stackTrace) {
      dPrint('replyToRequest error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<List<SolarOfferModel>> getMyOffers(OffersFilter? filter) async {
    try {
      final response = await _dioService.get(AppUrls.myOffers, queryParameters: filter?.query(), isPagination: true) as local.PaginationResponse;
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
      return (response.body as List).map((e) => SolarOfferModel.fromJson(e)).toList();
  } catch (e, stackTrace) {
      dPrint('getMyOffers error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<SolarOfferModel> getOfferDetails(int id) async {
    try {
      final response = await _dioService.get(AppUrls.offerDetails(id));
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
      return SolarOfferModel.fromJson(response.body);
  } catch (e, stackTrace) {
      dPrint('getOfferDetails error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<SolarOfferModel> updateOffer(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dioService.put(AppUrls.updateOffer(id), data: data);
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
      return SolarOfferModel.fromJson(response.body);
  } catch (e, stackTrace) {
      dPrint('updateOffer error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<void> deleteOffer(int id) async {
    try {
      final response = await _dioService.delete(AppUrls.deleteOffer(id));
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
  } catch (e, stackTrace) {
      dPrint('deleteOffer error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<void> finishOffer(int id) async {
    try {
      final response = await _dioService.post(AppUrls.finishOffer(id));
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
  } catch (e, stackTrace) {
      dPrint('finishOffer error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<List<InvolveModel>> getInvolves() async {
    try {
      final response = await _dioService.get(AppUrls.involves);
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
      return (response.body as List).map((e) => InvolveModel.fromJson(e)).toList();
  } catch (e, stackTrace) {
      dPrint('getInvolves error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<InvolveModel> createInvolve(Map<String, dynamic> data) async {
    try {
      final response = await _dioService.post('${AppUrls.involves}/', data: data);
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
      return InvolveModel.fromJson(response.body);
  } catch (e, stackTrace) {
      dPrint('createInvolve error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<InvolveModel> updateInvolve(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dioService.put(AppUrls.involve(id), data: data);
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
      return InvolveModel.fromJson(response.body);
  } catch (e, stackTrace) {
      dPrint('updateInvolve error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<void> deleteInvolve(int id) async {
    try {
      final response = await _dioService.delete(AppUrls.involve(id));
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
  } catch (e, stackTrace) {
      dPrint('deleteInvolve error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<List<SolarRequestModel>> getAllRequests(OffersFilter? filter) async {
    try {
      final response = await _dioService.get(AppUrls.adminRequests, queryParameters: filter?.query(), isPagination: true) as local.PaginationResponse;
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
      return (response.body as List).map((e) => SolarRequestModel.fromJson(e)).toList();
  } catch (e, stackTrace) {
      dPrint('getAllRequests error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<List<SolarOfferModel>> getAllOffers(OffersFilter? filter) async {
    try {
      final response = await _dioService.get(AppUrls.adminOffers, queryParameters: filter?.query(), isPagination: true) as local.PaginationResponse;
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser);
      }
      return (response.body as List).map((e) => SolarOfferModel.fromJson(e)).toList();
  } catch (e, stackTrace) {
      dPrint('getAllOffers error: $e', stackTrace: stackTrace, tag: 'OffersRemoteDataSourceImpl');
      rethrow;
    }
  }
}
