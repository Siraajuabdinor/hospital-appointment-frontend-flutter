import 'package:fluter/api/api.dart';
import 'package:dio/dio.dart';
import '../models/doctorModel.dart';

class DoctorService {
  // Get all doctors
  static Future<List<Doctor>> getAllDoctors() async {
    try {
      final response = await ApiClient.instance.get(
        'doctors',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> jsonData = responseData['data'] ?? [];
        return jsonData.map((json) => Doctor.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load doctors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching doctors: $e');
    }
  }

  // Get doctor by ID
  static Future<Doctor> getDoctorById(String id) async {
    try {
      final response = await ApiClient.instance.get(
        'doctors/$id',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        return Doctor.fromJson(jsonData);
      } else {
        throw Exception('Failed to load doctor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching doctor: $e');
    }
  }

  // Get doctors by specialty
  static Future<List<Doctor>> getDoctorsBySpecialty(String specialtyId) async {
    try {
      final response = await ApiClient.instance.get(
        'doctors/specialty/$specialtyId',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> jsonData = responseData['data'] ?? [];
        return jsonData.map((json) => Doctor.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load doctors by specialty: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching doctors by specialty: $e');
    }
  }

  // Get active doctors only
  static Future<List<Doctor>> getActiveDoctors() async {
    try {
      final response = await ApiClient.instance.get(
        'doctors',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> jsonData = responseData['data'] ?? [];
        // Filter for active doctors on client side
        return jsonData
            .map((json) => Doctor.fromJson(json))
            .where((doctor) => doctor.status == 'active')
            .toList();
      } else {
        throw Exception('Failed to load doctors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching active doctors: $e');
    }
  }

  // Create new doctor
  static Future<Doctor> createDoctor(Doctor doctor) async {
    try {
      final response = await ApiClient.instance.post(
        'doctors',
        data: doctor.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = response.data;
        return Doctor.fromJson(jsonData['data'] ?? jsonData);
      } else {
        final errorData = response.data;
        throw Exception('Failed to create doctor: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating doctor: $e');
    }
  }

  // Update doctor
  static Future<Doctor> updateDoctor(String id, Doctor doctor) async {
    try {
      final response = await ApiClient.instance.put(
        'doctors/$id',
        data: doctor.toJson(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        return Doctor.fromJson(jsonData);
      } else {
        final errorData = response.data;
        throw Exception('Failed to update doctor: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating doctor: $e');
    }
  }

  // Delete doctor
  static Future<bool> deleteDoctor(String id) async {
    try {
      final response = await ApiClient.instance.delete(
        'doctors/$id',
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = response.data;
        throw Exception('Failed to delete doctor: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting doctor: $e');
    }
  }

  // Update doctor status (activate/deactivate)
  static Future<Doctor> updateDoctorStatus(String id, String status) async {
    try {
      final response = await ApiClient.instance.patch(
        'doctors/$id/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        return Doctor.fromJson(jsonData);
      } else {
        final errorData = response.data;
        throw Exception('Failed to update doctor status: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating doctor status: $e');
    }
  }

  // Search doctors by name or email
  static Future<List<Doctor>> searchDoctors(String query) async {
    try {
      final response = await ApiClient.instance.get(
        'doctors/search?q=$query',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> jsonData = responseData['data'] ?? [];
        return jsonData.map((json) => Doctor.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search doctors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching doctors: $e');
    }
  }

  // Upload doctor image
  static Future<String> uploadDoctorImage(String doctorId, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await ApiClient.instance.post(
        'doctors/$doctorId/image',
        data: formData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        String imageUrl = jsonData['imageUrl'];
        
        // Convert relative URL to absolute URL if needed
        if (imageUrl.startsWith('/uploads/')) {
          imageUrl = '${ApiClient.baseUrl.replaceFirst('/api/', '')}$imageUrl';
        }
        
        return imageUrl;
      } else {
        final errorData = response.data;
        throw Exception('Failed to upload image: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}
