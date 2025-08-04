# Quick Setup Instructions

## 🚀 Get Started in 5 Steps

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Firebase Setup
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Authentication → Email/Password
3. Add your app and download config files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
4. Run: `flutterfire configure`

### 3. Weather API Setup
1. Get API key from [OpenWeatherMap](https://openweathermap.org/api)
2. Replace `demo_key_replace_with_real_key` in `lib/core/config/app_config.dart` with your actual API key

### 4. Run the App
```bash
flutter run
```

### 5. Build for Production
```bash
# Android
flutter build appbundle --release

# iOS  
flutter build ipa --release
```

## ⚠️ Important Notes

- **API Key**: Don't forget to replace the demo API key with your real OpenWeatherMap API key
- **Permissions**: Location permissions are pre-configured in AndroidManifest.xml and Info.plist
- **Firebase**: Ensure firebase configuration files are in the correct locations
- **Environment**: Create a `.env` file for additional configuration (optional)

## 🔧 Troubleshooting

**Firebase Issues**: Run `flutterfire configure` again
**API Issues**: Check your OpenWeatherMap API key is active
**Location Issues**: Test on a physical device with location services enabled

## 📱 Features Included

✅ User Authentication (Firebase)  
✅ Real-time Weather Data  
✅ Dark/Light Mode Toggle  
✅ Responsive UI Design  
✅ 7-Day Forecast  
✅ Hourly Forecast  
✅ City Search  
✅ Location-based Weather  
✅ Weather Details (humidity, wind, pressure, etc.)  
✅ Beautiful Weather Gradients  
✅ Shimmer Loading Effects  

**Ready to use! No additional setup required.**