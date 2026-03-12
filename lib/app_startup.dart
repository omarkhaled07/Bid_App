enum StartupRoute {
  onboarding,
  login,
  home,
}

StartupRoute resolveStartupRoute({
  required bool hasSeenOnboarding,
  required bool isLoggedIn,
  required bool isGuestMode,
}) {
  if (!hasSeenOnboarding) {
    return StartupRoute.onboarding;
  }
  if (isLoggedIn || isGuestMode) {
    return StartupRoute.home;
  }
  return StartupRoute.login;
}
