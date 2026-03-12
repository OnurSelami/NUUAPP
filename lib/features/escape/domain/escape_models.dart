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

  const Environment({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.baseColor,
    required this.imageUrl,
    required this.audioLayers,
  });
}

class EscapeState {
  final Environment? currentEnvironment;
  final bool isPlaying;
  final int minRemaining;
  final int initialMin;

  const EscapeState({
    this.currentEnvironment,
    this.isPlaying = false,
    this.minRemaining = 0,
    this.initialMin = 0,
  });

  EscapeState copyWith({
    Environment? currentEnvironment,
    bool? isPlaying,
    int? minRemaining,
    int? initialMin,
  }) {
    return EscapeState(
      currentEnvironment: currentEnvironment ?? this.currentEnvironment,
      isPlaying: isPlaying ?? this.isPlaying,
      minRemaining: minRemaining ?? this.minRemaining,
      initialMin: initialMin ?? this.initialMin,
    );
  }
}
