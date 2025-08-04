import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/models/weather_model.dart';
import '../../core/services/weather_service.dart';
import '../../core/utils/extensions.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecast> forecasts;

  const DailyForecastWidget({
    super.key,
    required this.forecasts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: forecasts.take(7).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final forecast = entry.value;
          final isToday = forecast.date.isToday();
          final isTomorrow = forecast.date.isTomorrow();
          final weatherService = WeatherService();
          final displayedCount = forecasts.take(7).length;

          String dayLabel;
          if (isToday) {
            dayLabel = 'Today';
          } else if (isTomorrow) {
            dayLabel = 'Tomorrow';
          } else {
            dayLabel = forecast.date.toDayString();
          }

          return Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: index < displayedCount - 1
                  ? Border(
                      bottom: BorderSide(
                        color: colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Day
                Expanded(
                  flex: 3,
                  child: Text(
                    dayLabel,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                
                // Weather Icon and Description
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      CachedNetworkImage(
                        imageUrl: weatherService.getWeatherIconUrl(forecast.icon),
                        width: 28,
                        height: 28,
                        placeholder: (context, url) => Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.wb_sunny,
                            color: colorScheme.onSurface,
                            size: 14,
                          ),
                        ),
                        errorWidget: (context, url, error) => Text(
                          weatherService.getWeatherConditionIcon('clear', forecast.icon),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          forecast.description.capitalizeWords(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Humidity (only show on larger screens)
                if (MediaQuery.of(context).size.width > 350)
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          forecast.humidity.toPercentageString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Temperature Range
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        forecast.minTemp.toTemperatureString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        forecast.maxTemp.toTemperatureString(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}