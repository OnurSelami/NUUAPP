import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

/// How the audio source is loaded
enum AudioSourceType { asset, url }

/// Represents a single audio layer in the environment (e.g., Rain, Wind, Fire)
class AudioLayer {
  final String id;
  final String name;
  final String source; // asset path or URL
  final AudioSourceType sourceType;
  final double defaultVolume;

  const AudioLayer({
    required this.id,
    required this.name,
    required this.source,
    this.sourceType = AudioSourceType.url,
    this.defaultVolume = 0.5,
  });

  // Backward compat: keep named param assetPath as alias for source with asset type
  const AudioLayer.asset({
    required this.id,
    required this.name,
    required String assetPath,
    this.defaultVolume = 0.5,
  })  : source = assetPath,
        sourceType = AudioSourceType.asset;
}

/// Holds the state of all active audio players and their volumes
class AudioMixerState {
  final Map<String, AudioPlayer> players;
  final Map<String, double> volumes;
  final Map<String, bool> loadErrors;
  final bool isPlaying;

  const AudioMixerState({
    this.players = const {},
    this.volumes = const {},
    this.loadErrors = const {},
    this.isPlaying = false,
  });

  AudioMixerState copyWith({
    Map<String, AudioPlayer>? players,
    Map<String, double>? volumes,
    Map<String, bool>? loadErrors,
    bool? isPlaying,
  }) {
    return AudioMixerState(
      players: players ?? this.players,
      volumes: volumes ?? this.volumes,
      loadErrors: loadErrors ?? this.loadErrors,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

/// Riverpod Notifier to manage the complex audio mixing logic
class AudioMixerController extends Notifier<AudioMixerState> {
  @override
  AudioMixerState build() => const AudioMixerState();

  /// Loads a set of layers (e.g., when entering an environment)
  Future<void> loadEnvironment(List<AudioLayer> layers) async {
    // 1. Dispose old players
    for (final player in state.players.values) {
      await player.stop();
      await player.dispose();
    }

    final newPlayers = <String, AudioPlayer>{};
    final newVolumes = <String, double>{};
    final newLoadErrors = <String, bool>{};

    // 2. Initialize new players
    for (final layer in layers) {
      final player = AudioPlayer();
      try {
        // Load from URL or asset based on source type
        if (layer.sourceType == AudioSourceType.url) {
          await player.setUrl(layer.source);
        } else {
          await player.setAsset(layer.source);
        }
        await player.setLoopMode(LoopMode.one);
        await player.setVolume(layer.defaultVolume);

        newPlayers[layer.id] = player;
        newVolumes[layer.id] = layer.defaultVolume;
        newLoadErrors[layer.id] = false;
      } catch (e) {
        debugPrint("Error loading audio '${layer.name}' from ${layer.source}: $e");
        newLoadErrors[layer.id] = true;
        await player.dispose();
      }
    }

    state = state.copyWith(
      players: newPlayers,
      volumes: newVolumes,
      loadErrors: newLoadErrors,
      isPlaying: false,
    );
  }

  /// Change volume of a specific layer
  void setVolume(String layerId, double volume) {
    if (!state.players.containsKey(layerId)) return;

    final player = state.players[layerId]!;
    player.setVolume(volume);

    final newVolumes = Map<String, double>.from(state.volumes);
    newVolumes[layerId] = volume;

    state = state.copyWith(volumes: newVolumes);
  }

  /// Play all layers
  Future<void> play() async {
    state = state.copyWith(isPlaying: true);
    for (final player in state.players.values) {
      player.play();
    }
  }

  /// Pause all layers
  Future<void> pause() async {
    state = state.copyWith(isPlaying: false);
    for (final player in state.players.values) {
      player.pause();
    }
  }

  /// Gradually decrease volume of all layers until stopped
  Future<void> fadeOutAndStop(Duration duration) async {
    if (!state.isPlaying) return;

    final steps = 20;
    final stepDuration = duration.inMilliseconds ~/ steps;
    final initialVolumes = Map<String, double>.from(state.volumes);

    for (int i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      final reductionFactor = 1.0 - (i / steps);
      for (final layerId in state.players.keys) {
        final initialVol = initialVolumes[layerId] ?? 0.0;
        state.players[layerId]?.setVolume(initialVol * reductionFactor);
      }
    }

    await pause();

    // Restore volumes for next play
    for (final layerId in state.players.keys) {
      final initialVol = initialVolumes[layerId] ?? 0.0;
      state.players[layerId]?.setVolume(initialVol);
    }
  }
}

/// Global provider for the Audio Mixer
final audioMixerProvider =
    NotifierProvider<AudioMixerController, AudioMixerState>(
  AudioMixerController.new,
);
