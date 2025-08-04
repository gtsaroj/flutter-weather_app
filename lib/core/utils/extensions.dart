import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
  
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}

extension DateTimeExtensions on DateTime {
  String toTimeString() {
    return DateFormat('HH:mm').format(this);
  }
  
  String toDateString() {
    return DateFormat('MMM dd, yyyy').format(this);
  }
  
  String toDayString() {
    return DateFormat('EEEE').format(this);
  }
  
  String toShortDayString() {
    return DateFormat('EEE').format(this);
  }
  
  String toMonthDayString() {
    return DateFormat('MMM dd').format(this);
  }
  
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
  
  bool isToday() {
    final now = DateTime.now();
    return isSameDay(now);
  }
  
  bool isTomorrow() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(tomorrow);
  }
}

extension DoubleExtensions on double {
  String toTemperatureString() {
    return '${round()}°';
  }
  
  String toSpeedString() {
    return '${toStringAsFixed(1)} m/s';
  }
  
  String toPercentageString() {
    return '${round()}%';
  }
}

extension IntExtensions on int {
  String toPercentageString() {
    return '$this%';
  }
  
  String toPressureString() {
    return '$this hPa';
  }
  
  String toVisibilityString() {
    return '${(this / 1000).toStringAsFixed(1)} km';
  }
}

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  
  Size get screenSize => MediaQuery.of(this).size;
  
  double get screenWidth => MediaQuery.of(this).size.width;
  
  double get screenHeight => MediaQuery.of(this).size.height;
  
  bool get isSmallScreen => screenWidth < 600;
  
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1200;
  
  bool get isLargeScreen => screenWidth >= 1200;
  
  EdgeInsets get padding => MediaQuery.of(this).padding;
  
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  
  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}