import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

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
  final bool isLoading;

  const AudioMixerState({
    this.players = const {},
    this.volumes = const {},
    this.loadErrors = const {},
    this.isPlaying = false,
    this.isLoading = false,
  });

  AudioMixerState copyWith({
    Map<String, AudioPlayer>? players,
    Map<String, double>? volumes,
    Map<String, bool>? loadErrors,
    bool? isPlaying,
    bool? isLoading,
  }) {
    return AudioMixerState(
      players: players ?? this.players,
      volumes: volumes ?? this.volumes,
      loadErrors: loadErrors ?? this.loadErrors,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Riverpod Notifier to manage the complex audio mixing logic
class AudioMixerController extends Notifier<AudioMixerState> {
  /// Cache of extracted asset file paths (assetPath → filePath)
  static final Map<String, String> _fileCache = {};

  @override
  AudioMixerState build() => const AudioMixerState();

  /// Extracts a Flutter asset to a real file on the filesystem.
  /// Returns the file path. Caches so extraction only happens once.
  Future<String> _extractAssetToFile(String assetPath) async {
    // Return cached path if already extracted
    if (_fileCache.containsKey(assetPath)) {
      final cached = _fileCache[assetPath]!;
      if (File(cached).existsSync()) {
        debugPrint('[AudioMixer] Using cached file for $assetPath → $cached');
        return cached;
      }
    }

    // Get temp directory and create audio_cache subfolder
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory('${tempDir.path}/audio_cache');
    if (!cacheDir.existsSync()) {
      cacheDir.createSync(recursive: true);
    }

    // Extract filename from asset path
    final fileName = assetPath.split('/').last;
    final filePath = '${cacheDir.path}/$fileName';

    debugPrint('[AudioMixer] Extracting asset $assetPath → $filePath');

    // Load bytes from Flutter asset bundle and write to file
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    debugPrint('[AudioMixer] Extracted ${bytes.length} bytes to $filePath');

    // Cache the path
    _fileCache[assetPath] = filePath;
    return filePath;
  }

  /// Loads a set of layers and optionally auto-plays them
  Future<void> loadEnvironment(List<AudioLayer> layers, {bool autoPlay = false}) async {
    debugPrint('[AudioMixer] loadEnvironment: ${layers.length} layers, autoPlay=$autoPlay');
    state = state.copyWith(isLoading: true);

    // 1. Dispose old players
    for (final entry in state.players.entries) {
      try {
        await entry.value.stop();
        await entry.value.dispose();
      } catch (e) {
        debugPrint('[AudioMixer] Error disposing ${entry.key}: $e');
      }
    }

    final newPlayers = <String, AudioPlayer>{};
    final newVolumes = <String, double>{};
    final newLoadErrors = <String, bool>{};

    // 2. Initialize new players
    for (final layer in layers) {
      final player = AudioPlayer();
      try {
        Duration? duration;

        if (layer.sourceType == AudioSourceType.url) {
          // URL: stream directly
          debugPrint('[AudioMixer] Loading URL: ${layer.source}');
          duration = await player.setUrl(layer.source);
        } else {
          // ASSET: extract to file first, then play from file path
          debugPrint('[AudioMixer] Extracting asset: ${layer.source}');
          final filePath = await _extractAssetToFile(layer.source);
          debugPrint('[AudioMixer] Playing from file: $filePath');
          duration = await player.setFilePath(filePath);
        }

        debugPrint('[AudioMixer] ✅ "${layer.name}" loaded, duration=$duration');

        await player.setLoopMode(LoopMode.one);
        await player.setVolume(layer.defaultVolume);

        newPlayers[layer.id] = player;
        newVolumes[layer.id] = layer.defaultVolume;
        newLoadErrors[layer.id] = false;
      } catch (e) {
        debugPrint('[AudioMixer] ❌ Error loading "${layer.name}": $e');
        newLoadErrors[layer.id] = true;
        try { await player.dispose(); } catch (_) {}
      }
    }

    // 3. Update state
    state = state.copyWith(
      players: newPlayers,
      volumes: newVolumes,
      loadErrors: newLoadErrors,
      isLoading: false,
      isPlaying: autoPlay,
    );

    // 4. Auto-play if requested
    if (autoPlay && newPlayers.isNotEmpty) {
      debugPrint('[AudioMixer] ▶ Auto-playing ${newPlayers.length} layers');
      for (final entry in newPlayers.entries) {
        entry.value.play();
      }
    }

    debugPrint('[AudioMixer] loadEnvironment complete. Players: ${newPlayers.length}');
  }

  /// Change volume of a specific layer
  void setVolume(String layerId, double volume) {
    if (!state.players.containsKey(layerId)) return;
    state.players[layerId]!.setVolume(volume);
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
