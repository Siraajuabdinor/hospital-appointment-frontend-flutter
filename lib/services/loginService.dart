import 'package:dio/dio.dart';
import 'package:fluter/api/api.dart';

import '../models/userModel.dart';

class LoginService {
  static const String _loginEndpoint = 'users/login';

  // Login method
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await ApiClient.instance.post(
        _loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final userData = response.data['data'];
        final token = response.data['token'];
        final user = UserModel.fromJson(userData);

        return {'success': true, 'user': user, 'token': token};
      } else {
        return {'success': false, 'message': response.data['message'] ?? 'Login failed'};
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error';

      if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your network.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server response timeout. Please try again.';
      } else if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }
}
