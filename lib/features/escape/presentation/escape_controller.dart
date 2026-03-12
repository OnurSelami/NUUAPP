import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio/presentation/audio_mixer_controller.dart';
import '../domain/escape_models.dart';
// Dummy data for environments
final availableEnvironments = [
  Environment(
    id: 'ocean',
    title: 'Ocean Waves',
    subtitle: 'Sunset ocean ambiance',
    icon: Icons.water,
    baseColor: const Color(0xFF1E3A5F),
    imageUrl: 'https://images.unsplash.com/photo-1662056694801-85115a6ae3b1?w=800&q=80',
    audioLayers: [
      const AudioLayer(id: 'waves_base', name: 'Gentle Waves', source: 'https://cdn.pixabay.com/audio/2022/06/07/audio_b9bd4170e4.mp3', defaultVolume: 0.6),
      const AudioLayer(id: 'seagulls', name: 'Seagulls', source: 'https://cdn.pixabay.com/audio/2024/11/04/audio_81a2742781.mp3', defaultVolume: 0.2),
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
      const AudioLayer(id: 'rain_base', name: 'Light Rain', source: 'https://cdn.pixabay.com/audio/2022/10/30/audio_e0908e498d.mp3', defaultVolume: 0.7),
      const AudioLayer(id: 'thunder_distant', name: 'Distant Thunder', source: 'https://cdn.pixabay.com/audio/2022/07/27/audio_b1fca38cad.mp3', defaultVolume: 0.3),
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
      const AudioLayer(id: 'forest_base', name: 'Wind in Trees', source: 'https://cdn.pixabay.com/audio/2022/08/31/audio_419263cae2.mp3', defaultVolume: 0.5),
      const AudioLayer(id: 'birds', name: 'Morning Birds', source: 'https://cdn.pixabay.com/audio/2022/03/09/audio_c5e82e1818.mp3', defaultVolume: 0.4),
    ],
  ),
  Environment(
    id: 'space',
    title: 'Starry Night',
    subtitle: 'Calm starry sky',
    icon: Icons.star,
    baseColor: const Color(0xFF0F1B3D),
    imageUrl: 'https://images.unsplash.com/photo-1629446488105-122120352a03?w=800&q=80',
    audioLayers: [
      const AudioLayer(id: 'space_drone', name: 'Deep Space Drone', source: 'https://cdn.pixabay.com/audio/2023/09/04/audio_9bba0e7fd1.mp3', defaultVolume: 0.8),
    ],
  ),
];

class EscapeController extends Notifier<EscapeState> {
  Timer? _timer;

  @override
  EscapeState build() => const EscapeState();

  void selectEnvironment(Environment env) {
    state = state.copyWith(currentEnvironment: env, isPlaying: false);
    ref.read(audioMixerProvider.notifier).loadEnvironment(env.audioLayers);
  }

  void startSession(int minutes) {
    state = state.copyWith(
      isPlaying: true,
      initialMin: minutes,
      minRemaining: minutes,
    );

    ref.read(audioMixerProvider.notifier).play();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (state.minRemaining > 1) {
        state = state.copyWith(minRemaining: state.minRemaining - 1);
      } else {
        _endSession();
      }
    });
  }

  void pauseSession() {
    state = state.copyWith(isPlaying: false);
    _timer?.cancel();
    ref.read(audioMixerProvider.notifier).pause();
  }

  void resumeSession() {
    state = state.copyWith(isPlaying: true);
    ref.read(audioMixerProvider.notifier).play();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (state.minRemaining > 1) {
        state = state.copyWith(minRemaining: state.minRemaining - 1);
      } else {
        _endSession();
      }
    });
  }

  void _endSession() {
    _timer?.cancel();
    state = state.copyWith(isPlaying: false, minRemaining: 0);
    ref.read(audioMixerProvider.notifier).fadeOutAndStop(const Duration(seconds: 10));
  }
}

final escapeProvider = NotifierProvider<EscapeController, EscapeState>(
  EscapeController.new,
);
