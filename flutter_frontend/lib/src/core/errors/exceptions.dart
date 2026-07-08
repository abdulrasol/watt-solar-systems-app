class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server Error']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache Error']);
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const ApiException(this.message, {this.statusCode, this.code});

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Unauthorized'])
    : super(statusCode: 401, code: 'unauthorized');
}

class MembershipException extends ApiException {
  const MembershipException([super.message = 'You are not a member of this company'])
    : super(statusCode: 403, code: 'membership');
}

class InactiveServiceException extends ApiException {
  final String serviceCode;

  const InactiveServiceException(
    this.serviceCode, [
    super.message = 'Inactive company service',
  ]) : super(statusCode: 403, code: 'inactive_service');
}

class ServiceDependencyException extends ApiException {
  const ServiceDependencyException(super.message)
    : super(statusCode: 400, code: 'service_dependency');
}
