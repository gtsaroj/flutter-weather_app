import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/weather_provider.dart';
import '../../../core/utils/extensions.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _searchResults = [];
  bool _isSearching = false;
  String _currentQuery = '';
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _searchCity(String cityName) async {
    if (cityName.trim().isEmpty) return;
    
    _searchFocusNode.unfocus();
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    await weatherProvider.getWeatherByCity(cityName.trim());
    
    if (!weatherProvider.isLoading && weatherProvider.currentWeather != null) {
      if (mounted) {
        Navigator.of(context).pop();
        context.showSnackBar('Weather updated for ${cityName.capitalizeWords()}');
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _currentQuery = query;
      _isSearching = query.isNotEmpty;
    });
    
    if (query.length >= 2) {
      _performSearch(query);
    } else {
      setState(() {
        _searchResults.clear();
      });
    }
  }

  void _performSearch(String query) {
    // Filter cities that match the query
    final results = _allCities
        .where((city) => 
            city['name']!.toLowerCase().contains(query.toLowerCase()) ||
            city['country']!.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .map((city) => '${city['name']}, ${city['country']}')
        .toList();
    
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Consumer<WeatherProvider>(
          builder: (context, weatherProvider, child) {
            return Column(
              children: [
                // Custom App Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Search Location',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Find weather in any city worldwide',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Field with improved design
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: _onSearchChanged,
                            onSubmitted: (value) => _searchCity(value),
                            decoration: InputDecoration(
                              hintText: 'Search for cities...',
                              hintStyle: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              suffixIcon: _currentQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        
                        // Search Results
                        if (_isSearching && _searchResults.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: _searchResults.map((result) {
                                final parts = result.split(', ');
                                final cityName = parts[0];
                                final countryName = parts.length > 1 ? parts[1] : '';
                                
                                return ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.location_city,
                                      color: colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    cityName,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    countryName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: colorScheme.onSurface.withOpacity(0.4),
                                  ),
                                  onTap: () => _searchCity(cityName),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                        
                        // Error Message
                        if (weatherProvider.errorMessage != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade700,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Location not found',
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        weatherProvider.errorMessage!,
                                        style: TextStyle(
                                          color: Colors.red.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 32),
                        
                        // Popular Cities Header
                        Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Popular Destinations',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Professional Grid of Popular Cities
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final screenWidth = MediaQuery.of(context).size.width;
                            final crossAxisCount = screenWidth < 600 ? 2 : 3;
                            final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;
                            final aspectRatio = itemWidth > 180 ? 1.4 : 1.2;
                            
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: aspectRatio,
                              ),
                              itemCount: _popularCities.length,
                              itemBuilder: (context, index) {
                                final city = _popularCities[index];
                                return _buildProfessionalCityCard(
                                  context,
                                  cityName: city['name']!,
                                  countryName: city['country']!,
                                  countryCode: city['code']!,
                                  emoji: city['emoji']!,
                                  onTap: () => _searchCity(city['name']!),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfessionalCityCard(
    BuildContext context, {
    required String cityName,
    required String countryName,
    required String countryCode,
    required String emoji,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing
    final cardPadding = screenWidth < 400 ? 12.0 : 16.0;
    final emojiSize = screenWidth < 400 ? 14.0 : 16.0;
    final titleFontSize = screenWidth < 400 ? 14.0 : 16.0;
    final subtitleFontSize = screenWidth < 400 ? 10.0 : 11.0;
    final codeFontSize = screenWidth < 400 ? 8.0 : 9.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withOpacity(0.05),
                  colorScheme.primary.withOpacity(0.02),
                ],
              ),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row with emoji and country code
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenWidth < 400 ? 4 : 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        emoji,
                        style: TextStyle(fontSize: emojiSize),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth < 400 ? 4 : 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        countryCode,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: codeFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Flexible spacing
                SizedBox(height: screenWidth < 400 ? 6 : 8),
                
                // Bottom section with city and country names
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cityName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontSize: titleFontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenWidth < 400 ? 1 : 2),
                      Text(
                        countryName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                          fontSize: subtitleFontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const List<Map<String, String>> _popularCities = [
    {'name': 'New York', 'country': 'United States', 'code': 'US', 'emoji': '🗽'},
    {'name': 'London', 'country': 'United Kingdom', 'code': 'UK', 'emoji': '🏰'},
    {'name': 'Tokyo', 'country': 'Japan', 'code': 'JP', 'emoji': '🗾'},
    {'name': 'Paris', 'country': 'France', 'code': 'FR', 'emoji': '🗼'},
    {'name': 'Dubai', 'country': 'UAE', 'code': 'AE', 'emoji': '🏜️'},
    {'name': 'Singapore', 'country': 'Singapore', 'code': 'SG', 'emoji': '🌸'},
    {'name': 'Sydney', 'country': 'Australia', 'code': 'AU', 'emoji': '🏄‍♂️'},
    {'name': 'Mumbai', 'country': 'India', 'code': 'IN', 'emoji': '🏢'},
    {'name': 'Bangkok', 'country': 'Thailand', 'code': 'TH', 'emoji': '🛕'},
    {'name': 'Berlin', 'country': 'Germany', 'code': 'DE', 'emoji': '🏛️'},
    {'name': 'Kathmandu', 'country': 'Nepal', 'code': 'NP', 'emoji': '🏔️'},
    {'name': 'Seoul', 'country': 'South Korea', 'code': 'KR', 'emoji': '🏯'},
  ];

  // Extended list for search functionality
  static const List<Map<String, String>> _allCities = [
    // Popular cities
    {'name': 'New York', 'country': 'United States'},
    {'name': 'London', 'country': 'United Kingdom'},
    {'name': 'Tokyo', 'country': 'Japan'},
    {'name': 'Paris', 'country': 'France'},
    {'name': 'Dubai', 'country': 'UAE'},
    {'name': 'Singapore', 'country': 'Singapore'},
    {'name': 'Sydney', 'country': 'Australia'},
    {'name': 'Mumbai', 'country': 'India'},
    {'name': 'Bangkok', 'country': 'Thailand'},
    {'name': 'Berlin', 'country': 'Germany'},
    {'name': 'Kathmandu', 'country': 'Nepal'},
    {'name': 'Seoul', 'country': 'South Korea'},
    
    // Additional major cities
    {'name': 'Los Angeles', 'country': 'United States'},
    {'name': 'Chicago', 'country': 'United States'},
    {'name': 'San Francisco', 'country': 'United States'},
    {'name': 'Washington', 'country': 'United States'},
    {'name': 'Miami', 'country': 'United States'},
    {'name': 'Las Vegas', 'country': 'United States'},
    {'name': 'Toronto', 'country': 'Canada'},
    {'name': 'Vancouver', 'country': 'Canada'},
    {'name': 'Montreal', 'country': 'Canada'},
    {'name': 'Mexico City', 'country': 'Mexico'},
    {'name': 'São Paulo', 'country': 'Brazil'},
    {'name': 'Rio de Janeiro', 'country': 'Brazil'},
    {'name': 'Buenos Aires', 'country': 'Argentina'},
    {'name': 'Lima', 'country': 'Peru'},
    {'name': 'Barcelona', 'country': 'Spain'},
    {'name': 'Madrid', 'country': 'Spain'},
    {'name': 'Rome', 'country': 'Italy'},
    {'name': 'Milan', 'country': 'Italy'},
    {'name': 'Amsterdam', 'country': 'Netherlands'},
    {'name': 'Vienna', 'country': 'Austria'},
    {'name': 'Zurich', 'country': 'Switzerland'},
    {'name': 'Stockholm', 'country': 'Sweden'},
    {'name': 'Copenhagen', 'country': 'Denmark'},
    {'name': 'Helsinki', 'country': 'Finland'},
    {'name': 'Oslo', 'country': 'Norway'},
    {'name': 'Prague', 'country': 'Czech Republic'},
    {'name': 'Budapest', 'country': 'Hungary'},
    {'name': 'Warsaw', 'country': 'Poland'},
    {'name': 'Moscow', 'country': 'Russia'},
    {'name': 'Istanbul', 'country': 'Turkey'},
    {'name': 'Cairo', 'country': 'Egypt'},
    {'name': 'Cape Town', 'country': 'South Africa'},
    {'name': 'Lagos', 'country': 'Nigeria'},
    {'name': 'Beijing', 'country': 'China'},
    {'name': 'Shanghai', 'country': 'China'},
    {'name': 'Hong Kong', 'country': 'Hong Kong'},
    {'name': 'Taipei', 'country': 'Taiwan'},
    {'name': 'Manila', 'country': 'Philippines'},
    {'name': 'Jakarta', 'country': 'Indonesia'},
    {'name': 'Kuala Lumpur', 'country': 'Malaysia'},
    {'name': 'Ho Chi Minh City', 'country': 'Vietnam'},
    {'name': 'Hanoi', 'country': 'Vietnam'},
    {'name': 'Dhaka', 'country': 'Bangladesh'},
    {'name': 'Colombo', 'country': 'Sri Lanka'},
    {'name': 'Delhi', 'country': 'India'},
    {'name': 'Kolkata', 'country': 'India'},
    {'name': 'Chennai', 'country': 'India'},
    {'name': 'Bangalore', 'country': 'India'},
    {'name': 'Hyderabad', 'country': 'India'},
    {'name': 'Pune', 'country': 'India'},
    {'name': 'Karachi', 'country': 'Pakistan'},
    {'name': 'Lahore', 'country': 'Pakistan'},
    {'name': 'Islamabad', 'country': 'Pakistan'},
    {'name': 'Tel Aviv', 'country': 'Israel'},
    {'name': 'Jerusalem', 'country': 'Israel'},
    {'name': 'Riyadh', 'country': 'Saudi Arabia'},
    {'name': 'Kuwait City', 'country': 'Kuwait'},
    {'name': 'Doha', 'country': 'Qatar'},
    {'name': 'Abu Dhabi', 'country': 'UAE'},
    {'name': 'Tehran', 'country': 'Iran'},
    {'name': 'Melbourne', 'country': 'Australia'},
    {'name': 'Brisbane', 'country': 'Australia'},
    {'name': 'Perth', 'country': 'Australia'},
    {'name': 'Auckland', 'country': 'New Zealand'},
    {'name': 'Wellington', 'country': 'New Zealand'},
    {'name': 'Fiji', 'country': 'Fiji'},
  ];
}