class BreathPattern {
  final String id;
  final String title;
  final String description;
  final int inhaleSeconds;
  final int hold1Seconds;
  final int exhaleSeconds;
  final int hold2Seconds;

  const BreathPattern({
    required this.id,
    required this.title,
    required this.description,
    required this.inhaleSeconds,
    this.hold1Seconds = 0,
    required this.exhaleSeconds,
    this.hold2Seconds = 0,
  });

  int get totalSeconds => inhaleSeconds + hold1Seconds + exhaleSeconds + hold2Seconds;
}

class BreathingPatterns {
  static const resonance = BreathPattern(
    id: 'resonance',
    title: 'Resonance Breathing',
    description: 'Instant nervous system balance.',
    inhaleSeconds: 4,
    exhaleSeconds: 6,
  );
  
  static const relax478 = BreathPattern(
    id: '478',
    title: '4-7-8 Relaxing Breath',
    description: 'Deep sleep and anxiety rescue.',
    inhaleSeconds: 4,
    hold1Seconds: 7,
    exhaleSeconds: 8,
  );
  
  static const box = BreathPattern(
    id: 'box',
    title: 'Box Breathing',
    description: 'Navy SEAL focus technique.',
    inhaleSeconds: 4,
    hold1Seconds: 4,
    exhaleSeconds: 4,
    hold2Seconds: 4,
  );
  
  static const physiological = BreathPattern(
    id: 'physio',
    title: 'Physiological Sigh',
    description: 'Immediate stress relief.',
    inhaleSeconds: 4,
    hold1Seconds: 2,
    exhaleSeconds: 6,
  );
  
  static const List<BreathPattern> all = [resonance, relax478, box, physiological];
}
