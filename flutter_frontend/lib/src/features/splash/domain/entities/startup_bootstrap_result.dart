class StartupBootstrapResult {
  final String route;
  final bool shouldRefreshConfigs;
  final bool shouldRefreshProfile;

  const StartupBootstrapResult({
    required this.route,
    required this.shouldRefreshConfigs,
    required this.shouldRefreshProfile,
  });
}
