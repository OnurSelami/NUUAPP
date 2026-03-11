import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/screen_wrapper.dart';

class EscapePlayerScreen extends StatefulWidget {
  final String environmentId;
  const EscapePlayerScreen({super.key, required this.environmentId});

  @override
  State<EscapePlayerScreen> createState() => _EscapePlayerScreenState();
}

class _EscapePlayerScreenState extends State<EscapePlayerScreen> {
  bool isPlaying = true;
  double volume = 0.7;
  double progress = 0.35;

  final envNames = ['Ocean Waves', 'Soft Rain', 'Forest Light', 'Starry Night', 'Calm Lake', 'Sunset Glow'];

  @override
  Widget build(BuildContext context) {
    final idx = int.tryParse(widget.environmentId) ?? 0;
    final name = idx < envNames.length ? envNames[idx] : 'Environment';

    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Ambient glow
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        blurRadius: 150,
                        spreadRadius: 80,
                      ),
                    ],
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(begin: 1, end: 1.15, duration: 4000.ms),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/escape'),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.glassWhite,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                          ),
                        ),
                        Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.glassWhite,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(LucideIcons.heart, color: Colors.white, size: 20),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms),

                    const Spacer(),

                    // Timer display
                    Text(
                      '12:45',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(color: AppColors.accent.withValues(alpha: 0.5), blurRadius: 30),
                        ],
                      ),
                    ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                    const SizedBox(height: 8),
                    Text('remaining', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),

                    const SizedBox(height: 48),

                    // Progress bar
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.glassWhite,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('5:15', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        Text('15:00', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ControlButton(
                          icon: LucideIcons.skipBack,
                          size: 48,
                          onTap: () {},
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: () => setState(() => isPlaying = !isPlaying),
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: AppColors.accentGradient,
                              shape: BoxShape.circle,
                              boxShadow: AppColors.accentGlow(blur: 30, opacity: 0.4),
                            ),
                            child: Icon(
                              isPlaying ? LucideIcons.pause : LucideIcons.play,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        _ControlButton(
                          icon: LucideIcons.skipForward,
                          size: 48,
                          onTap: () {},
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 600.ms),

                    const SizedBox(height: 40),

                    // Volume
                    Row(
                      children: [
                        Icon(LucideIcons.volume2, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: AppColors.accent,
                              inactiveTrackColor: AppColors.glassWhite,
                              thumbColor: AppColors.accent,
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            ),
                            child: Slider(
                              value: volume,
                              onChanged: (v) => setState(() => volume = v),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 800.ms),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _ControlButton({required this.icon, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.glassWhite,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.4),
      ),
    );
  }
}
