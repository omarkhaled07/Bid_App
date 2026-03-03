import 'package:bid/app_startup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveStartupRoute', () {
    test('returns onboarding when onboarding is not seen', () {
      expect(
        resolveStartupRoute(hasSeenOnboarding: false, isLoggedIn: false),
        StartupRoute.onboarding,
      );
      expect(
        resolveStartupRoute(hasSeenOnboarding: false, isLoggedIn: true),
        StartupRoute.onboarding,
      );
    });

    test('returns login when onboarding is seen but user is not logged in', () {
      expect(
        resolveStartupRoute(hasSeenOnboarding: true, isLoggedIn: false),
        StartupRoute.login,
      );
    });

    test('returns home when onboarding is seen and user is logged in', () {
      expect(
        resolveStartupRoute(hasSeenOnboarding: true, isLoggedIn: true),
        StartupRoute.home,
      );
    });
  });
}
