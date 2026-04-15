import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

/// All notification types sent by the server.
enum NotificationType {
  serviceRequest,
  subscriptionRequest,
  companyActivationReminder,
  service,
  offerRequest,
  offer,
  invite,
  memberRemove,
  unknown;

  static NotificationType fromString(String? type) {
    switch (type) {
      case 'service_request':
        return NotificationType.serviceRequest;
      case 'subscription_request':
        return NotificationType.subscriptionRequest;
      case 'company_activation_reminder':
        return NotificationType.companyActivationReminder;
      case 'service':
        return NotificationType.service;
      case 'offer_request':
        return NotificationType.offerRequest;
      case 'offer':
        return NotificationType.offer;
      case 'invite':
        return NotificationType.invite;
      case 'member-remove':
        return NotificationType.memberRemove;
      default:
        return NotificationType.unknown;
    }
  }

  /// Icon to show inside the notification card avatar.
  IconData get icon {
    switch (this) {
      case NotificationType.serviceRequest:
        return Iconsax.briefcase_bold;
      case NotificationType.subscriptionRequest:
        return Iconsax.receipt_1_bold;
      case NotificationType.companyActivationReminder:
        return Iconsax.buildings_2_bold;
      case NotificationType.service:
        return Iconsax.category_2_bold;
      case NotificationType.offerRequest:
        return Iconsax.sun_1_bold;
      case NotificationType.offer:
        return Iconsax.tag_bold;
      case NotificationType.invite:
        return Iconsax.people_bold;
      case NotificationType.memberRemove:
        return Iconsax.close_circle_bold;
      case NotificationType.unknown:
        return Iconsax.notification_bing_bold;
    }
  }

  /// Accent colour for the avatar and action button.
  Color get color {
    switch (this) {
      case NotificationType.serviceRequest:
        return const Color(0xFF00BFA5); // teal primary
      case NotificationType.subscriptionRequest:
        return const Color(0xFF7C3AED); // violet
      case NotificationType.companyActivationReminder:
        return const Color(0xFFF59E0B); // amber
      case NotificationType.service:
        return const Color(0xFF0EA5E9); // sky blue
      case NotificationType.offerRequest:
        return const Color(0xFFF97316); // orange
      case NotificationType.offer:
        return const Color(0xFF10B981); // emerald
      case NotificationType.invite:
        return const Color(0xFF6366F1); // indigo
      case NotificationType.memberRemove:
        return const Color(0xFFEF4444); // red
      case NotificationType.unknown:
        return const Color(0xFF9CA3AF); // grey
    }
  }

  /// GoRouter path to push when the user taps the action button.
  /// Returns null when there is no meaningful destination.
  String? navigationRoute(Map<String, dynamic> content) {
    switch (this) {
      case NotificationType.serviceRequest:
        return '/companies/dashboard/services';
      case NotificationType.subscriptionRequest:
        return '/admin/service-requests';
      case NotificationType.companyActivationReminder:
        return '/admin/service-requests';
      case NotificationType.service:
        return '/services';
      case NotificationType.offerRequest:
        // User navigates to their requests screen
        return '/user-requests';
      case NotificationType.offer:
        return '/user-requests';
      case NotificationType.invite:
        // Go to dashboard — member now has a company
        return '/companies/dashboard';
      case NotificationType.memberRemove:
        return '/home';
      case NotificationType.unknown:
        return null;
    }
  }

  /// Human-readable label for the action button.
  String actionLabel(AppLocalizations l10n) {
    switch (this) {
      case NotificationType.serviceRequest:
        return l10n.notif_action_view_services;
      case NotificationType.subscriptionRequest:
        return l10n.notif_action_review_request;
      case NotificationType.companyActivationReminder:
        return l10n.notif_action_review_request;
      case NotificationType.service:
        return l10n.notif_action_view_services;
      case NotificationType.offerRequest:
        return l10n.notif_action_view_my_requests;
      case NotificationType.offer:
        return l10n.notif_action_view_offers;
      case NotificationType.invite:
        return l10n.notif_action_go_to_dashboard;
      case NotificationType.memberRemove:
        return l10n.notif_action_go_home;
      case NotificationType.unknown:
        return l10n.view;
    }
  }

  /// Human-readable name for the notification type badge.
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case NotificationType.serviceRequest:
        return l10n.notif_type_service_request;
      case NotificationType.subscriptionRequest:
        return l10n.notif_type_subscription_request;
      case NotificationType.companyActivationReminder:
        return l10n.notif_type_activation_reminder;
      case NotificationType.service:
        return l10n.notif_type_service_update;
      case NotificationType.offerRequest:
        return l10n.notif_type_offer_request;
      case NotificationType.offer:
        return l10n.notif_type_offer_received;
      case NotificationType.invite:
        return l10n.notif_type_invite;
      case NotificationType.memberRemove:
        return l10n.notif_type_member_remove;
      case NotificationType.unknown:
        return l10n.notifications;
    }
  }
}
