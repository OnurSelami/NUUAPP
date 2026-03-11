import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen_1.dart';
import 'screens/onboarding/onboarding_screen_2.dart';
import 'screens/onboarding/onboarding_screen_3.dart';
import 'screens/home_screen.dart';
import 'screens/escape_environment_screen.dart';
import 'screens/escape_player_screen.dart';
import 'screens/focus_mode_screen.dart';
import 'screens/sleep_mode_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/calm_places_map_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const NuuApp());
}

class NuuApp extends StatelessWidget {
  const NuuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NUU',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding-1',
      builder: (context, state) => const OnboardingScreen1(),
    ),
    GoRoute(
      path: '/onboarding-2',
      builder: (context, state) => const OnboardingScreen2(),
    ),
    GoRoute(
      path: '/onboarding-3',
      builder: (context, state) => const OnboardingScreen3(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/escape',
      builder: (context, state) => const EscapeEnvironmentScreen(),
    ),
    GoRoute(
      path: '/escape-player/:id',
      builder: (context, state) => EscapePlayerScreen(
        environmentId: state.pathParameters['id'] ?? '0',
      ),
    ),
    GoRoute(
      path: '/focus',
      builder: (context, state) => const FocusModeScreen(),
    ),
    GoRoute(
      path: '/sleep',
      builder: (context, state) => const SleepModeScreen(),
    ),
    GoRoute(
      path: '/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),
    GoRoute(
      path: '/calm-places',
      builder: (context, state) => const CalmPlacesMapScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
