import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio/presentation/audio_mixer_controller.dart';
import '../../stats/presentation/stats_controller.dart';

class SleepState {
  final int selectedDuration; // 0 = continuous, 15, 30, 60, 90
  final int minRemaining;
  final bool isPlaying;
  final bool isContinuous;

  const SleepState({
    this.selectedDuration = 30,
    this.minRemaining = 30,
    this.isPlaying = false,
    this.isContinuous = false,
  });

  SleepState copyWith({
    int? selectedDuration,
    int? minRemaining,
    bool? isPlaying,
    bool? isContinuous,
  }) {
    return SleepState(
      selectedDuration: selectedDuration ?? this.selectedDuration,
      minRemaining: minRemaining ?? this.minRemaining,
      isPlaying: isPlaying ?? this.isPlaying,
      isContinuous: isContinuous ?? this.isContinuous,
    );
  }
}

class SleepController extends Notifier<SleepState> {
  Timer? _timer;
  DateTime? _sessionStart;
  static const sleepLayers = [
    AudioLayer.asset(id: 'deep_sleep_drone', name: 'Deep Sleep Drone', assetPath: 'assets/audio/deep_sleep.mp3', defaultVolume: 0.5),
    AudioLayer.asset(id: 'soft_rain', name: 'Soft Rain', assetPath: 'assets/audio/rain_base.mp3', defaultVolume: 0.3),
    AudioLayer.asset(id: 'white_noise', name: 'White Noise', assetPath: 'assets/audio/white_noise.mp3', defaultVolume: 0.1),
  ];

  @override
  SleepState build() => const SleepState();

  void setDuration(int minutes) {
    if (state.isPlaying) return;
    state = state.copyWith(
      selectedDuration: minutes,
      minRemaining: minutes,
      isContinuous: minutes == 0,
    );
  }

  void toggleSleep() {
    if (state.isPlaying) {
      _pause();
    } else {
      _start();
    }
  }

  void _start() {
    if (!state.isContinuous && state.minRemaining <= 0) {
      state = state.copyWith(minRemaining: state.selectedDuration);
    }

    state = state.copyWith(isPlaying: true);
    _sessionStart = DateTime.now();

    ref.read(audioMixerProvider.notifier).loadEnvironment(sleepLayers, autoPlay: true);

    _timer?.cancel();

    if (!state.isContinuous) {
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        if (state.minRemaining > 1) {
          state = state.copyWith(minRemaining: state.minRemaining - 1);
        } else {
          _endSession();
        }
      });
    }
  }

  void _pause() {
    state = state.copyWith(isPlaying: false);
    _timer?.cancel();
    ref.read(audioMixerProvider.notifier).pause();
    _saveProgress();
  }

  void stopSession() {
    _pause();
    state = state.copyWith(minRemaining: 0);
  }

  void _saveProgress() {
    if (_sessionStart != null) {
      final elapsed = DateTime.now().difference(_sessionStart!).inMinutes;
      if (elapsed > 0) {
        ref.read(statsProvider.notifier).addSession(elapsed, 'sleep');
      }
      _sessionStart = null;
    }
  }

  void _endSession() {
    _timer?.cancel();
    state = state.copyWith(isPlaying: false, minRemaining: 0);
    ref.read(audioMixerProvider.notifier).fadeOutAndStop(const Duration(seconds: 30));
    _saveProgress();
  }
}

final sleepProvider = NotifierProvider<SleepController, SleepState>(
  SleepController.new,
);
