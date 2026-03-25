import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio/presentation/audio_mixer_controller.dart';
import '../../stats/presentation/stats_controller.dart';
import '../domain/escape_models.dart';

// Environment data
final availableEnvironments = [
  Environment(
    id: 'ocean',
    title: 'Ocean Waves',
    subtitle: 'Sunset ocean ambiance',
    icon: Icons.water,
    baseColor: const Color(0xFF1E3A5F),
    imageUrl: 'https://images.unsplash.com/photo-1662056694801-85115a6ae3b1?w=800&q=80',
    audioLayers: [
      const AudioLayer.asset(id: 'waves_base', name: 'Gentle Waves', assetPath: 'assets/audio/ocean_base.mp3', defaultVolume: 0.6),
    ],
  ),
  Environment(
    id: 'rain',
    title: 'Soft Rain',
    subtitle: 'Gentle rain in darkness',
    icon: Icons.cloud,
    baseColor: const Color(0xFF1A2742),
    imageUrl: 'https://images.unsplash.com/photo-1759328502259-3e0eeecc02d5?w=800&q=80',
    audioLayers: [
      const AudioLayer.asset(id: 'rain_base', name: 'Light Rain', assetPath: 'assets/audio/rain_base.mp3', defaultVolume: 0.7),
      const AudioLayer.asset(id: 'thunder_distant', name: 'Distant Thunder', assetPath: 'assets/audio/thunder.mp3', defaultVolume: 0.3),
    ],
  ),
  Environment(
    id: 'forest',
    title: 'Forest Light',
    subtitle: 'Foggy forest with light beams',
    icon: Icons.forest,
    baseColor: const Color(0xFF1A3D2C),
    imageUrl: 'https://images.unsplash.com/photo-1658509800439-dee8fa351395?w=800&q=80',
    audioLayers: [
      const AudioLayer.asset(id: 'forest_base', name: 'Wind in Trees', assetPath: 'assets/audio/forest_base.mp3', defaultVolume: 0.5),
      const AudioLayer.asset(id: 'birds', name: 'Morning Birds', assetPath: 'assets/audio/birds.mp3', defaultVolume: 0.4),
    ],
    isPremium: true,
  ),
  Environment(
    id: 'space',
    title: 'Starry Night',
    subtitle: 'Calm starry sky',
    icon: Icons.star,
    baseColor: const Color(0xFF0F1B3D),
    imageUrl: 'https://images.unsplash.com/photo-1629446488105-122120352a03?w=800&q=80',
    audioLayers: [
      const AudioLayer.asset(id: 'space_drone', name: 'Deep Space Drone', assetPath: 'assets/audio/space_drone.mp3', defaultVolume: 0.8),
    ],
    isPremium: true,
  ),
  Environment(
    id: 'sleep',
    title: 'Deep Sleep',
    subtitle: 'Rain and white noise',
    icon: Icons.bedtime,
    baseColor: const Color(0xFF14142B),
    imageUrl: 'https://images.unsplash.com/photo-1517436073-3b1b16d9b0f4?w=800&q=80',
    audioLayers: [
      const AudioLayer.asset(id: 'deep_sleep', name: 'Sleeping Drone', assetPath: 'assets/audio/deep_sleep.mp3', defaultVolume: 0.6),
      const AudioLayer.asset(id: 'rain_base', name: 'Light Rain', assetPath: 'assets/audio/rain_base.mp3', defaultVolume: 0.4),
      const AudioLayer.asset(id: 'white_noise', name: 'White Noise', assetPath: 'assets/audio/white_noise.mp3', defaultVolume: 0.2),
    ],
  ),
  Environment(
    id: 'tinnitus',
    title: 'Tinnitus Relief',
    subtitle: 'Clinical masking therapy',
    icon: Icons.graphic_eq, // Sound wave icon
    baseColor: const Color(0xFF2A2A35),
    imageUrl: 'https://images.unsplash.com/photo-1518112166137-85f9979a43dd?w=800&q=80',
    audioLayers: [
      const AudioLayer.asset(id: 'rain_pink', name: 'Pink Noise (Rain)', assetPath: 'assets/audio/rain_base.mp3', defaultVolume: 0.6),
      const AudioLayer.asset(id: 'ocean_brown', name: 'Brown Noise (Ocean)', assetPath: 'assets/audio/ocean_base.mp3', defaultVolume: 0.4),
      const AudioLayer.asset(id: 'forest_high', name: 'High Freq Masker', assetPath: 'assets/audio/forest_base.mp3', defaultVolume: 0.3),
      const AudioLayer.asset(id: 'white_noise', name: 'White Noise', assetPath: 'assets/audio/white_noise.mp3', defaultVolume: 0.0),
    ],
    isPremium: true,
  ),
];

class EscapeController extends Notifier<EscapeState> {
  Timer? _timer;

  @override
  EscapeState build() => const EscapeState();

  void selectEnvironment(Environment env) {
    state = state.copyWith(currentEnvironment: env, isPlaying: false);
    // Don't load audio here - load it when the session starts
  }

  /// Start a session with the given number of minutes
  void startSession(int minutes) {
    final totalSec = minutes * 60;
    final env = state.currentEnvironment;
    if (env == null) return;

    state = state.copyWith(
      isPlaying: true,
      totalSeconds: totalSec,
      secondsRemaining: totalSec,
    );

    // Load environment audio and auto-play when ready
    ref.read(audioMixerProvider.notifier).loadEnvironment(env.audioLayers, autoPlay: true);
    _startTimer();
  }

  void pauseSession() {
    state = state.copyWith(isPlaying: false);
    _timer?.cancel();
    ref.read(audioMixerProvider.notifier).pause();
  }

  void resumeSession() {
    state = state.copyWith(isPlaying: true);
    ref.read(audioMixerProvider.notifier).play();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining > 1) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        _endSession();
      }
    });
  }

  void stopSession() {
    _timer?.cancel();
    
    // Calculate and save elapsed minutes
    if (state.totalSeconds > 0) {
      final elapsedSeconds = state.totalSeconds - state.secondsRemaining;
      final elapsedMinutes = elapsedSeconds ~/ 60;
      if (elapsedMinutes > 0) {
        ref.read(statsProvider.notifier).addSession(elapsedMinutes, 'escape');
      }
    }

    state = state.copyWith(isPlaying: false, secondsRemaining: 0, totalSeconds: 0);
    ref.read(audioMixerProvider.notifier).fadeOutAndStop(const Duration(seconds: 2));
  }

  void _endSession() {
    stopSession();
  }
}

final escapeProvider = NotifierProvider<EscapeController, EscapeState>(
  EscapeController.new,
);
