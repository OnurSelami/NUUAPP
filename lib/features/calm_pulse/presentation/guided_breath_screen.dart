import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../../activities/domain/user_activity.dart';
import '../../activities/presentation/activity_log_controller.dart';
import '../../stats/presentation/stats_controller.dart';
import '../domain/breath_pattern.dart';
import 'widgets/feeling_prompt_sheet.dart';

enum BreathPhase { ready, inhale, hold1, exhale, hold2 }

class GuidedBreathScreen extends ConsumerStatefulWidget {
  final BreathPattern pattern;
  const GuidedBreathScreen({super.key, this.pattern = BreathingPatterns.resonance});

  @override
  ConsumerState<GuidedBreathScreen> createState() => _GuidedBreathScreenState();
}

class _GuidedBreathScreenState extends ConsumerState<GuidedBreathScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  
  bool _isPlaying = false;
  BreathPhase _currentPhase = BreathPhase.ready;
  int _secondsLeftInPhase = 0;
  
  int _totalElapsedSeconds = 0;
  int _cyclesCompleted = 0;
  DateTime? _sessionStartTime;
  
  Timer? _engineTimer;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      value: 0.0, 
    );
  }
  
  @override
  void dispose() {
    _engineTimer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pauseSession();
    } else {
      _playSession();
    }
  }

  void _playSession() {
    if (_currentPhase == BreathPhase.ready) {
      _sessionStartTime = DateTime.now();
      _startPhase(BreathPhase.inhale);
    } else {
      _resumePhaseAnimation();
    }
    setState(() => _isPlaying = true);
    
    _engineTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _onTick();
    });
    HapticFeedback.lightImpact();
  }

  void _pauseSession() {
    setState(() => _isPlaying = false);
    _engineTimer?.cancel();
    _scaleController.stop();
    HapticFeedback.lightImpact();
  }

  Future<void> _stopSession() async {
    _pauseSession();
    await _logSessionIfValid();
    
    if (!mounted) return;
    setState(() {
      _currentPhase = BreathPhase.ready;
      _totalElapsedSeconds = 0;
      _cyclesCompleted = 0;
      _secondsLeftInPhase = 0;
    });
    _scaleController.animateTo(0.0, duration: const Duration(milliseconds: 800), curve: Curves.easeOut);
  }

  void _onTick() {
    if (!_isPlaying) return;
    
    setState(() {
      _totalElapsedSeconds++;
      if (_secondsLeftInPhase > 0) {
        _secondsLeftInPhase--;
        // Tick on every second if holding, else silent rhythm
        if (_currentPhase == BreathPhase.hold1 || _currentPhase == BreathPhase.hold2) {
          HapticFeedback.selectionClick();
        }
      }
      
      if (_secondsLeftInPhase == 0) {
        _advancePhase();
      }
    });
  }

  void _advancePhase() {
    HapticFeedback.heavyImpact(); 
    
    switch (_currentPhase) {
      case BreathPhase.inhale:
        if (widget.pattern.hold1Seconds > 0) {
          _startPhase(BreathPhase.hold1);
        } else {
          _startPhase(BreathPhase.exhale);
        }
        break;
      case BreathPhase.hold1:
        _startPhase(BreathPhase.exhale);
        break;
      case BreathPhase.exhale:
        if (widget.pattern.hold2Seconds > 0) {
          _startPhase(BreathPhase.hold2);
        } else {
          _cyclesCompleted++;
          if (_cyclesCompleted == 3) {
            _showSuccessFeedback();
          }
          _startPhase(BreathPhase.inhale);
        }
        break;
      case BreathPhase.hold2:
        _cyclesCompleted++;
        if (_cyclesCompleted == 3) {
          _showSuccessFeedback();
        }
        _startPhase(BreathPhase.inhale);
        break;
      case BreathPhase.ready:
        _startPhase(BreathPhase.inhale);
        break;
    }
  }

  void _startPhase(BreathPhase nextPhase) {
    setState(() {
      _currentPhase = nextPhase;
      switch (nextPhase) {
        case BreathPhase.inhale:
          _secondsLeftInPhase = widget.pattern.inhaleSeconds;
          _scaleController.duration = Duration(seconds: widget.pattern.inhaleSeconds);
          _scaleController.forward(from: 0.0);
          break;
        case BreathPhase.hold1:
          _secondsLeftInPhase = widget.pattern.hold1Seconds;
          break;
        case BreathPhase.exhale:
          _secondsLeftInPhase = widget.pattern.exhaleSeconds;
          _scaleController.duration = Duration(seconds: widget.pattern.exhaleSeconds);
          _scaleController.reverse(from: 1.0);
          break;
        case BreathPhase.hold2:
          _secondsLeftInPhase = widget.pattern.hold2Seconds;
          break;
        case BreathPhase.ready:
          _secondsLeftInPhase = 0;
          break;
      }
    });
  }

  void _resumePhaseAnimation() {
    if (_currentPhase == BreathPhase.inhale) {
      _scaleController.forward();
    } else if (_currentPhase == BreathPhase.exhale) {
      _scaleController.reverse();
    }
  }

  Future<void> _logSessionIfValid() async {
    if (_sessionStartTime == null) return;
    
    final endedAt = DateTime.now();
    final duration = _totalElapsedSeconds;
    final count = _cyclesCompleted;

    if (count > 0) {
      ref.read(statsProvider.notifier).addBreaths(count);
    }
    
    final int minutes = duration ~/ 60;
    if (minutes > 0) {
      ref.read(statsProvider.notifier).addSession(minutes, 'breathe');
    }

    if (count >= 3) {
      final feeling = await FeelingPromptSheet.show(context);
      _logSessionActivity(startedAt: _sessionStartTime!, endedAt: endedAt, duration: duration, feeling: feeling, completed: true, ignored: false);
    } else if (duration >= 8) {
      _logSessionActivity(startedAt: _sessionStartTime!, endedAt: endedAt, duration: duration, feeling: null, completed: false, ignored: false);
    }
    
    _sessionStartTime = null;
  }

  void _logSessionActivity({
    required DateTime startedAt,
    required DateTime endedAt,
    required int duration,
    required String? feeling,
    required bool completed,
    required bool ignored,
  }) {
    final newActivity = UserActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      activityType: 'calm_pulse',
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: duration,
      feeling: feeling,
      completed: completed,
      ignored: ignored,
    );
    ref.read(activityLogProvider.notifier).addLog(newActivity);
  }

  void _showSuccessFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '3 deep breaths. Nervous system resetting.',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: AppColors.bgDark.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 64, right: 64),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formatTime(int totalSeconds) {
      final m = totalSeconds ~/ 60;
      final s = totalSeconds % 60;
      return '$m:${s.toString().padLeft(2, '0')}';
    }

    String phaseText() {
      switch (_currentPhase) {
        case BreathPhase.ready: return 'Ready';
        case BreathPhase.inhale: return 'Inhale';
        case BreathPhase.hold1:
        case BreathPhase.hold2: return 'Hold';
        case BreathPhase.exhale: return 'Exhale';
      }
    }

    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white),
                      onPressed: () {
                        if (_isPlaying || _totalElapsedSeconds > 0) {
                          _stopSession();
                        }
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ]
                ),
              ),

              const SizedBox(height: 24),

              // Title Header
              Text(
                widget.pattern.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 8),
              if (widget.pattern.description.isNotEmpty) ...[
                Text(
                  widget.pattern.description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ).animate().fadeIn(delay: 100.ms),
              ],

              const Spacer(),

              // Animated Orb
              AnimatedBuilder(
                animation: _scaleController,
                builder: (context, child) {
                  final progress = _scaleController.value; 
                  final scale = 1.0 + (0.5 * progress); 
                  final glowOpacity = 0.2 + (0.4 * progress);

                  return Container(
                    width: 200 * scale,
                    height: 200 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: glowOpacity),
                          blurRadius: 60 * scale,
                          spreadRadius: 20 * scale,
                        ),
                      ],
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accent.withValues(alpha: 0.8),
                          AppColors.accent.withValues(alpha: 0.4),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: _currentPhase == BreathPhase.ready 
                      ? Text(
                          'Tap Play',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              phaseText(),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_secondsLeftInPhase',
                              style: const TextStyle(
                                color: Colors.white, 
                                fontSize: 48, 
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                  );
                },
              ),

              const Spacer(),

              // Timer text
              Text(
                formatTime(_totalElapsedSeconds),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isPlaying || _totalElapsedSeconds > 0) ...[
                    // Stop Button
                    GestureDetector(
                      onTap: _stopSession,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.glassWhite,
                        ),
                        child: const Icon(LucideIcons.square, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],

                  // Play / Pause Button
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying ? LucideIcons.pause : LucideIcons.play, 
                        color: AppColors.bgDark, 
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
