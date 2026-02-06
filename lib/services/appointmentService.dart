import 'package:dio/dio.dart';
import 'package:fluter/api/api.dart';
import '../models/appointmentModel.dart';

class AppointmentService {
  static const String baseUrl = '${ApiClient.baseUrl}appointments';

  // Get all appointments
  static Future<List<AppointmentModel>> getAllAppointments() async {
    try {
      final response = await ApiClient.instance.get(baseUrl);
      
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = response.data;
        List<dynamic> data = jsonResponse['data'];
        return data.map((appointment) => AppointmentModel.fromJson(appointment)).toList();
      } else {
        throw Exception('Failed to load appointments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching appointments: $e');
    }
  }

  // Get appointment by ID
  static Future<AppointmentModel> getAppointmentById(String id) async {
    try {
      final response = await ApiClient.instance.get('$baseUrl/$id');
      
      if (response.statusCode == 200) {
        return AppointmentModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load appointment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching appointment: $e');
    }
  }

  // Get appointments by patient ID (filtered from all appointments)
  static Future<List<AppointmentModel>> getAppointmentsByPatient(String patientId) async {
    try {
      final allAppointments = await getAllAppointments();
      return allAppointments.where((appointment) => appointment.pNo == patientId).toList();
    } catch (e) {
      throw Exception('Error fetching patient appointments: $e');
    }
  }

  // Get appointments by doctor ID (filtered from all appointments)
  static Future<List<AppointmentModel>> getAppointmentsByDoctor(String doctorId) async {
    try {
      final allAppointments = await getAllAppointments();
      return allAppointments.where((appointment) => appointment.docNo == doctorId).toList();
    } catch (e) {
      throw Exception('Error fetching doctor appointments: $e');
    }
  }

  // Get today's appointments (filtered from all appointments)
  static Future<List<AppointmentModel>> getTodayAppointments() async {
    try {
      final allAppointments = await getAllAppointments();
      final today = DateTime.now();
      final todayAppointments = allAppointments.where((appointment) {
        return appointment.date.year == today.year &&
               appointment.date.month == today.month &&
               appointment.date.day == today.day;
      }).toList();
      return todayAppointments;
    } catch (e) {
      throw Exception('Error fetching today\'s appointments: $e');
    }
  }

  // Create new appointment
  static Future<AppointmentModel> createAppointment(AppointmentModel appointment) async {
    try {
      final response = await ApiClient.instance.post(
        baseUrl,
        data: appointment.toJson(),
      );
      
      if (response.statusCode == 201) {
        return AppointmentModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create appointment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString())
          : null;

      if (statusCode == 409 && message != null && message.isNotEmpty) {
        throw Exception(message);
      }

      if (message != null && message.isNotEmpty) {
        throw Exception(message);
      }

      throw Exception('Failed to create appointment. Please try again.');
    } catch (e) {
      throw Exception('Failed to create appointment. Please try again.');
    }
  }

  // Update appointment
  static Future<AppointmentModel> updateAppointment(String id, AppointmentModel appointment) async {
    try {
      final response = await ApiClient.instance.put(
        '$baseUrl/$id',
        data: appointment.toJson(),
      );
      
      if (response.statusCode == 200) {
        return AppointmentModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update appointment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating appointment: $e');
    }
  }

  // Update appointment status (using full update since status endpoint doesn't exist)
  static Future<AppointmentModel> updateAppointmentStatus(String id, String status) async {
    try {
      // First get the current appointment
      final currentAppointment = await getAppointmentById(id);
      
      // Update with new status
      final updatedAppointment = currentAppointment.copyWith(status: status);
      
      final response = await ApiClient.instance.put(
        '$baseUrl/$id',
        data: updatedAppointment.toJson(),
      );
      
      if (response.statusCode == 200) {
        return AppointmentModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update appointment status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating appointment status: $e');
    }
  }

  // Delete appointment
  static Future<bool> deleteAppointment(String id) async {
    try {
      final response = await ApiClient.instance.delete('$baseUrl/$id');
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete appointment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting appointment: $e');
    }
  }

  // Get appointments by date range (filtered from all appointments)
  static Future<List<AppointmentModel>> getAppointmentsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final allAppointments = await getAllAppointments();
      return allAppointments.where((appointment) {
        return appointment.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
               appointment.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      throw Exception('Error fetching appointments by date range: $e');
    }
  }
}