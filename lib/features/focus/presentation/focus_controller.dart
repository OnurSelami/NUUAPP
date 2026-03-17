import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio/presentation/audio_mixer_controller.dart';
import '../../stats/presentation/stats_controller.dart';

class FocusState {
  final int selectedDuration; // 25 or 45 min
  final int minRemaining;
  final int secRemaining;
  final bool isPlaying;
  final bool isSessionComplete;

  const FocusState({
    this.selectedDuration = 25,
    this.minRemaining = 25,
    this.secRemaining = 0,
    this.isPlaying = false,
    this.isSessionComplete = false,
  });

  FocusState copyWith({
    int? selectedDuration,
    int? minRemaining,
    int? secRemaining,
    bool? isPlaying,
    bool? isSessionComplete,
  }) {
    return FocusState(
      selectedDuration: selectedDuration ?? this.selectedDuration,
      minRemaining: minRemaining ?? this.minRemaining,
      secRemaining: secRemaining ?? this.secRemaining,
      isPlaying: isPlaying ?? this.isPlaying,
      isSessionComplete: isSessionComplete ?? this.isSessionComplete,
    );
  }
}

class FocusController extends Notifier<FocusState> {
  Timer? _timer;
  DateTime? _sessionStart;

  static const focusLayers = [
    AudioLayer.asset(id: 'focus_drone', name: 'Deep Focus Drone', assetPath: 'assets/audio/focus_drone.mp3', defaultVolume: 0.6),
    AudioLayer.asset(id: 'coffee_shop', name: 'Coffee Shop Ambience', assetPath: 'assets/audio/coffee_shop.mp3', defaultVolume: 0.3),
  ];

  @override
  FocusState build() => const FocusState();

  void setDuration(int minutes) {
    if (state.isPlaying) return;
    state = state.copyWith(
      selectedDuration: minutes,
      minRemaining: minutes,
      secRemaining: 0,
      isSessionComplete: false,
    );
  }

  void toggleFocus() {
    if (state.isPlaying) {
      _pause();
    } else {
      _start();
    }
  }

  void _start() {
    if (state.isSessionComplete) {
      state = state.copyWith(minRemaining: state.selectedDuration, secRemaining: 0, isSessionComplete: false);
    }

    state = state.copyWith(isPlaying: true);
    _sessionStart = DateTime.now();

    ref.read(audioMixerProvider.notifier).loadEnvironment(focusLayers, autoPlay: true);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secRemaining > 0) {
        state = state.copyWith(secRemaining: state.secRemaining - 1);
      } else if (state.minRemaining > 0) {
        state = state.copyWith(minRemaining: state.minRemaining - 1, secRemaining: 59);
      } else {
        _endSession();
      }
    });
  }

  void _pause() {
    state = state.copyWith(isPlaying: false);
    _timer?.cancel();
    ref.read(audioMixerProvider.notifier).pause();
    _saveProgress();
  }

  void stopSession() {
    _pause();
    state = state.copyWith(minRemaining: state.selectedDuration, secRemaining: 0);
  }

  void _saveProgress() {
    if (_sessionStart != null) {
      final elapsed = DateTime.now().difference(_sessionStart!).inMinutes;
      if (elapsed > 0) {
        ref.read(statsProvider.notifier).addSession(elapsed, 'focus');
      }
      _sessionStart = null;
    }
  }

  void _endSession() {
    _timer?.cancel();
    state = state.copyWith(
      isPlaying: false,
      minRemaining: 0,
      secRemaining: 0,
      isSessionComplete: true,
    );
    ref.read(audioMixerProvider.notifier).fadeOutAndStop(const Duration(seconds: 5));
    _saveProgress();
  }
}

final focusProvider = NotifierProvider<FocusController, FocusState>(
  FocusController.new,
);
