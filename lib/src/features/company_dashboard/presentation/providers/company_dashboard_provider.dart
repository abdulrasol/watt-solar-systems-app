import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Provider for tracking the selected page index in the company dashboard
final companyDashboardIndexProvider = StateProvider<int>((ref) => 0);

// Provider for tracking navigation history to allow 'goBack' functionality
final companyDashboardHistoryProvider = StateProvider<List<String>>((ref) => ['dashboard']);

class CompanyDashboardNotifier extends StateNotifier<void> {
  final Ref ref;

  CompanyDashboardNotifier(this.ref) : super(null);

  // Restricted pages for inactive subscriptions
  final List<int> _restrictedIndices = [3, 5, 6, 7, 9, 11, 12, 13, 14, 15];

  void changePage(int index, String routeName, {bool isSubscriptionActive = false, Function? onSubscriptionRequired}) {
    final currentIndex = ref.read(companyDashboardIndexProvider);
    if (currentIndex == index) return;

    // Check subscription status
    if (!isSubscriptionActive && _restrictedIndices.contains(index)) {
      if (onSubscriptionRequired != null) {
        onSubscriptionRequired();
      }
      return;
    }

    ref.read(companyDashboardIndexProvider.notifier).state = index;

    final history = ref.read(companyDashboardHistoryProvider);
    if (history.isEmpty || history.last != routeName) {
      ref.read(companyDashboardHistoryProvider.notifier).state = [...history, routeName];
    }
  }

  void goBack({bool isSubscriptionActive = false}) {
    final history = ref.read(companyDashboardHistoryProvider);
    if (history.length > 1) {
      final newHistory = List<String>.from(history)..removeLast();
      ref.read(companyDashboardHistoryProvider.notifier).state = newHistory;

      final previousRoute = newHistory.last;
      final newIndex = _getPageIndex(previousRoute);

      // Ensure we don't go back to a restricted page if subscription expired in meantime
      if (!isSubscriptionActive && _restrictedIndices.contains(newIndex)) {
        // Skip restricted page in history or go to dashboard
        changePage(0, 'dashboard', isSubscriptionActive: isSubscriptionActive);
        return;
      }

      ref.read(companyDashboardIndexProvider.notifier).state = newIndex;
    }
  }

  bool get canGoBack {
    return ref.read(companyDashboardHistoryProvider).length > 1;
  }

  int _getPageIndex(String route) {
    switch (route) {
      case 'dashboard':
        return 0;
      case 'profile':
        return 1;
      case 'subscription':
        return 2;
      case 'offers':
        return 3;
      case 'inventory':
        return 4;
      case 'pos':
        return 5;
      case 'orders':
        return 6;
      case 'invoices':
        return 7;
      case 'accounting':
        return 8;
      case 'analytics':
        return 9;
      case 'members':
        return 10;
      case 'systems':
        return 11;
      case 'customers':
        return 12;
      case 'suppliers':
        return 13;
      case 'my_purchases':
        return 14;
      case 'delivery':
        return 15;
      default:
        return 0;
    }
  }
}

final companyDashboardControllerProvider = StateNotifierProvider<CompanyDashboardNotifier, void>((ref) {
  return CompanyDashboardNotifier(ref);
});
