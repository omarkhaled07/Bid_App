enum StartupRoute {
  onboarding,
  login,
  home,
}

StartupRoute resolveStartupRoute({
  required bool hasSeenOnboarding,
  required bool isLoggedIn,
}) {
  if (!hasSeenOnboarding) {
    return StartupRoute.onboarding;
  }
  if (isLoggedIn) {
    return StartupRoute.home;
  }
  return StartupRoute.login;
}
