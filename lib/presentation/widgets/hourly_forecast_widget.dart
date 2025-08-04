import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/models/weather_model.dart';
import '../../core/services/weather_service.dart';
import '../../core/utils/extensions.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> forecasts;

  const HourlyForecastWidget({
    super.key,
    required this.forecasts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecasts.take(24).length,
        itemBuilder: (context, index) {
          final forecast = forecasts[index];
          final isNow = index == 0;
          final weatherService = WeatherService();

          return Container(
            width: 80,
            margin: EdgeInsets.only(
              right: index < forecasts.length - 1 ? 12 : 0,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isNow ? colorScheme.primary : colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Time
                Text(
                  isNow ? 'Now' : forecast.dateTime.toTimeString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isNow 
                        ? colorScheme.onPrimary 
                        : colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                // Weather Icon
                CachedNetworkImage(
                  imageUrl: weatherService.getWeatherIconUrl(forecast.icon),
                  width: 32,
                  height: 32,
                  placeholder: (context, url) => Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (isNow ? colorScheme.onPrimary : colorScheme.onSurface)
                          .withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.wb_sunny,
                      color: isNow ? colorScheme.onPrimary : colorScheme.onSurface,
                      size: 16,
                    ),
                  ),
                  errorWidget: (context, url, error) => Text(
                    weatherService.getWeatherConditionIcon('clear', forecast.icon),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                
                // Temperature
                Text(
                  forecast.temperature.toTemperatureString(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isNow ? colorScheme.onPrimary : colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}