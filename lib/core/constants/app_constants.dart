class AppConstants {
  // API URLs
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  
  // Firebase Collection Names
  static const String usersCollection = 'users';
  static const String moviesCollection = 'movies';
  static const String reviewsCollection = 'reviews';
  static const String recommendationsCollection = 'recommendations';
  
  // App Info
  static const String appName = 'Movie Recommendation System';
  static const String appVersion = '1.0.0';
  
  // Error Messages
  static const String networkError = 'Network connection error';
  static const String unknownError = 'An unknown error occurred';
  static const String authError = 'Authentication failed';
}