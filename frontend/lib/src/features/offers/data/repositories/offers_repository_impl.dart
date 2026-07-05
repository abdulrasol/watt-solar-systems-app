import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/involve.dart';
import '../../domain/entities/solar_offer.dart';
import '../../domain/entities/solar_request.dart';
import '../../domain/entities/offers_filter.dart';
import '../../domain/repositories/offers_repository.dart';
import '../data_sources/offers_remote_data_source.dart';

class OffersRepositoryImpl implements OffersRepository {
  final OffersRemoteDataSource _remoteDataSource;

  OffersRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<SolarRequest>>> getUserRequests(
    OffersFilter? filter,
  ) async {
    try {
      final result = await _remoteDataSource.getUserRequests(filter);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SolarRequest>> createRequest(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _remoteDataSource.createRequest(data);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRequest(int id) async {
    try {
      await _remoteDataSource.deleteRequest(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SolarOffer>>> getOffersForRequest(
    int requestId, {
    OffersFilter? filter,
  }) async {
    try {
      final result = await _remoteDataSource.getOffersForRequest(
        requestId,
        filter: filter,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> respondToOffer(
    int offerId,
    String responseStatus,
  ) async {
    try {
      await _remoteDataSource.respondToOffer(offerId, responseStatus);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SolarRequest>>> getAvailableRequests(
    OffersFilter? filter,
  ) async {
    try {
      final result = await _remoteDataSource.getAvailableRequests(filter);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SolarOffer>> replyToRequest(
    int requestId,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _remoteDataSource.replyToRequest(requestId, data);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SolarOffer>>> getMyOffers(
    OffersFilter? filter,
  ) async {
    try {
      final result = await _remoteDataSource.getMyOffers(filter);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SolarOffer>> getOfferDetails(int id) async {
    try {
      final result = await _remoteDataSource.getOfferDetails(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SolarOffer>> updateOffer(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _remoteDataSource.updateOffer(id, data);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteOffer(int id) async {
    try {
      await _remoteDataSource.deleteOffer(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> finishOffer(int id) async {
    try {
      await _remoteDataSource.finishOffer(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Involve>>> getInvolves() async {
    try {
      final result = await _remoteDataSource.getInvolves();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Involve>> createInvolve(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _remoteDataSource.createInvolve(data);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Involve>> updateInvolve(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _remoteDataSource.updateInvolve(id, data);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInvolve(int id) async {
    try {
      await _remoteDataSource.deleteInvolve(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SolarRequest>>> getAllRequests(
    OffersFilter? filter,
  ) async {
    try {
      final result = await _remoteDataSource.getAllRequests(filter);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SolarOffer>>> getAllOffers(
    OffersFilter? filter,
  ) async {
    try {
      final result = await _remoteDataSource.getAllOffers(filter);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
