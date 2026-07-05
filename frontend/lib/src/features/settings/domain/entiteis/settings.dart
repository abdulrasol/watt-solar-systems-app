class Settings {
  bool isDark;
  bool isNotificationEnabled;
  String language;
  bool saveRolePageSelection;
  String? saveRolePageSelectionRoute;
  Settings({
    required this.isDark,
    required this.isNotificationEnabled,
    required this.language,
    required this.saveRolePageSelection,
    this.saveRolePageSelectionRoute,
  });

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    isDark: json['isDark'],
    isNotificationEnabled: json['isNotificationEnabled'],
    language: json['language'],
    saveRolePageSelection: json['saveRolePageSelection'],
    saveRolePageSelectionRoute: json['saveRolePageSelectionRoute'],
  );

  Map<String, dynamic> toJson() => {
    'isDark': isDark,
    'isNotificationEnabled': isNotificationEnabled,
    'language': language,
    'saveRolePageSelection': saveRolePageSelection,
    'saveRolePageSelectionRoute': saveRolePageSelectionRoute,
  };
}
