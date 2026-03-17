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
    // Format timer
    final minDisplay = escapeState.minutesDisplay.toString().padLeft(2, '0');
    final secDisplay = escapeState.secondsDisplay.toString().padLeft(2, '0');
    final totalMinutes = escapeState.totalSeconds ~/ 60;

    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
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
                    AppColors.bgDark.withValues(alpha: 0.6),
                    AppColors.bgDark.withValues(alpha: 0.85),
                    AppColors.bgDark.withValues(alpha: 0.98),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
            
            // Subtle slow pulse for atmospheric feel
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 1.5,
                  height: MediaQuery.of(context).size.width * 1.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: escapeState.currentEnvironment?.baseColor.withValues(alpha: 0.15) ?? AppColors.sageGreen.withValues(alpha: 0.1),
                        blurRadius: 180,
                        spreadRadius: 80,
                      ),
                    ],
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(begin: 1.0, end: 1.1, duration: 6000.ms),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ref.read(escapeProvider.notifier).stopSession();
                            context.go('/escape');
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary, size: 24),
                        ),
                        Text(
                          'ESCAPE',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4.0,
                          ),
                        ),
                        Icon(LucideIcons.headphones, color: AppColors.sageGreen, size: 20),
                      ],
                    ).animate().fadeIn(duration: 600.ms),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.15),

                    // Title
                    Text(
                      name,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 16, letterSpacing: 2.0, fontWeight: FontWeight.w500),
                    ).animate().fadeIn(duration: 800.ms, delay: 100.ms),
                    const SizedBox(height: 16),

                    // Timer display
                    Text(
                      '$minDisplay:$secDisplay',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 80,
                        fontWeight: FontWeight.w200,
                        letterSpacing: -2,
                        height: 1.0,
                        shadows: isPlaying ? [Shadow(color: AppColors.sageGreen.withValues(alpha: 0.3), blurRadius: 40)] : [],
                      ),
                    ).animate().fadeIn(duration: 800.ms, delay: 200.ms),

                    const SizedBox(height: 60),

                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (isPlaying) {
                              ref.read(escapeProvider.notifier).pauseSession();
                            } else {
                              ref.read(escapeProvider.notifier).resumeSession();
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPlaying ? AppColors.glassHover : Colors.transparent,
                              border: Border.all(
                                color: isPlaying ? AppColors.sageGreen : AppColors.glassBorder,
                                width: 1,
                              ),
                              boxShadow: isPlaying ? AppColors.glow(color: AppColors.sageGreen, blur: 40, opacity: 0.2) : [],
                            ),
                            child: Icon(
                              isPlaying ? LucideIcons.pause : LucideIcons.play,
                              color: isPlaying ? AppColors.textPrimary : AppColors.textSecondary,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                    const SizedBox(height: 60),
                    
                    // Duration Selection (Pills)
                    const Text(
                      'DURATION',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2.0),
                    ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [5, 10, 15, 30, 60].map((time) {
                          final isSelected = totalMinutes == time;
                          return GestureDetector(
                            onTap: () {
                              ref.read(escapeProvider.notifier).startSession(time);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.glassHover : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected ? AppColors.glassBorder : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                '${time}m',
                                style: TextStyle(
                                  color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 600.ms),

                    const SizedBox(height: 40),

                    // Layer Mixers
                    if (escapeState.currentEnvironment != null)
                      Column(
                        children: [
                          const Text(
                            'MIXER',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2.0),
                          ).animate().fadeIn(duration: 600.ms, delay: 700.ms),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.glassWhite, // Minimal glass backdrop
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.glassBorder, width: 0.5),
                            ),
                            child: Column(
                              children: escapeState.currentEnvironment!.audioLayers.map((layer) {
                                final vol = audioState.volumes[layer.id] ?? layer.defaultVolume;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: SoundMixerSlider(
                                    label: layer.name,
                                    value: vol,
                                    onChanged: (v) {
                                      ref.read(audioMixerProvider.notifier).setVolume(layer.id, v);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ).animate().fadeIn(duration: 600.ms, delay: 800.ms),
                        ],
                      ),

                    const SizedBox(height: 80),
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
