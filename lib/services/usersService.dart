import 'package:dio/dio.dart';
import 'package:fluter/api/api.dart';
import '../models/userModel.dart';

class UsersService {
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await ApiClient.instance.get('users');
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> jsonData = data is Map<String, dynamic> ? (data['data'] ?? []) : data;
        return jsonData.map((json) => UserModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load users: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  static Future<UserModel> createUser({
    required String fullName,
    required String email,
    required String role,
    String? password,
  }) async {
    try {
      final payload = <String, dynamic>{
        'fullName': fullName,
        'email': email,
        'role': role,
        if (password != null && password.isNotEmpty) 'password': password,
      };
      final response = await ApiClient.instance.post('users', data: payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = response.data;
        return UserModel.fromJson(jsonData['data'] ?? jsonData);
      }
      throw Exception('Failed to create user: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Error creating user: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  static Future<UserModel> updateUser({
    required String id,
    required String fullName,
    required String email,
    required String role,
  }) async {
    try {
      final payload = <String, dynamic>{
        'fullName': fullName,
        'email': email,
        'role': role,
      };
      final response = await ApiClient.instance.put('users/$id', data: payload);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        return UserModel.fromJson(jsonData['data'] ?? jsonData);
      }
      throw Exception('Failed to update user: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Error updating user: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  static Future<bool> deleteUser(String id) async {
    try {
      final response = await ApiClient.instance.delete('users/$id');
      if (response.statusCode == 200) {
        return true;
      }
      throw Exception('Failed to delete user: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Error deleting user: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }
}
