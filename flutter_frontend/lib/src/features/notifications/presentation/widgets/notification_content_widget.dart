import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/features/notifications/domain/entities/notification_type.dart';

/// Renders the `data.content` map from a notification as structured UI,
/// adapting layout to each notification type.
class NotificationContentWidget extends StatelessWidget {
  final NotificationType type;
  final Map<String, dynamic> content;
  final bool isDark;

  const NotificationContentWidget({super.key, required this.type, required this.content, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: isDark ? 0.10 : 0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: type.color.withValues(alpha: isDark ? 0.25 : 0.18)),
      ),
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (type) {
      case NotificationType.subscriptionRequest:
        return _SubscriptionRequestContent(content: content, isDark: isDark);
      case NotificationType.companyActivationReminder:
        return _CompanyActivationContent(content: content, isDark: isDark);
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

Widget _infoRow({required IconData icon, required String label, required String value, required Color color, required bool isDark}) {
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
              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[800], height: 1.4),
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
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5),
    ),
  );
}

// ─── Per-type content widgets ─────────────────────────────────────────────────

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
        _infoRow(icon: Iconsax.buildings_2, label: 'Company', value: companyName, color: color, isDark: isDark),
        if (companyId != null) _infoRow(icon: Iconsax.hashtag, label: 'Company ID', value: '#$companyId', color: color, isDark: isDark),
        if (plan != null) _infoRow(icon: Iconsax.receipt_1, label: 'Plan', value: plan, color: color, isDark: isDark),
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
        _infoRow(icon: Iconsax.buildings_2, label: 'Company', value: companyName, color: color, isDark: isDark),
        if (companyId != null) _infoRow(icon: Iconsax.hashtag, label: 'ID', value: '#$companyId', color: color, isDark: isDark),
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
        if (requestId != null) _infoRow(icon: Iconsax.hashtag, label: 'Request', value: '#$requestId', color: color, isDark: isDark),
        if (cityName != null) _infoRow(icon: Iconsax.location, label: 'City', value: cityName, color: color, isDark: isDark),
        if (panelPower != null) _infoRow(icon: Iconsax.sun_1, label: 'Solar', value: '${panelPower}W', color: color, isDark: isDark),
        if (batteryPower != null) _infoRow(icon: Iconsax.battery_charging, label: 'Battery', value: '${batteryPower}KWh', color: color, isDark: isDark),
        if (inverterPower != null) _infoRow(icon: Iconsax.flash_1, label: 'Inverter', value: '${inverterPower}KW', color: color, isDark: isDark),
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
        _infoRow(icon: Iconsax.buildings_2, label: 'Company', value: companyName, color: color, isDark: isDark),
        if (price != null) _infoRow(icon: Iconsax.dollar_circle, label: 'Price', value: '\$$price', color: color, isDark: isDark),
        if (requestId != null) _infoRow(icon: Iconsax.hashtag, label: 'Request', value: '#$requestId', color: color, isDark: isDark),
        if (offerId != null) _infoRow(icon: Iconsax.tag, label: 'Offer', value: '#$offerId', color: color, isDark: isDark),
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
        _infoRow(icon: Iconsax.buildings_2, label: 'Company', value: companyName, color: color, isDark: isDark),
        if (role != null) _infoRow(icon: Iconsax.profile_circle, label: 'Role', value: role, color: color, isDark: isDark),
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
        _infoRow(icon: Iconsax.buildings_2, label: 'Company', value: companyName, color: color, isDark: isDark),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(Iconsax.info_circle, size: 13, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Your membership with this company has been terminated.',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.4),
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
          .map((e) => _infoRow(icon: Iconsax.info_circle, label: e.key, value: e.value?.toString() ?? '-', color: const Color(0xFF9CA3AF), isDark: isDark))
          .toList(),
    );
  }
}
