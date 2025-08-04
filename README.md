# Weather App 🌤️

A professional-grade Weather Application built with Flutter, featuring real-time weather data, user authentication, and a beautiful responsive UI with dark/light mode support.

## Features ✨

### 🔐 User Authentication
- Secure Firebase Authentication with email/password
- User registration and login
- Password reset functionality
- Persistent authentication state

### 🌍 Real-time Weather Data
- Current weather conditions with detailed information
- 24-hour hourly forecast
- 7-day daily forecast
- Location-based weather detection
- City search functionality
- Weather condition icons and gradients

### 🎨 Modern UI/UX
- Clean, responsive design
- Material Design 3 components
- Custom weather-themed gradients
- Smooth animations and transitions
- Shimmer loading effects
- Professional weather cards and widgets

### 🌓 Dark/Light Mode Toggle
- System-adaptive theme switching
- Manual theme selection
- Consistent theming across all components
- Accessibility-friendly color schemes

### 📱 Additional Features
- Popular cities quick search
- Detailed weather metrics (humidity, wind speed, pressure, visibility, UV index)
- Sunrise/sunset times
- Location permission handling
- Error handling with retry functionality
- Pull-to-refresh functionality

## Screenshots 📸

*Add screenshots of your app here*

## Tech Stack 🛠️

- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Authentication**: Firebase Auth
- **API**: OpenWeatherMap API
- **Location Services**: Geolocator
- **UI Components**: Material Design 3
- **Fonts**: Google Fonts (Inter)
- **Images**: Cached Network Image
- **Loading**: Shimmer

## Getting Started 🚀

### Prerequisites

- Flutter SDK (3.0 or higher)
- Android Studio / VS Code
- Firebase project
- OpenWeatherMap API key

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd weatherapp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   
   a. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   
   b. Enable Authentication with Email/Password provider
   
   c. Add your Android/iOS app to the Firebase project
   
   d. Download and place the configuration files:
   - `google-services.json` in `android/app/`
   - `GoogleService-Info.plist` in `ios/Runner/`
   
   e. Run Firebase CLI to generate configuration:
   ```bash
   firebase login
   flutterfire configure
   ```

4. **Weather API Setup**
   
   a. Get your free API key from [OpenWeatherMap](https://openweathermap.org/api)
   
   b. Create a `.env` file in the root directory:
   ```env
   WEATHER_API_KEY=your_openweathermap_api_key_here
   WEATHER_API_BASE_URL=https://api.openweathermap.org/data/2.5
   ```
   
   c. Update the API key in `lib/core/config/app_config.dart`:
   ```dart
   static const String weatherApiKey = 'your_actual_api_key_here';
   ```

5. **Configure Permissions**
   
   **Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   ```
   
   **iOS** (`ios/Runner/Info.plist`):
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>This app needs location access to provide weather information for your area.</string>
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure 📁

```
lib/
├── core/
│   ├── config/          # App configuration
│   ├── models/          # Data models
│   ├── providers/       # State management
│   ├── services/        # API and business logic
│   ├── theme/           # App theming
│   └── utils/           # Utilities and extensions
├── presentation/
│   ├── pages/           # Screen widgets
│   │   ├── auth/        # Authentication screens
│   │   ├── home/        # Home screen
│   │   ├── search/      # Search functionality
│   │   └── settings/    # Settings screen
│   └── widgets/         # Reusable UI components
└── main.dart           # App entry point
```

## Configuration Files 📝

### Firebase Configuration
After running `flutterfire configure`, you'll get:
- `lib/firebase_options.dart` - Generated Firebase configuration
- `android/app/google-services.json` - Android configuration
- `ios/Runner/GoogleService-Info.plist` - iOS configuration

### Environment Variables
Create a `.env` file (see `.env.example`) with:
- `WEATHER_API_KEY` - Your OpenWeatherMap API key
- `WEATHER_API_BASE_URL` - Weather API base URL

## API Integration 🌐

This app uses the OpenWeatherMap API for weather data:
- Current Weather API
- 5-day Weather Forecast API
- Geocoding API for city search

### API Endpoints Used:
- `GET /weather` - Current weather data
- `GET /forecast` - 5-day forecast
- `GET /geo/1.0/direct` - City geocoding

## State Management 📊

The app uses Provider for state management with three main providers:
- `AuthProvider` - Handles authentication state
- `WeatherProvider` - Manages weather data and API calls
- `ThemeProvider` - Controls app theming

## Performance Optimizations ⚡

- Lazy loading of weather data
- Cached network images
- Shimmer loading placeholders
- Efficient widget rebuilding with Consumer widgets
- Proper memory management with dispose methods

## Testing 🧪

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## Build for Production 🏗️

### Android
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ipa --release
```

## Contributing 🤝

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Troubleshooting 🔧

### Common Issues:

1. **Firebase not connecting**
   - Ensure `google-services.json` and `GoogleService-Info.plist` are in correct locations
   - Run `flutterfire configure` again

2. **Weather API not working**
   - Check your API key is correct and active
   - Verify API key has necessary permissions

3. **Location not working**
   - Ensure location permissions are granted
   - Check physical device location services are enabled

4. **Build issues**
   - Clean and rebuild: `flutter clean && flutter pub get`
   - Check Flutter doctor: `flutter doctor`

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments 🙏

- [OpenWeatherMap](https://openweathermap.org/) for weather data API
- [Firebase](https://firebase.google.com/) for authentication services
- [Flutter](https://flutter.dev/) team for the amazing framework
- Material Design team for design guidelines

## Support 💬

If you have any questions or run into issues, please:
1. Check the troubleshooting section
2. Search existing issues
3. Create a new issue with detailed information

---

**Built with ❤️ and Flutter**