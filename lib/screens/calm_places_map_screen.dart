import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/screen_wrapper.dart';
import '../widgets/glass_card.dart';
import '../widgets/bottom_nav.dart';

class CalmPlacesMapScreen extends StatelessWidget {
  const CalmPlacesMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final places = [
      _Place('City Botanical Garden', '0.5 miles', 'Nature, Quiet'),
      _Place('Zen Coffee House', '1.2 miles', 'Cafe, Ambient'),
      _Place('Riverside Walk', '2.0 miles', 'Nature, Open Space'),
    ];

    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, color: AppColors.accent, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Calm Places',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms),
                    const SizedBox(height: 8),
                    Text(
                      'Discover quiet spaces near you',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

                    const SizedBox(height: 32),

                    // Map placeholder
                    GlassCard(
                      padding: const EdgeInsets.all(0),
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(LucideIcons.map, color: Colors.white.withValues(alpha: 0.1), size: 100),
                            Positioned(
                              top: 100,
                              left: 150,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                  boxShadow: AppColors.accentGlow(blur: 20),
                                ),
                                child: const Icon(Icons.my_location, color: Colors.white, size: 14),
                              )
                                  .animate(onPlay: (c) => c.repeat(reverse: true))
                                  .scaleXY(begin: 1, end: 1.2, duration: 1500.ms),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 32),

                    const Text(
                      'Nearby Discoveries',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                    const SizedBox(height: 16),

                    // Places list
                    ...places.asMap().entries.map((entry) {
                      final i = entry.key;
                      final place = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(LucideIcons.image, color: Colors.white54, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(place.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(place.distance, style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(place.tags, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Icon(LucideIcons.chevronRight, color: AppColors.textSecondary, size: 20),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: Duration(milliseconds: 500 + i * 100))
                            .slideY(begin: 0.1, end: 0),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const BottomNav(),
          ],
        ),
      ),
    );
  }
}

class _Place {
  final String name;
  final String distance;
  final String tags;
  _Place(this.name, this.distance, this.tags);
}
