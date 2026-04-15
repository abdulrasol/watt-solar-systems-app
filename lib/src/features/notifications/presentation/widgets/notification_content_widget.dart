import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/notifications/domain/entities/notification_type.dart';

/// Renders the `data.content` map from a notification as structured UI,
/// adapting layout to each notification type.
class NotificationContentWidget extends StatelessWidget {
  final NotificationType type;
  final Map<String, dynamic> content;
  final bool isDark;

  const NotificationContentWidget({
    super.key,
    required this.type,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: isDark ? 0.10 : 0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: type.color.withValues(alpha: isDark ? 0.25 : 0.18),
        ),
      ),
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (type) {
      case NotificationType.serviceRequest:
        return _ServiceRequestContent(content: content, isDark: isDark);
      case NotificationType.subscriptionRequest:
        return _SubscriptionRequestContent(content: content, isDark: isDark);
      case NotificationType.companyActivationReminder:
        return _CompanyActivationContent(content: content, isDark: isDark);
      case NotificationType.service:
        return _ServiceContent(content: content, isDark: isDark);
      case NotificationType.offerRequest:
        return _OfferRequestContent(content: content, isDark: isDark);
      case NotificationType.offer:
        return _OfferContent(content: content, isDark: isDark);
      case NotificationType.invite:
        return _InviteContent(content: content, isDark: isDark);
      case NotificationType.memberRemove:
        return _MemberRemoveContent(content: content, isDark: isDark);
      case NotificationType.unknown:
        return _GenericContent(content: content, isDark: isDark);
    }
  }
}

// ─── Shared helpers ──────────────────────────────────────────────────────────

Widget _infoRow({
  required IconData icon,
  required String label,
  required String value,
  required Color color,
  required bool isDark,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _sectionTitle(String text, Color color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.5,
      ),
    ),
  );
}

// ─── Per-type content widgets ─────────────────────────────────────────────────

/// service_request — contains company info about who sent/received the request
class _ServiceRequestContent extends StatelessWidget {
  final Map<String, dynamic> content;
  final bool isDark;
  const _ServiceRequestContent({required this.content, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = NotificationType.serviceRequest.color;
    final companyName = content['company_name']?.toString() ?? '-';
    final serviceCode = content['service_code']?.toString();
    final serviceName = content['service_name']?.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('SERVICE REQUEST', color),
        _infoRow(icon: Iconsax.buildings_2_bold, label: 'Company', value: companyName, color: color, isDark: isDark),
        if (serviceName != null)
          _infoRow(icon: Iconsax.category_2_bold, label: 'Service', value: serviceName, color: color, isDark: isDark),
        if (serviceCode != null)
          _infoRow(icon: Iconsax.code_bold, label: 'Code', value: serviceCode, color: color, isDark: isDark),
      ],
    );
  }
}

/// subscription_request — admin-facing
class _SubscriptionRequestContent extends StatelessWidget {
  final Map<String, dynamic> content;
  final bool isDark;
  const _SubscriptionRequestContent({required this.content, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = NotificationType.subscriptionRequest.color;
    final companyName = content['company_name']?.toString() ?? '-';
    final companyId = content['company_id']?.toString();
    final plan = content['plan']?.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('SUBSCRIPTION REQUEST', color),
        _infoRow(icon: Iconsax.buildings_2_bold, label: 'Company', value: companyName, color: color, isDark: isDark),
        if (companyId != null)
          _infoRow(icon: Iconsax.hashtag_bold, label: 'Company ID', value: '#$companyId', color: color, isDark: isDark),
        if (plan != null)
          _infoRow(icon: Iconsax.receipt_1_bold, label: 'Plan', value: plan, color: color, isDark: isDark),
      ],
    );
  }
}

/// company_activation_reminder — admin-facing: company awaiting activation
class _CompanyActivationContent extends StatelessWidget {
  final Map<String, dynamic> content;
  final bool isDark;
  const _CompanyActivationContent({required this.content, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = NotificationType.companyActivationReminder.color;
    final companyName = content['company_name']?.toString() ?? '-';
    final companyId = content['company_id']?.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('ACTIVATION REMINDER', color),
        _infoRow(icon: Iconsax.buildings_2_bold, label: 'Company', value: companyName, color: color, isDark: isDark),
        if (companyId != null)
          _infoRow(icon: Iconsax.hashtag_bold, label: 'ID', value: '#$companyId', color: color, isDark: isDark),
      ],
    );
  }
}

/// service — status update on a service the company applied for
class _ServiceContent extends StatelessWidget {
  final Map<String, dynamic> content;
  final bool isDark;
  const _ServiceContent({required this.content, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = NotificationType.service.color;
    final serviceName = content['service_name']?.toString() ?? '-';
    final serviceCode = content['service_code']?.toString();
    final status = content['status']?.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('SERVICE UPDATE', color),
        _infoRow(icon: Iconsax.category_2_bold, label: 'Service', value: serviceName, color: color, isDark: isDark),
        if (serviceCode != null)
          _infoRow(icon: Iconsax.code_bold, label: 'Code', value: serviceCode, color: color, isDark: isDark),
        if (status != null)
          _infoRow(icon: Iconsax.tick_circle_bold, label: 'Status', value: status, color: color, isDark: isDark),
      ],
    );
  }
}

/// offer_request — a new solar system offer request
class _OfferRequestContent extends StatelessWidget {
  final Map<String, dynamic> content;
  final bool isDark;
  const _OfferRequestContent({required this.content, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = NotificationType.offerRequest.color;
    final requestId = content['request_id']?.toString();
    final cityName = content['city']?.toString();
    final panelPower = content['total_panel_power']?.toString();
    final batteryPower = content['total_battery_power']?.toString();
    final inverterPower = content['total_inverters_power']?.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('OFFER REQUEST', color),
        if (requestId != null)
          _infoRow(icon: Iconsax.hashtag_bold, label: 'Request', value: '#$requestId', color: color, isDark: isDark),
        if (cityName != null)
          _infoRow(icon: Iconsax.location_bold, label: 'City', value: cityName, color: color, isDark: isDark),
        if (panelPower != null)
          _infoRow(icon: Iconsax.sun_1_bold, label: 'Solar', value: '${panelPower}W', color: color, isDark: isDark),
        if (batteryPower != null)
          _infoRow(icon: Iconsax.battery_charging_bold, label: 'Battery', value: '${batteryPower}KWh', color: color, isDark: isDark),
        if (inverterPower != null)
          _infoRow(icon: Iconsax.flash_1_bold, label: 'Inverter', value: '${inverterPower}KW', color: color, isDark: isDark),
      ],
    );
  }
}

/// offer — an offer received on a user's request
class _OfferContent extends StatelessWidget {
  final Map<String, dynamic> content;
  final bool isDark;
  const _OfferContent({required this.content, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = NotificationType.offer.color;
    final companyName = content['company_name']?.toString() ?? '-';
    final price = content['price']?.toString();
    final offerId = content['offer_id']?.toString();
    final requestId = content['request_id']?.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('OFFER RECEIVED', color),
        _infoRow(icon: Iconsax.buildings_2_bold, label: 'Company', value: companyName, color: color, isDark: isDark),
        if (price != null)
          _infoRow(icon: Iconsax.dollar_circle_bold, label: 'Price', value: '\$$price', color: color, isDark: isDark),
        if (requestId != null)
          _infoRow(icon: Iconsax.hashtag_bold, label: 'Request', value: '#$requestId', color: color, isDark: isDark),
        if (offerId != null)
          _infoRow(icon: Iconsax.tag_bold, label: 'Offer', value: '#$offerId', color: color, isDark: isDark),
      ],
    );
  }
}

/// invite — user was invited to a company
class _InviteContent extends StatelessWidget {
  final Map<String, dynamic> content;
  final bool isDark;
  const _InviteContent({required this.content, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = NotificationType.invite.color;
    final companyName = content['company_name']?.toString() ?? '-';
    final role = content['role']?.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('COMPANY INVITATION', color),
        _infoRow(icon: Iconsax.buildings_2_bold, label: 'Company', value: companyName, color: color, isDark: isDark),
        if (role != null)
          _infoRow(icon: Iconsax.profile_circle_bold, label: 'Role', value: role, color: color, isDark: isDark),
      ],
    );
  }
}

/// member-remove — user's membership was terminated
class _MemberRemoveContent extends StatelessWidget {
  final Map<String, dynamic> content;
  final bool isDark;
  const _MemberRemoveContent({required this.content, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = NotificationType.memberRemove.color;
    final companyName = content['company_name']?.toString() ?? '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('MEMBERSHIP REMOVED', color),
        _infoRow(icon: Iconsax.buildings_2_bold, label: 'Company', value: companyName, color: color, isDark: isDark),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(Iconsax.info_circle_bold, size: 13, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Your membership with this company has been terminated.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Fallback: show all key-value pairs generically
class _GenericContent extends StatelessWidget {
  final Map<String, dynamic> content;
  final bool isDark;
  const _GenericContent({required this.content, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content.entries
          .map(
            (e) => _infoRow(
              icon: Iconsax.info_circle_bold,
              label: e.key,
              value: e.value?.toString() ?? '-',
              color: const Color(0xFF9CA3AF),
              isDark: isDark,
            ),
          )
          .toList(),
    );
  }
}
