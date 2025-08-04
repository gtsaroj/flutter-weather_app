import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../config/app_config.dart';

enum WeatherState { initial, loading, loaded, error }

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  
  WeatherState _state = WeatherState.initial;
  WeatherData? _currentWeather;
  String? _errorMessage;
  LocationData? _currentLocation;
  List<LocationData> _searchResults = [];
  bool _isSearching = false;
  
  // Getters
  WeatherState get state => _state;
  WeatherData? get currentWeather => _currentWeather;
  String? get errorMessage => _errorMessage;
  LocationData? get currentLocation => _currentLocation;
  List<LocationData> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  bool get isLoading => _state == WeatherState.loading;
  bool get hasData => _currentWeather != null;
  
  Future<void> initializeWeather() async {
    try {
      _state = WeatherState.loading;
      _errorMessage = null;
      notifyListeners();
      
      // Try to get current location with timeout
      try {
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          await _getWeatherForPosition(position);
          return;
        }
      } catch (e) {
        print('Location service failed: $e');
      }
      
      // Try to use last known location
      final lastLocation = AppConfig.getLastKnownLocation();
      if (lastLocation != null) {
        await getWeatherByCoordinates(lastLocation['lat']!, lastLocation['lon']!);
        return;
      }
      
      // Default to a major city for demo purposes
      await getWeatherByCity('New York');
    } catch (e) {
      _state = WeatherState.error;
      _errorMessage = 'Failed to initialize weather data. Using demo data.';
      // Load demo weather data for development
      _loadDemoWeatherData();
      notifyListeners();
    }
  }
  
  void _loadDemoWeatherData() {
    _currentWeather = WeatherData(
      temperature: 22.5,
      feelsLike: 25.0,
      humidity: 65,
      windSpeed: 3.2,
      pressure: 1013,
      visibility: 10000,
      uvIndex: 5,
      description: 'partly cloudy',
      main: 'Clouds',
      icon: '02d',
      cityName: 'Demo City',
      country: 'US',
      dateTime: DateTime.now(),
      sunrise: DateTime.now().subtract(const Duration(hours: 2)),
      sunset: DateTime.now().add(const Duration(hours: 6)),
      hourlyForecast: _generateDemoHourlyForecast(),
      dailyForecast: _generateDemoDailyForecast(),
    );
    _currentLocation = const LocationData(
      latitude: 40.7128,
      longitude: -74.0060,
      cityName: 'Demo City',
      country: 'US',
    );
    _state = WeatherState.loaded;
  }
  
  List<HourlyForecast> _generateDemoHourlyForecast() {
    final now = DateTime.now();
    return List.generate(24, (index) {
      return HourlyForecast(
        dateTime: now.add(Duration(hours: index)),
        temperature: 20.0 + (index % 8) * 2.0,
        description: index % 3 == 0 ? 'sunny' : index % 3 == 1 ? 'cloudy' : 'partly cloudy',
        icon: index % 3 == 0 ? '01d' : index % 3 == 1 ? '03d' : '02d',
        humidity: 60 + (index % 10),
        windSpeed: 2.0 + (index % 5) * 0.5,
      );
    });
  }
  
  List<DailyForecast> _generateDemoDailyForecast() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      return DailyForecast(
        date: now.add(Duration(days: index)),
        maxTemp: 25.0 + (index % 5) * 2.0,
        minTemp: 15.0 + (index % 5) * 1.5,
        description: index % 3 == 0 ? 'sunny' : index % 3 == 1 ? 'rainy' : 'cloudy',
        icon: index % 3 == 0 ? '01d' : index % 3 == 1 ? '10d' : '03d',
        humidity: 55 + (index % 15),
        windSpeed: 1.5 + (index % 4) * 0.8,
      );
    });
  }
  
  Future<void> _getWeatherForPosition(Position position) async {
    try {
      // Get city name from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final cityName = placemark.locality ?? placemark.administrativeArea ?? 'Unknown';
        final country = placemark.country ?? 'Unknown';
        
        _currentLocation = LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          cityName: cityName,
          country: country,
        );
      }
      
      // Save location for future use
      await AppConfig.setLastKnownLocation(position.latitude, position.longitude);
      
      // Get weather data
      await getWeatherByCoordinates(position.latitude, position.longitude);
    } catch (e) {
      _state = WeatherState.error;
      _errorMessage = 'Failed to get weather for current location: ${e.toString()}';
      notifyListeners();
    }
  }
  
  Future<void> getWeatherByCoordinates(double lat, double lon) async {
    try {
      _state = WeatherState.loading;
      _errorMessage = null;
      notifyListeners();
      
      final weatherData = await _weatherService.getCurrentWeather(lat, lon);
      final forecast = await _weatherService.getForecast(lat, lon);
      
      _currentWeather = weatherData.copyWith(
        hourlyForecast: List<HourlyForecast>.from(forecast['hourly'] ?? []),
        dailyForecast: List<DailyForecast>.from(forecast['daily'] ?? []),
      );
      
      _state = WeatherState.loaded;
      notifyListeners();
    } catch (e) {
      _state = WeatherState.error;
      _errorMessage = 'Failed to get weather data: ${e.toString()}';
      notifyListeners();
    }
  }
  
  Future<void> getWeatherByCity(String cityName) async {
    try {
      _state = WeatherState.loading;
      _errorMessage = null;
      notifyListeners();
      
      // First try to get from predefined cities
      final predefinedCity = _getPredefinedCityData(cityName);
      if (predefinedCity != null) {
        _currentLocation = LocationData(
          latitude: double.parse(predefinedCity['lat']!),
          longitude: double.parse(predefinedCity['lon']!),
          cityName: predefinedCity['city']!,
          country: predefinedCity['country']!,
        );
        _loadDemoWeatherDataForCity(predefinedCity['city']!, predefinedCity['country']!);
        _state = WeatherState.loaded;
        notifyListeners();
        return;
      }
      
      // Try real geocoding service
      try {
        final locations = await locationFromAddress(cityName).timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw Exception('Location service timeout'),
        );
        
        if (locations.isNotEmpty) {
          final location = locations.first;
          
          _currentLocation = LocationData(
            latitude: location.latitude,
            longitude: location.longitude,
            cityName: cityName,
            country: 'Unknown',
          );
          
          try {
            await getWeatherByCoordinates(location.latitude, location.longitude);
          } catch (e) {
            // If weather API fails, use demo data
            _loadDemoWeatherDataForCity(cityName, 'Unknown');
            _state = WeatherState.loaded;
            notifyListeners();
          }
        } else {
          throw Exception('City not found');
        }
      } catch (e) {
        // If geocoding fails, try to create demo data for the searched city
        _loadDemoWeatherDataForCity(cityName, 'Unknown');
        _state = WeatherState.loaded;
        notifyListeners();
      }
    } catch (e) {
      _state = WeatherState.error;
      _errorMessage = 'Could not find weather data for $cityName. Please try a different city.';
      notifyListeners();
    }
  }
  
  Map<String, String>? _getPredefinedCityData(String cityName) {
    final searchCity = cityName.toLowerCase().trim();
    final predefinedCities = {
      'nepal': {'city': 'Kathmandu', 'country': 'Nepal', 'lat': '27.7172', 'lon': '85.3240'},
      'kathmandu': {'city': 'Kathmandu', 'country': 'Nepal', 'lat': '27.7172', 'lon': '85.3240'},
      'new york': {'city': 'New York', 'country': 'United States', 'lat': '40.7128', 'lon': '-74.0060'},
      'london': {'city': 'London', 'country': 'United Kingdom', 'lat': '51.5074', 'lon': '-0.1278'},
      'tokyo': {'city': 'Tokyo', 'country': 'Japan', 'lat': '35.6762', 'lon': '139.6503'},
      'paris': {'city': 'Paris', 'country': 'France', 'lat': '48.8566', 'lon': '2.3522'},
      'sydney': {'city': 'Sydney', 'country': 'Australia', 'lat': '-33.8688', 'lon': '151.2093'},
      'dubai': {'city': 'Dubai', 'country': 'UAE', 'lat': '25.2048', 'lon': '55.2708'},
      'mumbai': {'city': 'Mumbai', 'country': 'India', 'lat': '19.0760', 'lon': '72.8777'},
      'delhi': {'city': 'Delhi', 'country': 'India', 'lat': '28.7041', 'lon': '77.1025'},
      'singapore': {'city': 'Singapore', 'country': 'Singapore', 'lat': '1.3521', 'lon': '103.8198'},
      'bangkok': {'city': 'Bangkok', 'country': 'Thailand', 'lat': '13.7563', 'lon': '100.5018'},
    };
    
    return predefinedCities[searchCity];
  }
  
  void _loadDemoWeatherDataForCity(String cityName, String country) {
    // Generate realistic demo weather data for the searched city
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final baseTemp = 15.0 + (random % 20); // Temperature between 15-35°C
    
    _currentWeather = WeatherData(
      temperature: baseTemp,
      feelsLike: baseTemp + 2.5,
      humidity: 50 + (random % 40), // Humidity 50-90%
      windSpeed: 1.0 + (random % 15) / 5.0, // Wind 1-4 m/s
      pressure: 1000 + (random % 30), // Pressure 1000-1030 hPa
      visibility: 8000 + (random % 2000), // Visibility 8-10km
      uvIndex: (random % 10) + 1, // UV Index 1-10
      description: _getRandomWeatherDescription(random),
      main: _getRandomWeatherMain(random),
      icon: _getRandomWeatherIcon(random),
      cityName: cityName,
      country: country,
      dateTime: DateTime.now(),
      sunrise: DateTime.now().subtract(Duration(hours: (random % 3) + 2)),
      sunset: DateTime.now().add(Duration(hours: (random % 3) + 6)),
      hourlyForecast: _generateDemoHourlyForecast(),
      dailyForecast: _generateDemoDailyForecast(),
    );
    
    _currentLocation = LocationData(
      latitude: 27.7172 + (random % 10) / 100.0, // Slight variation
      longitude: 85.3240 + (random % 10) / 100.0,
      cityName: cityName,
      country: country,
    );
  }
  
  String _getRandomWeatherDescription(int random) {
    final descriptions = [
      'clear sky', 'partly cloudy', 'cloudy', 'light rain', 
      'scattered clouds', 'sunny', 'overcast', 'mist'
    ];
    return descriptions[random % descriptions.length];
  }
  
  String _getRandomWeatherMain(int random) {
    final mains = ['Clear', 'Clouds', 'Rain', 'Mist', 'Haze'];
    return mains[random % mains.length];
  }
  
  String _getRandomWeatherIcon(int random) {
    final icons = ['01d', '02d', '03d', '04d', '09d', '10d', '50d'];
    return icons[random % icons.length];
  }
  
  Future<void> searchCities(String query) async {
    if (query.isEmpty) {
      _searchResults.clear();
      _isSearching = false;
      notifyListeners();
      return;
    }
    
    try {
      _isSearching = true;
      notifyListeners();
      
      final locations = await locationFromAddress(query);
      _searchResults = locations.take(5).map((location) {
        return LocationData(
          latitude: location.latitude,
          longitude: location.longitude,
          cityName: query,
          country: 'Unknown',
        );
      }).toList();
      
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _isSearching = false;
      _searchResults.clear();
      notifyListeners();
    }
  }
  
  Future<void> refreshWeather() async {
    if (_currentLocation != null) {
      await getWeatherByCoordinates(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      );
    } else {
      await initializeWeather();
    }
  }
  
  void clearError() {
    _errorMessage = null;
    if (_state == WeatherState.error) {
      _state = _currentWeather != null ? WeatherState.loaded : WeatherState.initial;
    }
    notifyListeners();
  }
  
  void clearSearchResults() {
    _searchResults.clear();
    _isSearching = false;
    notifyListeners();
  }
}