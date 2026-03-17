import 'package:flutter/material.dart';
import '../../audio/presentation/audio_mixer_controller.dart';

class Environment {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color baseColor;
  final String imageUrl;
  final List<AudioLayer> audioLayers;
  final bool isPremium;

  const Environment({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.baseColor,
    required this.imageUrl,
    required this.audioLayers,
    this.isPremium = false,
  });
}

class EscapeState {
  final Environment? currentEnvironment;
  final bool isPlaying;
  final int secondsRemaining;
  final int totalSeconds;

  const EscapeState({
    this.currentEnvironment,
    this.isPlaying = false,
    this.secondsRemaining = 0,
    this.totalSeconds = 0,
  });

  /// Helper to get minutes remaining for display
  int get minutesDisplay => secondsRemaining ~/ 60;

  /// Helper to get seconds part for display
  int get secondsDisplay => secondsRemaining % 60;

  /// Helper to get progress (0.0 to 1.0)
  double get progress => totalSeconds > 0 ? 1.0 - (secondsRemaining / totalSeconds) : 0.0;

  EscapeState copyWith({
    Environment? currentEnvironment,
    bool? isPlaying,
    int? secondsRemaining,
    int? totalSeconds,
  }) {
    return EscapeState(
      currentEnvironment: currentEnvironment ?? this.currentEnvironment,
      isPlaying: isPlaying ?? this.isPlaying,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      totalSeconds: totalSeconds ?? this.totalSeconds,
    );
  }
}
