import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../stats/presentation/stats_controller.dart';
import '../data/energy_repository.dart';
import '../data/energy_pattern_engine.dart';
import '../data/energy_insight_engine.dart';
import '../data/models/energy_log.dart';

/// State for Energy Map feature
class EnergyMapState {
  final List<EnergyLog> allLogs;
  final List<EnergyLog> todayLogs;
  final EnergyProfile profile;
  final List<EnergyInsight> insights;
  final bool isLoading;
  final String? miniInsight; // Instant feedback after logging

  const EnergyMapState({
    this.allLogs = const [],
    this.todayLogs = const [],
    this.profile = const EnergyProfile(),
    this.insights = const [],
    this.isLoading = false,
    this.miniInsight,
  });

  EnergyMapState copyWith({
    List<EnergyLog>? allLogs,
    List<EnergyLog>? todayLogs,
    EnergyProfile? profile,
    List<EnergyInsight>? insights,
    bool? isLoading,
    String? miniInsight,
    bool clearMini = false,
  }) {
    return EnergyMapState(
      allLogs: allLogs ?? this.allLogs,
      todayLogs: todayLogs ?? this.todayLogs,
      profile: profile ?? this.profile,
      insights: insights ?? this.insights,
      isLoading: isLoading ?? this.isLoading,
      miniInsight: clearMini ? null : (miniInsight ?? this.miniInsight),
    );
  }
}

/// Riverpod controller for Energy Map
class EnergyMapController extends Notifier<EnergyMapState> {
  late EnergyRepository _repo;

  @override
  EnergyMapState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    _repo = EnergyRepository(prefs);
    // Defer data loading to avoid setting state during build
    Future.microtask(() => _loadData());
    return const EnergyMapState(isLoading: true);
  }

  /// Load all data and compute profile + insights
  void _loadData() {
    try {
      final allLogs = _repo.getLogs(days: 90);
      final todayLogs = _repo.getTodayLogs();
      final profile = EnergyPatternEngine.buildProfile(allLogs);
      final insights = EnergyInsightEngine.generateInsights(profile, allLogs);

      state = state.copyWith(
        allLogs: allLogs,
        todayLogs: todayLogs,
        profile: profile,
        insights: insights,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Energy load error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Log a new energy entry
  Future<void> logEnergy({
    required int level,
    List<String> tags = const [],
  }) async {
    final now = DateTime.now();
    final log = EnergyLog(
      id: '${now.millisecondsSinceEpoch}',
      timestamp: now,
      level: level.clamp(0, 100),
      tags: tags,
      segment: DaySegment.fromHour(now.hour),
    );

    await _repo.addLog(log);

    // Refresh data
    final allLogs = _repo.getLogs(days: 90);
    final todayLogs = _repo.getTodayLogs();
    final profile = EnergyPatternEngine.buildProfile(allLogs);
    final insights = EnergyInsightEngine.generateInsights(profile, allLogs);

    // Get instant mini-insight
    final mini = EnergyInsightEngine.getMiniInsight(log, profile);

    state = state.copyWith(
      allLogs: allLogs,
      todayLogs: todayLogs,
      profile: profile,
      insights: insights,
      miniInsight: mini,
    );
  }

  /// Clear the mini-insight after it's been shown
  void clearMiniInsight() {
    state = state.copyWith(clearMini: true);
  }

  /// Refresh data manually
  void refresh() {
    state = state.copyWith(isLoading: true);
    _loadData();
  }

  /// Returns a smart contextual insight for the Home screen
  String getSmartInsight() {
    if (state.isLoading || state.allLogs.isEmpty) {
      return "Take a moment for yourself.";
    }

    final hour = DateTime.now().hour;
    final profile = state.profile;
    
    // Check if current hour is a dip (±1 hour)
    if (profile.dipHour >= 0 && 
        (hour == profile.dipHour || hour == profile.dipHour - 1 || hour == profile.dipHour + 1)) {
      return "Energy usually drops around this time. Ready to reset?";
    }
    
    // Check if peak hour
    if (profile.peakHour >= 0 && hour == profile.peakHour) {
      return "You're at your peak energy right now.";
    }
    
    // Check if no logs today
    if (state.todayLogs.isEmpty) {
      return "How is your energy right now?";
    }
    
    // Default insight
    if (state.insights.isNotEmpty) {
      return state.insights.first.title;
    }

    return "Breathe and reset your mind.";
  }
}

/// Main provider
final energyMapProvider =
    NotifierProvider<EnergyMapController, EnergyMapState>(() {
  return EnergyMapController();
});
