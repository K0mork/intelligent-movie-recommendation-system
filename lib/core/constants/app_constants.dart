/// アプリケーション全体で使用される定数を管理するクラス
class AppConstants {
  // API URLs
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String omdbBaseUrl = 'https://www.omdbapi.com';

  // Firebase Collection Names
  static const String usersCollection = 'users';
  static const String moviesCollection = 'movies';
  static const String reviewsCollection = 'reviews';
  static const String recommendationsCollection = 'recommendations';

  // App Info
  static const String appName = 'FilmFlow';
  static const String appVersion = '1.0.0';

  // Error Messages
  static const String networkError = 'Network connection error';
  static const String unknownError = 'An unknown error occurred';
  static const String authError = 'Authentication failed';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double webPadding = 24.0;
  static const double cardElevation = 4.0;
  static const double borderRadius = 8.0;

  // Network Settings
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Localization
  static const String defaultLanguage = 'ja-JP';
  static const String defaultRegion = 'asia-northeast1';

  // Pagination
  static const int defaultPageSize = 20;
  static const double loadMoreTriggerDistance = 200.0;
}
