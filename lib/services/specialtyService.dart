import 'package:fluter/api/api.dart';
import '../models/specialtyModel.dart';

class SpecialtyService {
  // Get all specialties
  static Future<List<Specialty>> getAllSpecialties() async {
    try {
      final response = await ApiClient.instance.get(
        'specialties',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> jsonData = responseData['data'];
        return jsonData.map((json) => Specialty.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load specialties: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching specialties: $e');
    }
  }

  // Get specialty by ID
  static Future<Specialty> getSpecialtyById(String id) async {
    try {
      final response = await ApiClient.instance.get(
        'specialties/$id',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        return Specialty.fromJson(jsonData);
      } else {
        throw Exception('Failed to load specialty: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching specialty: $e');
    }
  }

  // Create new specialty
  static Future<Specialty> createSpecialty(Specialty specialty) async {
    try {
      final response = await ApiClient.instance.post(
        'specialties',
        data: specialty.toJson(),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = response.data;
        return Specialty.fromJson(jsonData);
      } else {
        final errorData = response.data;
        throw Exception('Failed to create specialty: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating specialty: $e');
    }
  }

  // Update specialty
  static Future<Specialty> updateSpecialty(String id, Specialty specialty) async {
    try {
      final response = await ApiClient.instance.put(
        'specialties/$id',
        data: specialty.toJson(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        return Specialty.fromJson(jsonData);
      } else {
        final errorData = response.data;
        throw Exception('Failed to update specialty: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating specialty: $e');
    }
  }

  // Delete specialty
  static Future<bool> deleteSpecialty(String id) async {
    try {
      final response = await ApiClient.instance.delete(
        'specialties/$id',
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = response.data;
        throw Exception('Failed to delete specialty: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting specialty: $e');
    }
  }
}
