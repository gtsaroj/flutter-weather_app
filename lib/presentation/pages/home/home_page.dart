import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/weather_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../widgets/weather_card.dart';
import '../../widgets/hourly_forecast_widget.dart';
import '../../widgets/daily_forecast_widget.dart';
import '../../widgets/weather_details_grid.dart';
import '../../widgets/shimmer_loading.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWeatherData();
    });
  }

  Future<void> _initializeWeatherData() async {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    if (!weatherProvider.hasData) {
      await weatherProvider.initializeWeather();
    }
  }

  Future<void> _refreshData() async {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    await weatherProvider.refreshWeather();
  }

  String _getGreetingBasedOnNepaliTime() {
    // Get current UTC time and convert to Nepal time (UTC+5:45)
    final now = DateTime.now().toUtc();
    final nepaliTime = now.add(const Duration(hours: 5, minutes: 45));
    final hour = nepaliTime.hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Access'),
        content: const Text(
          'This app needs location access to provide accurate weather information for your area.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeWeatherData();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Consumer3<WeatherProvider, AuthProvider, ThemeProvider>(
        builder: (context, weatherProvider, authProvider, themeProvider, child) {
          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 0,
                toolbarHeight: 64,
                floating: false,
                pinned: true,
                backgroundColor: colorScheme.background,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.only(left: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getGreetingBasedOnNepaliTime(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onBackground.withOpacity(0.6),
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              authProvider.userName ?? 
                              authProvider.user?.email?.split('@')[0] ?? 
                              'Guest',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onBackground,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                leadingWidth: 160,
                title: Text(
                  'Weather',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
                actions: [
                  // Search Button
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: colorScheme.onBackground,
                      size: 22,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/search');
                    },
                  ),
                  
                  // Theme Toggle
                  IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: colorScheme.onBackground,
                      size: 22,
                    ),
                    onPressed: () {
                      themeProvider.toggleTheme();
                    },
                  ),
                  
                  // Menu Button
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: colorScheme.onBackground,
                      size: 22,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'settings':
                          Navigator.of(context).pushNamed('/settings');
                          break;
                        case 'refresh':
                          _refreshData();
                          break;
                        case 'logout':
                          authProvider.signOut();
                          Navigator.of(context).pushReplacementNamed('/login');
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'settings',
                        child: Row(
                          children: [
                            Icon(Icons.settings),
                            SizedBox(width: 8),
                            Text('Settings'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'refresh',
                        child: Row(
                          children: [
                            Icon(Icons.refresh),
                            SizedBox(width: 8),
                            Text('Refresh'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text('Sign Out'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Content
              SliverToBoxAdapter(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildContent(weatherProvider),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(WeatherProvider weatherProvider) {
    if (weatherProvider.isLoading && !weatherProvider.hasData) {
      return const ShimmerLoading();
    }

    if (weatherProvider.errorMessage != null && !weatherProvider.hasData) {
      return _buildErrorState(weatherProvider);
    }

    if (weatherProvider.currentWeather == null) {
      return _buildEmptyState();
    }

    final weather = weatherProvider.currentWeather!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Weather Card
        WeatherCard(weather: weather),
        const SizedBox(height: 24),
        
        // Hourly Forecast
        if (weather.hourlyForecast.isNotEmpty) ...[
          Text(
            'Hourly Forecast',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          HourlyForecastWidget(forecasts: weather.hourlyForecast),
          const SizedBox(height: 24),
        ],
        
        // Weather Details
        Text(
          'Weather Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        WeatherDetailsGrid(weather: weather),
        const SizedBox(height: 24),
        
        // Daily Forecast
        if (weather.dailyForecast.isNotEmpty) ...[
          Text(
            '7-Day Forecast',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          DailyForecastWidget(forecasts: weather.dailyForecast),
        ],
      ],
    );
  }

  Widget _buildErrorState(WeatherProvider weatherProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              weatherProvider.errorMessage ?? 'Unable to load weather data',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              children: [
                TextButton(
                  onPressed: _showLocationDialog,
                  child: const Text('Check Location'),
                ),
                ElevatedButton(
                  onPressed: _refreshData,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to Weather App',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Get started by allowing location access or searching for a city',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/search');
                  },
                  child: const Text('Search City'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _initializeWeatherData,
                  child: const Text('Use Location'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}