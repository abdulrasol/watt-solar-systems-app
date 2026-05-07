import 'package:flutter_riverpod/legacy.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

final isAuthEnabled = StateProvider<bool>((ref) => isEnabled(ref, 'auth'));
final isStoreEnabled = StateProvider<bool>((ref) => isEnabled(ref, 'store'));
final isPosterEnabled = StateProvider<bool>((ref) => isEnabled(ref, 'posters'));
final isOffersEnabled = StateProvider<bool>((ref) => isEnabled(ref, 'offers'));
final isCommunityEnabled = StateProvider<bool>((ref) => isEnabled(ref, 'community'));
final isCompaniesEnabled = StateProvider<bool>((ref) => isEnabled(ref, 'companies'));
final isCompanyEnabled = StateProvider<bool>((ref) => isEnabled(ref, 'company'));
final isNotificationsEnabled = StateProvider<bool>((ref) => isEnabled(ref, 'notifications'));
final isservicesEnabled = StateProvider<bool>((ref) => isEnabled(ref, 'services'));
final isSystemsEnabled = StateProvider<bool>((ref) => isEnabled(ref, 'systems'));
