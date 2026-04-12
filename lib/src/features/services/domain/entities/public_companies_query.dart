class PublicCompaniesQuery {
  final int? cityId;
  final String search;
  final List<String> companyTypes;
  final String channel;

  const PublicCompaniesQuery({
    this.cityId,
    this.search = '',
    this.companyTypes = const [],
    this.channel = 'b2c',
  });

  PublicCompaniesQuery copyWith({
    int? cityId,
    bool clearCityId = false,
    String? search,
    List<String>? companyTypes,
    String? channel,
  }) {
    return PublicCompaniesQuery(
      cityId: clearCityId ? null : (cityId ?? this.cityId),
      search: search ?? this.search,
      companyTypes: companyTypes ?? this.companyTypes,
      channel: channel ?? this.channel,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      'channel': channel,
      if (cityId != null) 'city_id': cityId,
      if (search.trim().isNotEmpty) 'search': search.trim(),
      if (companyTypes.isNotEmpty) 'company_type': companyTypes,
    };
  }
}
