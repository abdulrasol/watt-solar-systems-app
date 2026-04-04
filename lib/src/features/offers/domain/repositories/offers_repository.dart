import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/involve.dart';
import '../entities/solar_offer.dart';
import '../entities/solar_request.dart';
import '../entities/offers_filter.dart';

abstract class OffersRepository {
  // User Actions
  Future<Either<Failure, List<SolarRequest>>> getUserRequests(
    OffersFilter? filter,
  );
  Future<Either<Failure, SolarRequest>> createRequest(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteRequest(int id);
  Future<Either<Failure, List<SolarOffer>>> getOffersForRequest(
    int requestId, {
    OffersFilter? filter,
  });
  Future<Either<Failure, void>> respondToOffer(
    int offerId,
    String responseStatus,
  );

  // Company Actions
  Future<Either<Failure, List<SolarRequest>>> getAvailableRequests(
    OffersFilter? filter,
  );
  Future<Either<Failure, SolarOffer>> replyToRequest(
    int requestId,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, List<SolarOffer>>> getMyOffers(OffersFilter? filter);
  Future<Either<Failure, SolarOffer>> getOfferDetails(int id);
  Future<Either<Failure, SolarOffer>> updateOffer(
    int id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteOffer(int id);
  Future<Either<Failure, void>> finishOffer(int id);
  Future<Either<Failure, List<Involve>>> getInvolves();
  Future<Either<Failure, Involve>> createInvolve(Map<String, dynamic> data);
  Future<Either<Failure, Involve>> updateInvolve(
    int id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteInvolve(int id);

  // Admin Actions
  Future<Either<Failure, List<SolarRequest>>> getAllRequests(
    OffersFilter? filter,
  );
  Future<Either<Failure, List<SolarOffer>>> getAllOffers(OffersFilter? filter);
}
