import 'package:solar_hub/src/shared/domain/company/company.dart';

class PublicCompaniesResult {
  final List<Company> items;
  final int count;
  final String channel;

  const PublicCompaniesResult({
    required this.items,
    required this.count,
    required this.channel,
  });
}
