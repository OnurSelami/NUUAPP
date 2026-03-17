import 'models/calm_place.dart';
import 'models/weather_data.dart';

/// Engine that calculates a Calm Score (0–100) for each place
/// based on multiple weighted factors.
class CalmScoreEngine {
  /// Calculate calm score and reasons for a place
  static CalmPlace computeScore({
    required CalmPlace place,
    required WeatherData? weather,
    required Set<String> savedCategories,
  }) {
    double score = 0;
    final reasons = <CalmReason>[];
    final now = DateTime.now();
    final hour = now.hour;

    // 1. Category score (25%)
    final categoryScore = _categoryScore(place.category);
    score += categoryScore * 0.25;
    if (categoryScore >= 90) {
      reasons.add(CalmReason(
        text: '${place.category.label} — naturally calming',
        icon: 'leaf',
      ));
    }

    // 2. Distance score (20%)
    final distScore = _distanceScore(place.distanceMeters);
    score += distScore * 0.20;
    if (place.distanceMeters < 800) {
      reasons.add(CalmReason(
        text: 'Just ${place.walkingTime}',
        icon: 'footprints',
      ));
    }

    // 3. Weather suitability (15%)
    if (weather != null) {
      final weatherScore = _weatherScore(place.category, weather);
      score += weatherScore * 0.15;
      if (weather.isOutdoorFriendly && _isOutdoorCategory(place.category)) {
        reasons.add(CalmReason(
          text: weather.weatherTip,
          icon: 'sun',
        ));
      } else if (!weather.isOutdoorFriendly && !_isOutdoorCategory(place.category)) {
        reasons.add(CalmReason(
          text: 'Indoor calm — ideal for current weather',
          icon: 'cloud-rain',
        ));
      }
    } else {
      score += 50 * 0.15; // neutral if no weather data
    }

    // 4. Rating (15%)
    final ratingScore = place.rating != null ? (place.rating! / 5.0 * 100) : 70;
    score += ratingScore * 0.15;

    // 5. Open now (10%)
    final openScore = place.isOpenNow ? 100.0 : 0.0;
    score += openScore * 0.10;
    if (place.isOpenNow) {
      reasons.add(CalmReason(text: 'Open now', icon: 'clock'));
    }

    // 6. Time of day relevance (10%)
    final timeScore = _timeOfDayScore(place.category, hour);
    score += timeScore * 0.10;
    final timeTip = _timeOfDayTip(place.category, hour);
    if (timeTip != null) {
      reasons.add(CalmReason(text: timeTip, icon: 'sunrise'));
    }

    // 7. User preference boost (5%)
    final prefScore = savedCategories.contains(place.category.name) ? 100.0 : 40.0;
    score += prefScore * 0.05;

    return place.copyWith(
      calmScore: score.round().clamp(0, 100),
      calmReasons: reasons.take(4).toList(), // max 4 reasons
    );
  }

  /// Category inherent calmness score
  static double _categoryScore(PlaceCategory cat) {
    switch (cat) {
      case PlaceCategory.park:
        return 90;
      case PlaceCategory.forest:
        return 100;
      case PlaceCategory.beach:
        return 95;
      case PlaceCategory.trail:
        return 92;
      case PlaceCategory.library:
        return 88;
      case PlaceCategory.meditation:
        return 95;
      case PlaceCategory.wellness:
        return 85;
      case PlaceCategory.cafe:
        return 70;
    }
  }

  /// Distance score: closer = higher
  static double _distanceScore(double meters) {
    if (meters < 500) return 100;
    if (meters < 1000) return 85;
    if (meters < 2000) return 70;
    if (meters < 3000) return 50;
    if (meters < 5000) return 30;
    return 10;
  }

  /// Weather suitability for the place type
  static double _weatherScore(PlaceCategory cat, WeatherData weather) {
    final isOutdoor = _isOutdoorCategory(cat);
    if (isOutdoor) {
      return weather.isOutdoorFriendly ? 100 : 20;
    } else {
      // Indoor places are great in bad weather
      return weather.isOutdoorFriendly ? 60 : 90;
    }
  }

  /// Time of day relevance
  static double _timeOfDayScore(PlaceCategory cat, int hour) {
    final isOutdoor = _isOutdoorCategory(cat);
    if (isOutdoor) {
      // Outdoor places: best at morning (6–9) and golden hour (17–19)
      if (hour >= 6 && hour <= 9) return 100;
      if (hour >= 17 && hour <= 19) return 95;
      if (hour >= 10 && hour <= 16) return 70;
      return 30; // nighttime
    } else {
      // Indoor places: good all day, slightly better in evening
      if (hour >= 18 && hour <= 22) return 90;
      if (hour >= 8 && hour <= 17) return 80;
      return 60;
    }
  }

  /// Time-contextual tip
  static String? _timeOfDayTip(PlaceCategory cat, int hour) {
    if (_isOutdoorCategory(cat)) {
      if (hour >= 5 && hour <= 8) return 'Perfect for a calm morning';
      if (hour >= 16 && hour <= 19) return 'Beautiful at sunset';
    } else {
      if (hour >= 19) return 'Great for an evening winddown';
    }
    return null;
  }

  static bool _isOutdoorCategory(PlaceCategory cat) {
    return cat == PlaceCategory.park ||
        cat == PlaceCategory.forest ||
        cat == PlaceCategory.beach ||
        cat == PlaceCategory.trail;
  }
}
