import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateProvider;
import 'package:solar_hub/src/features/splash/presentation/providers/config_provider.dart';

enum HomeTab {
  dashboard(0),
  calculator(1),
  services(2),
  store(3),
  community(4);

  const HomeTab(this.indexValue);

  final int indexValue;

  static HomeTab fromIndex(int index) {
    return HomeTab.values.firstWhere(
      (tab) => tab.indexValue == index,
      orElse: () => HomeTab.dashboard,
    );
  }
}

class HomeNavigationState {
  final List<HomeTab> visibleTabs;

  const HomeNavigationState({required this.visibleTabs});

  bool isVisible(HomeTab tab) => visibleTabs.contains(tab);

  int sanitizeIndex(int selectedIndex) {
    final selectedTab = HomeTab.fromIndex(selectedIndex);
    return isVisible(selectedTab)
        ? selectedTab.indexValue
        : HomeTab.dashboard.indexValue;
  }

  int navIndexFor(int logicalIndex) {
    final safeIndex = sanitizeIndex(logicalIndex);
    final safeTab = HomeTab.fromIndex(safeIndex);
    return visibleTabs.indexOf(safeTab);
  }

  HomeTab visibleTabAt(int navIndex) {
    if (navIndex < 0 || navIndex >= visibleTabs.length) {
      return HomeTab.dashboard;
    }
    return visibleTabs[navIndex];
  }
}

final homePageIndexProvider = StateProvider<int>(
  (ref) => HomeTab.dashboard.indexValue,
);

final homeNavigationProvider = Provider<HomeNavigationState>((ref) {
  final configState = ref.watch(configProvider);
  final values = configState.values;

  final visibleTabs = <HomeTab>[
    HomeTab.dashboard,
    HomeTab.calculator,
  ];

  if (values['services'] ?? true) {
    visibleTabs.add(HomeTab.services);
  }
  if (values['store'] ?? false) {
    visibleTabs.add(HomeTab.store);
  }
  if (values['community'] ?? false) {
    visibleTabs.add(HomeTab.community);
  }

  return HomeNavigationState(visibleTabs: visibleTabs);
});

void selectHomeTab(WidgetRef ref, HomeTab tab) {
  final navigation = ref.read(homeNavigationProvider);
  ref.read(homePageIndexProvider.notifier).state = navigation.isVisible(tab)
      ? tab.indexValue
      : HomeTab.dashboard.indexValue;
}
