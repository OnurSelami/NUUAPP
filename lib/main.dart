import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/onboarding/onboarding_screen_1.dart';
import 'core/routing/onboarding/onboarding_screen_2.dart';
import 'core/routing/onboarding/onboarding_screen_3.dart';
import 'core/routing/home_screen.dart';
import 'features/escape/presentation/escape_environment_screen.dart';
import 'features/escape/presentation/escape_player_screen.dart';
import 'features/focus/presentation/focus_mode_screen.dart';
import 'features/sleep/presentation/sleep_mode_screen.dart';
import 'features/stats/presentation/statistics_screen.dart';
import 'features/stats/presentation/stats_controller.dart';
import 'features/calm_places/presentation/calm_places_home_screen.dart';
import 'features/calm_places/presentation/calm_places_map_screen.dart';
import 'features/calm_places/presentation/calm_places_list_screen.dart';
import 'features/calm_places/presentation/saved_places_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/settings/presentation/premium_screen.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/calm_pulse/presentation/calm_pulse_screen.dart';
import 'features/tactile/presentation/tactile_menu_screen.dart';
import 'features/calm_places/presentation/go_mode_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const NuuApp(),
    ),
  );
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
  initialLocation: '/auth',
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
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
      builder: (context, state) => const CalmPlacesHomeScreen(),
    ),
    GoRoute(
      path: '/calm-places/map',
      builder: (context, state) => const CalmPlacesMapScreen(),
    ),
    GoRoute(
      path: '/calm-places/list',
      builder: (context, state) => const CalmPlacesListScreen(),
    ),
    GoRoute(
      path: '/calm-places/saved',
      builder: (context, state) => const SavedPlacesScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumScreen(),
    ),
    GoRoute(
      path: '/calm-pulse',
      builder: (context, state) => const CalmPulseScreen(),
    ),
    GoRoute(
      path: '/tactile',
      builder: (context, state) => const TactileMenuScreen(),
    ),
    GoRoute(
      path: '/go-mode',
      builder: (context, state) => const GoModeScreen(),
    ),
  ],
);
