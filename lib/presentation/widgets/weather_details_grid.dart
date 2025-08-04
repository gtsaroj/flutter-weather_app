import 'package:flutter/material.dart';

import '../../core/models/weather_model.dart';
import '../../core/utils/extensions.dart';

class WeatherDetailsGrid extends StatelessWidget {
  final WeatherData weather;

  const WeatherDetailsGrid({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = 2;
    final childAspectRatio = screenWidth < 400 ? 1.0 : 1.2;
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: childAspectRatio,
      children: [
        _buildDetailCard(
          context,
          icon: Icons.air,
          title: 'Wind Speed',
          value: weather.windSpeed.toSpeedString(),
          subtitle: _getWindDescription(weather.windSpeed),
          backgroundColor: _getWindSpeedColor(context, weather.windSpeed),
        ),
        _buildDetailCard(
          context,
          icon: Icons.water_drop,
          title: 'Humidity',
          value: weather.humidity.toPercentageString(),
          subtitle: _getHumidityDescription(weather.humidity),
          backgroundColor: _getHumidityColor(context, weather.humidity),
        ),
        _buildDetailCard(
          context,
          icon: Icons.speed,
          title: 'Pressure',
          value: weather.pressure.toPressureString(),
          subtitle: _getPressureDescription(weather.pressure),
          backgroundColor: _getPressureColor(context, weather.pressure),
        ),
        _buildDetailCard(
          context,
          icon: Icons.visibility,
          title: 'Visibility',
          value: weather.visibility.toVisibilityString(),
          subtitle: _getVisibilityDescription(weather.visibility),
          backgroundColor: _getVisibilityColor(context, weather.visibility),
        ),
        _buildDetailCard(
          context,
          icon: Icons.wb_sunny,
          title: 'UV Index',
          value: weather.uvIndex.toString(),
          subtitle: _getUVIndexDescription(weather.uvIndex),
          backgroundColor: _getUVIndexColor(context, weather.uvIndex),
        ),
        _buildDetailCard(
          context,
          icon: Icons.thermostat,
          title: 'Feels Like',
          value: weather.feelsLike.toTemperatureString(),
          subtitle: 'Apparent temperature',
          backgroundColor: _getFeelsLikeColor(context, weather.feelsLike, weather.temperature),
        ),
      ],
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color backgroundColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor.withOpacity(0.15),
            backgroundColor.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: backgroundColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: backgroundColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: backgroundColor.withOpacity(0.8),
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: backgroundColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getUVIndexDescription(int uvIndex) {
    if (uvIndex <= 2) return 'Low';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'High';
    if (uvIndex <= 10) return 'Very High';
    return 'Extreme';
  }

  // Wind Speed Colors and Descriptions
  Color _getWindSpeedColor(BuildContext context, double windSpeed) {
    if (windSpeed < 10) return Colors.green;
    if (windSpeed < 20) return Colors.yellow.shade700;
    if (windSpeed < 30) return Colors.orange;
    return Colors.red;
  }

  String _getWindDescription(double windSpeed) {
    if (windSpeed < 5) return 'Calm';
    if (windSpeed < 10) return 'Light breeze';
    if (windSpeed < 20) return 'Moderate breeze';
    if (windSpeed < 30) return 'Strong breeze';
    return 'High wind';
  }

  // Humidity Colors and Descriptions
  Color _getHumidityColor(BuildContext context, int humidity) {
    if (humidity < 30) return Colors.red.shade600;
    if (humidity < 40) return Colors.orange;
    if (humidity < 60) return Colors.green;
    if (humidity < 70) return Colors.blue.shade600;
    return Colors.indigo;
  }

  String _getHumidityDescription(int humidity) {
    if (humidity < 30) return 'Too dry';
    if (humidity < 40) return 'Dry';
    if (humidity < 60) return 'Comfortable';
    if (humidity < 70) return 'Humid';
    return 'Very humid';
  }

  // Pressure Colors and Descriptions
  Color _getPressureColor(BuildContext context, int pressure) {
    if (pressure < 1000) return Colors.red.shade700;
    if (pressure < 1013) return Colors.orange;
    if (pressure < 1020) return Colors.green;
    if (pressure < 1030) return Colors.blue.shade600;
    return Colors.purple;
  }

  String _getPressureDescription(int pressure) {
    if (pressure < 1000) return 'Very low';
    if (pressure < 1013) return 'Low';
    if (pressure < 1020) return 'Normal';
    if (pressure < 1030) return 'High';
    return 'Very high';
  }

  // Visibility Colors and Descriptions
  Color _getVisibilityColor(BuildContext context, int visibility) {
    if (visibility < 1) return Colors.red.shade700;
    if (visibility < 5) return Colors.orange;
    if (visibility < 10) return Colors.yellow.shade700;
    if (visibility < 20) return Colors.green;
    return Colors.blue.shade600;
  }

  String _getVisibilityDescription(int visibility) {
    if (visibility < 1) return 'Very poor';
    if (visibility < 5) return 'Poor';
    if (visibility < 10) return 'Moderate';
    if (visibility < 20) return 'Good';
    return 'Excellent';
  }

  // UV Index Colors
  Color _getUVIndexColor(BuildContext context, int uvIndex) {
    if (uvIndex <= 2) return Colors.green;
    if (uvIndex <= 5) return Colors.yellow.shade700;
    if (uvIndex <= 7) return Colors.orange;
    if (uvIndex <= 10) return Colors.red;
    return Colors.purple;
  }

  // Feels Like Colors
  Color _getFeelsLikeColor(BuildContext context, double feelsLike, double actualTemp) {
    final diff = (feelsLike - actualTemp).abs();
    if (diff < 2) return Colors.green;
    if (diff < 5) return Colors.yellow.shade700;
    if (diff < 8) return Colors.orange;
    return Colors.red;
  }
}