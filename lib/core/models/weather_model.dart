import 'package:equatable/equatable.dart';

class WeatherData extends Equatable {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final int visibility;
  final int uvIndex;
  final String description;
  final String main;
  final String icon;
  final String cityName;
  final String country;
  final DateTime dateTime;
  final DateTime sunrise;
  final DateTime sunset;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  const WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.description,
    required this.main,
    required this.icon,
    required this.cityName,
    required this.country,
    required this.dateTime,
    required this.sunrise,
    required this.sunset,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      pressure: json['main']['pressure'] as int,
      visibility: json['visibility'] as int? ?? 10000,
      uvIndex: 0, // Will be updated from UV index API call
      description: json['weather'][0]['description'] as String,
      main: json['weather'][0]['main'] as String,
      icon: json['weather'][0]['icon'] as String,
      cityName: json['name'] as String,
      country: json['sys']['country'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      sunrise: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000),
      hourlyForecast: [], // Will be populated from forecast API
      dailyForecast: [], // Will be populated from forecast API
    );
  }

  WeatherData copyWith({
    double? temperature,
    double? feelsLike,
    int? humidity,
    double? windSpeed,
    int? pressure,
    int? visibility,
    int? uvIndex,
    String? description,
    String? main,
    String? icon,
    String? cityName,
    String? country,
    DateTime? dateTime,
    DateTime? sunrise,
    DateTime? sunset,
    List<HourlyForecast>? hourlyForecast,
    List<DailyForecast>? dailyForecast,
  }) {
    return WeatherData(
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      pressure: pressure ?? this.pressure,
      visibility: visibility ?? this.visibility,
      uvIndex: uvIndex ?? this.uvIndex,
      description: description ?? this.description,
      main: main ?? this.main,
      icon: icon ?? this.icon,
      cityName: cityName ?? this.cityName,
      country: country ?? this.country,
      dateTime: dateTime ?? this.dateTime,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
      dailyForecast: dailyForecast ?? this.dailyForecast,
    );
  }

  @override
  List<Object?> get props => [
        temperature,
        feelsLike,
        humidity,
        windSpeed,
        pressure,
        visibility,
        uvIndex,
        description,
        main,
        icon,
        cityName,
        country,
        dateTime,
        sunrise,
        sunset,
        hourlyForecast,
        dailyForecast,
      ];
}

class HourlyForecast extends Equatable {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;

  const HourlyForecast({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
      icon: json['weather'][0]['icon'] as String,
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [dateTime, temperature, description, icon, humidity, windSpeed];
}

class DailyForecast extends Equatable {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;

  const DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      maxTemp: (json['main']['temp_max'] as num).toDouble(),
      minTemp: (json['main']['temp_min'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
      icon: json['weather'][0]['icon'] as String,
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [date, maxTemp, minTemp, description, icon, humidity, windSpeed];
}

class LocationData extends Equatable {
  final double latitude;
  final double longitude;
  final String cityName;
  final String country;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.country,
  });

  @override
  List<Object?> get props => [latitude, longitude, cityName, country];
}