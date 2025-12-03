/// Application-wide constants
class AppConstants {
  AppConstants._();

  // Scroll delays
  static const scrollDelayShort = Duration(milliseconds: 100);
  static const scrollDelayMedium = Duration(milliseconds: 200);
  static const scrollDelayLong = Duration(milliseconds: 300);

  // UI dimensions
  static const double inputBottomMargin = 80.0;
  static const double avatarSize = 30.0;
  static const double borderRadius = 16.0;
  static const double imageHeight = 220.0;

  // Animation durations
  static const animationDuration = Duration(milliseconds: 300);

  // API timeouts
  static const apiTimeout = Duration(seconds: 30);
  static const apiRetryCount = 3;

  // Storage keys
  static const String chatHistoryKey = 'chat_history';
  static const String themeModeKey = 'theme_mode';
  static const String apiKeyKey = 'api_key';

  // Default values
  static const String defaultModel = 'gpt-4o-mini-2024-07-18';
  static const String defaultPlaceholder = 'thinking...';
  static const String imagePlaceholder = 'rendering image...';
}

