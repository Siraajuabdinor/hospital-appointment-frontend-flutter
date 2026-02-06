import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ApiClient {
  static Dio? _apiDio;
  static Dio? _imageDio;
  static const String authTokenKey = 'authToken';

  // Base URL for API endpoints
  static const String baseUrl = 'https://hospital-appointment-backend-2.onrender.com/api/';
  //static const String baseUrl = 'http://10.209.162.233:5000/api/';
  
  // For API integrations
  static Dio get instance {
    _apiDio ??= Dio(
      BaseOptions(
        // baseUrl: 'http://192.168.100.7/ebadal/mobile/',
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add token to every request (if available in SharedPreferences).
    _apiDio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(authTokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    return _apiDio!;
  }

  // For image fetching (e.g. profile pictures, channel icons)
  static Dio get imageInstance {
    _imageDio ??= Dio(
      BaseOptions(
        // Keep image host aligned with the API host to avoid 404s when running
        // against local/staging backends.
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'image/*',
        },
      ),
    );
    return _imageDio!;
  }

  // Get base URL for images (from imageInstance)
  static String get imageBaseUrl {
    return imageInstance.options.baseUrl;
  }

  // Resolve relative image paths returned by backend to absolute URLs.
  static String resolveImageUrl(String? imagePath) {
    final trimmed = imagePath?.trim() ?? '';
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http')) return trimmed;

    final apiHost = ApiClient.baseUrl.replaceFirst('/api/', '');
    if (trimmed.startsWith('/')) {
      return '$apiHost$trimmed';
    }
    return '$apiHost/$trimmed';
  }
}