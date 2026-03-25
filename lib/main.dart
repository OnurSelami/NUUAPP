import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
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
import 'features/stats/presentation/stats_controller.dart';
import 'features/stats/presentation/analytics_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/settings/presentation/premium_screen.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/calm_pulse/domain/breath_pattern.dart';
import 'features/calm_pulse/presentation/calm_pulse_screen.dart';
import 'features/calm_pulse/presentation/breath_library_screen.dart';
import 'features/calm_pulse/presentation/guided_breath_screen.dart';
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

class NuuApp extends ConsumerStatefulWidget {
  const NuuApp({super.key});

  @override
  ConsumerState<NuuApp> createState() => _NuuAppState();
}

class _NuuAppState extends ConsumerState<NuuApp> {
  @override
  void initState() {
    super.initState();
    HomeWidget.setAppGroupId('group.com.nuu.nuu_app');

    // Foreground click handling
    HomeWidget.widgetClicked.listen(_handleWidgetDeepLink);

    // Background/Cold launch handling
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_handleWidgetDeepLink);
  }

  void _handleWidgetDeepLink(Uri? uri) {
    if (uri != null) {
      if (uri.host == 'calmpulse' || uri.path == '/calm-pulse') {
        _router.push('/calm-pulse');
      }
    }
  }

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
      path: '/analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
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
      path: '/guided-breath',
      builder: (context, state) {
        final pattern = state.extra as BreathPattern?;
        return GuidedBreathScreen(pattern: pattern ?? BreathingPatterns.resonance);
      },
    ),
    GoRoute(
      path: '/breathe',
      builder: (context, state) => const BreathLibraryScreen(),
    ),
  ],
);
