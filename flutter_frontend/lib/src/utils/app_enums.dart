import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';

enum Permissions { read, write, none }

enum ServiceStatus {
  pending('Pending', Iconsax.clock, Colors.orange),
  active('Active', Iconsax.verify, Colors.green),
  rejected('Rejected', Iconsax.close_circle, Colors.red),
  suspended('Suspended', Iconsax.warning_2, Colors.amber),
  cancelled('Cancelled', Iconsax.slash, Colors.grey);

  final String label;
  final IconData icon;
  final Color color;

  const ServiceStatus(this.label, this.icon, this.color);

  static ServiceStatus fromString(String? status) {
    if (status == null) return ServiceStatus.pending;
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
        return ServiceStatus.active;
      case 'rejected':
        return ServiceStatus.rejected;
      case 'suspended':
        return ServiceStatus.suspended;
      case 'cancelled':
        return ServiceStatus.cancelled;
      case 'pending':
      case 'requested':
      default:
        return ServiceStatus.pending;
    }
  }
}

enum BatteryType {
  gel('Gel'),
  tubular('Tubular'),
  lithium('Lithium');

  final String label;
  const BatteryType(this.label);
}

enum InverterType {
  offGrid('Off Grid'),
  onGrid('On Grid'),
  hybrid('Hybrid');

  final String label;
  const InverterType(this.label);
}

enum RequestStatus {
  open('Open', Iconsax.folder_open, Colors.blue),
  offered('Offered', Iconsax.document_text_1, Colors.orange),
  accepted('Accepted', Iconsax.tick_circle, Colors.purple),
  closed('Closed', Iconsax.folder_cross, Colors.grey);

  final String label;
  final IconData icon;
  final Color color;
  const RequestStatus(this.label, this.icon, this.color);
}

enum OfferStatus {
  pending('Pending', Iconsax.clock, Colors.orange),
  accepted('Accepted', Iconsax.verify, Colors.green),
  rejected('Rejected', Iconsax.close_circle, Colors.red),
  completed('Completed', Iconsax.document_text, Colors.blue);

  final String label;
  final IconData icon;
  final Color color;
  const OfferStatus(this.label, this.icon, this.color);
}

extension ServiceStatusL10n on ServiceStatus {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case ServiceStatus.pending:
        return l10n.status_pending;
      case ServiceStatus.active:
        return l10n.status_active;
      case ServiceStatus.rejected:
        return l10n.status_rejected;
      case ServiceStatus.suspended:
        return l10n.status_suspended;
      case ServiceStatus.cancelled:
        return l10n.status_cancelled;
    }
  }
}

extension BatteryTypeL10n on BatteryType {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case BatteryType.gel:
        return l10n.battery_type_gel;
      case BatteryType.tubular:
        return l10n.battery_type_tubular;
      case BatteryType.lithium:
        return l10n.battery_type_lithium;
    }
  }
}

extension InverterTypeL10n on InverterType {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case InverterType.offGrid:
        return l10n.inverter_type_off_grid;
      case InverterType.onGrid:
        return l10n.inverter_type_on_grid;
      case InverterType.hybrid:
        return l10n.inverter_type_hybrid;
    }
  }
}

extension RequestStatusL10n on RequestStatus {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case RequestStatus.open:
        return l10n.request_status_open;
      case RequestStatus.offered:
        return l10n.request_status_offered;
      case RequestStatus.accepted:
        return l10n.request_status_accepted;
      case RequestStatus.closed:
        return l10n.request_status_closed;
    }
  }
}

extension OfferStatusL10n on OfferStatus {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case OfferStatus.pending:
        return l10n.status_pending;
      case OfferStatus.accepted:
        return l10n.status_accepted;
      case OfferStatus.rejected:
        return l10n.status_rejected;
      case OfferStatus.completed:
        return l10n.status_completed;
    }
  }
}
