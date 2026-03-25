import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../../activities/domain/user_activity.dart';
import '../../activities/presentation/activity_log_controller.dart';
import '../../stats/presentation/stats_controller.dart';
import 'widgets/feeling_prompt_sheet.dart';

class CalmPulseScreen extends ConsumerStatefulWidget {
  const CalmPulseScreen({super.key});

  @override
  ConsumerState<CalmPulseScreen> createState() => _CalmPulseScreenState();
}

class _CalmPulseScreenState extends ConsumerState<CalmPulseScreen> with SingleTickerProviderStateMixin {
  static const Duration _inhaleDuration = Duration(seconds: 4);
  static const Duration _exhaleDuration = Duration(seconds: 6);

  late AnimationController _breathingController;
  late Animation<double> _scaleAnimation;
  
  bool _isHolding = false;
  int _breathCount = 0;
  bool _achievedMilestone = false;
  String _statusText = 'Ready';
  Timer? _hapticTimer;
  DateTime? _sessionStartTime;
  bool _isProcessingSession = false;

  @override
  void initState() {
    super.initState();
    
    _breathingController = AnimationController(
      vsync: this,
      duration: _inhaleDuration,
      reverseDuration: _exhaleDuration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutSine,
      ),
    );

    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _breathingController.reverse();
        setState(() => _statusText = 'Exhale');
        HapticFeedback.mediumImpact(); 
      } else if (status == AnimationStatus.dismissed) {
        if (_isHolding) {
          _breathCount++;
          if (_breathCount == 3 && !_achievedMilestone) {
            setState(() {
              _achievedMilestone = true;
            });
            HapticFeedback.heavyImpact(); 
          } else {
            HapticFeedback.mediumImpact(); 
          }
          
          _breathingController.forward();
          setState(() => _statusText = 'Inhale');
        }
      }
    });
  }

  void _onPressDown(TapDownDetails details) {
    setState(() {
      _isHolding = true;
      _statusText = 'Inhale';
      _breathCount = 0;
      _achievedMilestone = false;
    });
    if (!_isProcessingSession) {
      _sessionStartTime ??= DateTime.now();
    }

    if (_breathingController.status == AnimationStatus.dismissed || 
        _breathingController.status == AnimationStatus.reverse) {
      _breathingController.forward();
    }
    
    _startHapticRhythm();
    HapticFeedback.heavyImpact(); 
  }

  void _onPressUp(TapUpDetails details) {
    _stopBreathingSession();
  }

  void _onPressCancel() {
    _stopBreathingSession();
  }

  Future<void> _stopBreathingSession() async {
    if (_isProcessingSession) return;
    
    _isProcessingSession = true;

    final endedAt = DateTime.now();
    final startedAt = _sessionStartTime;
    _sessionStartTime = null;

    setState(() {
      _isHolding = false;
      _statusText = 'Ready';
    });
    
    _breathingController.reverse();
    _stopHapticRhythm();
    HapticFeedback.heavyImpact(); 

    final finalBreathCount = _breathCount;

    if (startedAt != null) {
      final duration = endedAt.difference(startedAt).inSeconds;

      if (finalBreathCount > 0) {
        ref.read(statsProvider.notifier).addBreaths(finalBreathCount);
      }

      if (finalBreathCount >= 3) {
        final feeling = await FeelingPromptSheet.show(context);
        _logSession(
          startedAt: startedAt,
          endedAt: endedAt,
          duration: duration,
          feeling: feeling,
          completed: true,
          ignored: false,
        );
        _showSuccessFeedback(finalBreathCount);
      } else if (finalBreathCount > 0 || duration >= 8) {
        _logSession(
          startedAt: startedAt,
          endedAt: endedAt,
          duration: duration,
          feeling: null,
          completed: false,
          ignored: false,
        );
        _showSuccessFeedback(finalBreathCount);
      } else {
        _logSession(
          startedAt: startedAt,
          endedAt: endedAt,
          duration: duration,
          feeling: null,
          completed: false,
          ignored: true,
        );
      }
    }

    if (mounted) {
      _isProcessingSession = false;
    }
  }

  void _logSession({
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

  void _showSuccessFeedback(int count) {
    if (!mounted) return;
    
    String message = 'Just getting started.';
    if (count >= 10) {
      message = '$count deep breaths. Deep calm achieved.';
    } else if (count >= 3) {
      message = '$count deep breaths. Nervous system resetting.';
    } else if (count > 0) {
      message = '$count breath taken.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
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
        elevation: 8,
      ),
    );
  }

  void _startHapticRhythm() {
    _hapticTimer?.cancel();
    _hapticTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isHolding) {
        HapticFeedback.selectionClick(); 
      }
    });
  }

  void _stopHapticRhythm() {
    _hapticTimer?.cancel();
    _hapticTimer = null;
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _hapticTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent, 
        body: GestureDetector(
          onTapDown: _onPressDown,
          onTapUp: _onPressUp,
          onTapCancel: _onPressCancel,
          behavior: HitTestBehavior.opaque,
          child: SizedBox.expand(
            child: SafeArea(
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),

                      const Text(
                        'CALM PULSE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Touch and hold to breathe',
                    style: TextStyle(
                      color: AppColors.accent.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ).animate().fadeIn(duration: 800.ms, delay: 200.ms),

                  const Spacer(), 

                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      final scale = _scaleAnimation.value;
                      final progress = (scale - 1.0) / 0.5;
                      final glowOpacity = 0.2 + (0.4 * progress);
                      final Color glowColor = _achievedMilestone ? AppColors.accentOrange : AppColors.accent;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          if (!_isHolding)
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accent.withValues(alpha: 0.1),
                              ),
                            )
                            .animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .scaleXY(begin: 1.0, end: 1.1, duration: 2.seconds)
                            .fadeIn(duration: 1.seconds),

                          Container(
                            width: 200 * scale,
                            height: 200 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: glowColor.withValues(alpha: glowOpacity),
                                  blurRadius: 60 * scale,
                                  spreadRadius: 20 * scale,
                                ),
                              ],
                            ),
                          ),

                          Container(
                            width: 200 * scale,
                            height: 200 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.accent.withValues(alpha: 0.8),
                                  AppColors.accent.withValues(alpha: 0.4),
                                ],
                                stops: const [0.5, 1.0],
                              ),
                              border: Border.all(
                                color: _achievedMilestone 
                                  ? AppColors.accentOrange.withValues(alpha: 0.3) 
                                  : Colors.white.withValues(alpha: 0.15),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const Spacer(),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      _statusText,
                      key: ValueKey<String>(_statusText),
                      style: TextStyle(
                        color: _isHolding ? Colors.white : AppColors.textSecondary,
                        fontSize: 24,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  Text(
                    'Press and hold the orb',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 32),
                      ],
                    ),
                  ),
                  
                  Positioned(
                    top: 16,
                    left: 16,
                    child: GestureDetector(
                      onTap: () {
                        _stopBreathingSession();
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.glassWhite,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
