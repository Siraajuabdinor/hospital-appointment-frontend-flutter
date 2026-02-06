import 'package:dio/dio.dart';
import 'package:fluter/api/api.dart';
import '../models/doctorModel.dart';

class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final String? role;
  final Doctor? doctor;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.role,
    this.doctor,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Handle different response formats
    Doctor? doctorData;
    if (json['doctor'] != null) {
      doctorData = Doctor.fromJson(json['doctor']);
    } else if (json['data'] != null && json['data']['doctor'] != null) {
      doctorData = Doctor.fromJson(json['data']['doctor']);
    }

    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      role: json['role'],
      doctor: doctorData,
    );
  }
}

class AuthService {
  static const String _loginEndpoint = 'users/login';

  // Login method
  static Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await ApiClient.instance.post(
        _loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      } else {
        return LoginResponse(
          success: false,
          message: 'Login failed: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error';
      
      if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server response timeout. Please try again.';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }

      return LoginResponse(
        success: false,
        message: errorMessage,
      );
    } catch (e) {
      return LoginResponse(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  // Mock login for testing (when backend is not available)
  static Future<LoginResponse> mockLogin(String email, String password) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));

    // Mock user credentials
    if (email == 'admin@hospital.com' && password == 'admin123') {
      return LoginResponse(
        success: true,
        message: 'Login successful',
        token: 'mock_admin_token',
        role: 'admin',
      );
    } else if (email == 'doctor@hospital.com' && password == 'doctor123') {
      return LoginResponse(
        success: true,
        message: 'Login successful',
        token: 'mock_doctor_token',
        role: 'doctor',
        doctor: Doctor(
          id: '1',
          fullName: 'Dr. Ahmed Mohamed',
          tell: '+252612345678',
          email: 'doctor@hospital.com',
          sex: 'male',
          qualification: 'MBBS, MD',
          experienceYears: 10,
          bio: 'Experienced general practitioner',
          status: 'active',
          sp_no: 'SP001',
        ),
      );
    } else {
      return LoginResponse(
        success: false,
        message: 'Invalid email or password',
      );
    }
  }
}
