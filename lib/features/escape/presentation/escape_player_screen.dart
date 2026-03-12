import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../../../core/widgets/sound_mixer_slider.dart';
import 'escape_controller.dart';
import '../../audio/presentation/audio_mixer_controller.dart';

class EscapePlayerScreen extends ConsumerStatefulWidget {
  final String environmentId;
  const EscapePlayerScreen({super.key, required this.environmentId});

  @override
  ConsumerState<EscapePlayerScreen> createState() => _EscapePlayerScreenState();
}

class _EscapePlayerScreenState extends ConsumerState<EscapePlayerScreen> {
  bool isPlaying = true;
  double volume = 0.7;
  double progress = 0.35;

  final envNames = ['Ocean Waves', 'Soft Rain', 'Forest Light', 'Starry Night', 'Calm Lake', 'Sunset Glow'];

  @override
  void initState() {
    super.initState();
    // Start session when screen loads if not already playing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(escapeProvider.notifier).startSession(15); // Default 15 min session
    });
  }

  @override
  Widget build(BuildContext context) {
    final escapeState = ref.watch(escapeProvider);
    final audioState = ref.watch(audioMixerProvider);
    final name = escapeState.currentEnvironment?.title ?? 'Environment';
    final isPlaying = escapeState.isPlaying;
    
    // Calculate progress
    final totalMin = escapeState.initialMin > 0 ? escapeState.initialMin : 1;
    final progress = 1.0 - (escapeState.minRemaining / totalMin);
    // Format timer
    final minRemainingStr = escapeState.minRemaining.toString().padLeft(2, '0');

    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Full-screen cinematic background
            if (escapeState.currentEnvironment != null)
              Image.network(
                escapeState.currentEnvironment!.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: AppColors.bgDark),
              ),
            // Gradient overlays to ensure readability and mood
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.bgDark.withValues(alpha: 0.5),
                    AppColors.bgDark.withValues(alpha: 0.75),
                    AppColors.bgDark.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
            // Light ambient glow
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: escapeState.currentEnvironment?.baseColor.withValues(alpha: 0.4) ?? AppColors.accent.withValues(alpha: 0.2),
                        blurRadius: 180,
                        spreadRadius: 80,
                      ),
                    ],
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(begin: 1.0, end: 1.2, duration: 4000.ms),
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
                      '$minRemainingStr:00',
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
                        widthFactor: progress.clamp(0.0, 1.0),
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
                        Text('0:00', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        Text('${escapeState.initialMin}:00', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Timer Options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [5, 10, 15, 30, 60].map((time) {
                        final isSelected = escapeState.initialMin == time;
                        return GestureDetector(
                          onTap: () {
                            ref.read(escapeProvider.notifier).startSession(time);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accent : AppColors.glassWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.accent : AppColors.glassBorder,
                              ),
                            ),
                            child: Text(
                              '${time}m',
                              style: TextStyle(
                                color: isSelected ? AppColors.bgDark : Colors.white,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ).animate().fadeIn(duration: 600.ms, delay: 500.ms),

                    const SizedBox(height: 32),

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
                          onTap: () {
                            if (isPlaying) {
                              ref.read(escapeProvider.notifier).pauseSession();
                            } else {
                              ref.read(escapeProvider.notifier).resumeSession();
                            }
                          },
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

                    // Layer Mixers
                    if (escapeState.currentEnvironment != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.glassWhite,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Column(
                          children: escapeState.currentEnvironment!.audioLayers.map((layer) {
                            final vol = audioState.volumes[layer.id] ?? layer.defaultVolume;
                            return SoundMixerSlider(
                              label: layer.name,
                              value: vol,
                              onChanged: (v) {
                                ref.read(audioMixerProvider.notifier).setVolume(layer.id, v);
                              },
                            );
                          }).toList(),
                        ),
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
