import 'package:equatable/equatable.dart';

class PublicCompaniesQuery extends Equatable {
  final int? cityId;
  final String search;
  final int? serviceId;
  final String channel;

  const PublicCompaniesQuery({
    this.cityId,
    this.search = '',
    this.serviceId,
    this.channel = 'b2c',
  });

  PublicCompaniesQuery copyWith({
    int? cityId,
    bool clearCityId = false,
    String? search,
    int? serviceId,
    bool clearServiceId = false,
    String? channel,
  }) {
    return PublicCompaniesQuery(
      cityId: clearCityId ? null : (cityId ?? this.cityId),
      search: search ?? this.search,
      serviceId: clearServiceId ? null : (serviceId ?? this.serviceId),
      channel: channel ?? this.channel,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      'channel': channel,
      if (cityId != null) 'city_id': cityId,
      if (search.trim().isNotEmpty) 'search': search.trim(),
      if (serviceId != null) 'service_id': serviceId,
    };
  }

  @override
  List<Object?> get props => [cityId, search, serviceId, channel];
}
