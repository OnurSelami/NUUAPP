import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/weather_data.dart';

/// Weather-aware recommendation chip
class WeatherChip extends StatelessWidget {
  final WeatherData weather;

  const WeatherChip({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_weatherIcon, color: _weatherColor, size: 16),
          const SizedBox(width: 8),
          Text(
            weather.tempDisplay,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 1,
            height: 12,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(width: 6),
          Text(
            weather.weatherTip,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  IconData get _weatherIcon {
    switch (weather.condition) {
      case WeatherCondition.clear:
        return weather.isDay ? LucideIcons.sun : LucideIcons.moon;
      case WeatherCondition.partlyCloudy:
        return LucideIcons.cloudSun;
      case WeatherCondition.cloudy:
        return LucideIcons.cloud;
      case WeatherCondition.rain:
      case WeatherCondition.heavyRain:
        return LucideIcons.cloudRain;
      case WeatherCondition.snow:
        return LucideIcons.snowflake;
      case WeatherCondition.fog:
        return LucideIcons.cloudFog;
      case WeatherCondition.thunderstorm:
        return LucideIcons.cloudLightning;
    }
  }

  Color get _weatherColor {
    if (weather.isOutdoorFriendly) return const Color(0xFF4ADE80);
    return const Color(0xFFFBBF24);
  }
}
