import 'package:flutter/services.dart';

abstract class OrientationService {
  Future<void> forceLandscape();
  Future<void> restoreDefault();
}

class SystemOrientationService implements OrientationService {
  @override
  Future<void> forceLandscape() {
    return SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Future<void> restoreDefault() {
    return SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
