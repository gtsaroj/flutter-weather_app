import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static late SharedPreferences _prefs;
  
  // API Configuration
  static const String weatherApiKey = 'e2df8a06f353aab10c3482383948698e';
  static const String weatherApiBaseUrl = 'https://api.openweathermap.org/data/2.5';
  
  // App Configuration
  static const String appName = 'Weather App';
  static const String appVersion = '1.0.0';
  
  // Theme Configuration
  static const String themeKey = 'theme_mode';
  static const String locationPermissionKey = 'location_permission_granted';
  static const String lastKnownLocationKey = 'last_known_location';
  
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  static SharedPreferences get prefs => _prefs;
  
  // Theme Methods
  static Future<void> setThemeMode(String themeMode) async {
    await _prefs.setString(themeKey, themeMode);
  }
  
  static String getThemeMode() {
    return _prefs.getString(themeKey) ?? 'system';
  }
  
  // Location Methods
  static Future<void> setLocationPermissionGranted(bool granted) async {
    await _prefs.setBool(locationPermissionKey, granted);
  }
  
  static bool isLocationPermissionGranted() {
    return _prefs.getBool(locationPermissionKey) ?? false;
  }
  
  // Last Known Location
  static Future<void> setLastKnownLocation(double lat, double lon) async {
    await _prefs.setDouble('last_lat', lat);
    await _prefs.setDouble('last_lon', lon);
  }
  
  static Map<String, double>? getLastKnownLocation() {
    final lat = _prefs.getDouble('last_lat');
    final lon = _prefs.getDouble('last_lon');
    
    if (lat != null && lon != null) {
      return {'lat': lat, 'lon': lon};
    }
    return null;
  }
}