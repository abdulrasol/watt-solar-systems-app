import 'package:flutter_riverpod/legacy.dart';
import 'package:solar_hub/src/core/flags/feature_flags.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

final isAuthEnabled = StateProvider<bool>((ref) => isFeatureEnabled(ref, AppFeature.auth));
final isStoreEnabled = StateProvider<bool>((ref) => isFeatureEnabled(ref, AppFeature.store));
final isPosterEnabled = StateProvider<bool>((ref) => isFeatureEnabled(ref, AppFeature.posters));
final isOffersEnabled = StateProvider<bool>((ref) => isFeatureEnabled(ref, AppFeature.offers));
final isCommunityEnabled = StateProvider<bool>((ref) => isFeatureEnabled(ref, AppFeature.community));
final isCompaniesEnabled = StateProvider<bool>((ref) => isFeatureEnabled(ref, AppFeature.companies));
final isCompanyEnabled = StateProvider<bool>((ref) => isFeatureEnabled(ref, AppFeature.company));
final isNotificationsEnabled = StateProvider<bool>((ref) => isFeatureEnabled(ref, AppFeature.notifications));
final isservicesEnabled = StateProvider<bool>((ref) => isFeatureEnabled(ref, AppFeature.services));
final isSystemsEnabled = StateProvider<bool>((ref) => isFeatureEnabled(ref, AppFeature.systems));
