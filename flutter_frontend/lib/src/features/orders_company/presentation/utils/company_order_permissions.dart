import 'package:solar_hub/src/shared/domain/company/company.dart';

class CompanyOrderPermissions {
  final bool canChangeOrderStatus;
  final bool canEditOrderDetails;

  const CompanyOrderPermissions({
    required this.canChangeOrderStatus,
    required this.canEditOrderDetails,
  });

  factory CompanyOrderPermissions.fromCompany(Company? company) {
    final role = company?.memberRole?.toLowerCase();
    final isManagerOrAdmin = role == 'admin' || role == 'manager';
    final canChangeOrderStatus =
        isManagerOrAdmin || company?.permissionValue('sales') == 'write';

    return CompanyOrderPermissions(
      canChangeOrderStatus: canChangeOrderStatus,
      canEditOrderDetails: isManagerOrAdmin,
    );
  }
}
