import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio/presentation/audio_mixer_controller.dart';

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

  static const sleepLayers = [
    AudioLayer(id: 'deep_sleep_drone', name: 'Deep Sleep Drone', source: 'https://cdn.pixabay.com/audio/2023/04/11/audio_14942ec498.mp3', defaultVolume: 0.5),
    AudioLayer(id: 'soft_rain', name: 'Soft Rain', source: 'https://cdn.pixabay.com/audio/2022/10/30/audio_e0908e498d.mp3', defaultVolume: 0.3),
    AudioLayer(id: 'white_noise', name: 'White Noise', source: 'https://cdn.pixabay.com/audio/2022/03/15/audio_115f075bbb.mp3', defaultVolume: 0.1),
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

    ref.read(audioMixerProvider.notifier).loadEnvironment(sleepLayers).then((_) {
      ref.read(audioMixerProvider.notifier).play();
    });

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
  }

  void _endSession() {
    _timer?.cancel();
    state = state.copyWith(isPlaying: false, minRemaining: 0);
    ref.read(audioMixerProvider.notifier).fadeOutAndStop(const Duration(seconds: 30));
  }
}

final sleepProvider = NotifierProvider<SleepController, SleepState>(
  SleepController.new,
);
