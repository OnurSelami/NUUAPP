/// Weather condition from Open-Meteo
enum WeatherCondition {
  clear('Clear Sky', 'sun'),
  partlyCloudy('Partly Cloudy', 'cloud-sun'),
  cloudy('Cloudy', 'cloud'),
  rain('Rain', 'cloud-rain'),
  heavyRain('Heavy Rain', 'cloud-rain-wind'),
  snow('Snow', 'snowflake'),
  fog('Fog', 'cloud-fog'),
  thunderstorm('Thunderstorm', 'cloud-lightning');

  final String label;
  final String icon;
  const WeatherCondition(this.label, this.icon);
}

/// Current weather data from Open-Meteo API
class WeatherData {
  final double temperature; // Celsius
  final WeatherCondition condition;
  final double windSpeed; // km/h
  final int humidity; // percentage
  final bool isDay;

  const WeatherData({
    required this.temperature,
    required this.condition,
    required this.windSpeed,
    required this.humidity,
    required this.isDay,
  });

  /// Whether weather is suitable for outdoor calm activities
  bool get isOutdoorFriendly {
    if (condition == WeatherCondition.rain ||
        condition == WeatherCondition.heavyRain ||
        condition == WeatherCondition.thunderstorm ||
        condition == WeatherCondition.snow) {
      return false;
    }
    if (temperature < 0 || temperature > 40) return false;
    if (windSpeed > 40) return false;
    return true;
  }

  /// Human-readable weather tip
  String get weatherTip {
    if (!isOutdoorFriendly) {
      return 'Indoor calm recommended';
    }
    if (condition == WeatherCondition.clear && temperature > 15 && temperature < 30) {
      return 'Perfect for outdoor calm';
    }
    if (condition == WeatherCondition.partlyCloudy) {
      return 'Great outdoor conditions';
    }
    return 'Good for a calm walk';
  }

  /// Temperature formatted
  String get tempDisplay => '${temperature.round()}°C';

  /// Parse Open-Meteo WMO weather code to condition
  factory WeatherData.fromOpenMeteo(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final weatherCode = current['weather_code'] as int;
    final temp = (current['temperature_2m'] as num).toDouble();
    final wind = (current['wind_speed_10m'] as num).toDouble();
    final humidity = (current['relative_humidity_2m'] as num).toInt();
    final isDay = (current['is_day'] as int) == 1;

    return WeatherData(
      temperature: temp,
      condition: _mapWeatherCode(weatherCode),
      windSpeed: wind,
      humidity: humidity,
      isDay: isDay,
    );
  }

  static WeatherCondition _mapWeatherCode(int code) {
    if (code == 0) return WeatherCondition.clear;
    if (code <= 3) return WeatherCondition.partlyCloudy;
    if (code <= 49) return WeatherCondition.fog;
    if (code <= 59) return WeatherCondition.rain;
    if (code <= 69) return WeatherCondition.snow;
    if (code <= 79) return WeatherCondition.snow;
    if (code <= 82) return WeatherCondition.heavyRain;
    if (code <= 86) return WeatherCondition.snow;
    if (code >= 95) return WeatherCondition.thunderstorm;
    return WeatherCondition.cloudy;
  }
}
