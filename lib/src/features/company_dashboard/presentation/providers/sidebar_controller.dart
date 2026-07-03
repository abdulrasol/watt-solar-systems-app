import 'package:flutter_riverpod/flutter_riverpod.dart';

final sidebarControllerProvider =
    NotifierProvider<SidebarController, bool>(SidebarController.new);

class SidebarController extends Notifier<bool> {
  @override
  bool build() {
    // Default: Not collapsed
    return false;
  }

  void toggle() => state = !state;
  void collapse() => state = true;
  void expand() => state = false;
}
