import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/splash_screen.dart';
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
import 'features/escape/presentation/calm_places_map_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/settings/presentation/premium_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.nuu.app.channel.audio',
    androidNotificationChannelName: 'NUU Ambient Audio',
    androidNotificationOngoing: true,
  );

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
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumScreen(),
    ),
  ],
);
