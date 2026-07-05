import '../models/solar_request_model.dart';
import '../models/solar_offer_model.dart';
import '../models/involve_model.dart';
import '../../domain/entities/offers_filter.dart';

abstract class OffersRemoteDataSource {
  // User Actions
  Future<List<SolarRequestModel>> getUserRequests(OffersFilter? filter);
  Future<SolarRequestModel> createRequest(Map<String, dynamic> data);
  Future<void> deleteRequest(int id);
  Future<List<SolarOfferModel>> getOffersForRequest(
    int requestId, {
    OffersFilter? filter,
  });
  Future<void> respondToOffer(int offerId, String responseStatus);

  // Company Actions
  Future<List<SolarRequestModel>> getAvailableRequests(OffersFilter? filter);
  Future<SolarOfferModel> replyToRequest(
    int requestId,
    Map<String, dynamic> data,
  );
  Future<List<SolarOfferModel>> getMyOffers(OffersFilter? filter);
  Future<SolarOfferModel> getOfferDetails(int id);
  Future<SolarOfferModel> updateOffer(int id, Map<String, dynamic> data);
  Future<void> deleteOffer(int id);
  Future<void> finishOffer(int id);
  Future<List<InvolveModel>> getInvolves();
  Future<InvolveModel> createInvolve(Map<String, dynamic> data);
  Future<InvolveModel> updateInvolve(int id, Map<String, dynamic> data);
  Future<void> deleteInvolve(int id);

  // Admin Actions
  Future<List<SolarRequestModel>> getAllRequests(OffersFilter? filter);
  Future<List<SolarOfferModel>> getAllOffers(OffersFilter? filter);
}
