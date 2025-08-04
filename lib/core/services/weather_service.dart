import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../config/app_config.dart';

class WeatherService {
  static const String _baseUrl = AppConfig.weatherApiBaseUrl;
  static const String _apiKey = AppConfig.weatherApiKey;
  
  Future<WeatherData> getCurrentWeather(double lat, double lon) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<Map<String, List<dynamic>>> getForecast(double lat, double lon) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecastList = data['list'];
        
        // Group forecast data
        final List<HourlyForecast> hourlyForecast = [];
        final Map<String, DailyForecast> dailyMap = {};
        
        for (var item in forecastList) {
          final hourly = HourlyForecast.fromJson(item);
          hourlyForecast.add(hourly);
          
          // Group by date for daily forecast
          final dateKey = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000)
              .toIso8601String()
              .split('T')[0];
          
          if (!dailyMap.containsKey(dateKey)) {
            dailyMap[dateKey] = DailyForecast.fromJson(item);
          } else {
            // Update with max/min temperatures
            final existing = dailyMap[dateKey]!;
            final temp = (item['main']['temp'] as num).toDouble();
            dailyMap[dateKey] = DailyForecast(
              date: existing.date,
              maxTemp: temp > existing.maxTemp ? temp : existing.maxTemp,
              minTemp: temp < existing.minTemp ? temp : existing.minTemp,
              description: existing.description,
              icon: existing.icon,
              humidity: existing.humidity,
              windSpeed: existing.windSpeed,
            );
          }
        }
        
        return {
          'hourly': hourlyForecast.take(24).toList(), // Next 24 hours
          'daily': dailyMap.values.take(7).toList(), // Next 7 days
        };
      } else {
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<WeatherData> getWeatherByCity(String cityName) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('City not found');
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<List<LocationData>> searchCities(String query) async {
    try {
      final url = Uri.parse(
        'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$_apiKey'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => LocationData(
          latitude: (item['lat'] as num).toDouble(),
          longitude: (item['lon'] as num).toDouble(),
          cityName: item['name'] as String,
          country: item['country'] as String,
        )).toList();
      } else {
        throw Exception('Failed to search cities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }
  
  String getWeatherConditionIcon(String main, String icon) {
    // Map weather conditions to local icons if needed
    switch (main.toLowerCase()) {
      case 'clear':
        return icon.contains('d') ? '☀️' : '🌙';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }
}