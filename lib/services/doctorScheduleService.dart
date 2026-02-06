import '../models/doctorScheduleModel.dart';
import '../api/api.dart';

class DoctorScheduleService {
  static Future<List<DoctorSchedule>> getAllDoctorSchedules() async {
    try {
      final response = await ApiClient.instance.get(
        'doctorSchedules',
      );

      print('Schedule API Response Status: ${response.statusCode}');
      print('Schedule API Response Body: ${response.data}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = response.data;
        print('Parsed JSON: $responseData');
        
        if (responseData['success'] == true) {
          List<dynamic> jsonData = responseData['data'];
          print('Data array length: ${jsonData.length}');
          
          List<DoctorSchedule> schedules = jsonData.map((json) {
            print('Processing schedule JSON: $json');
            DoctorSchedule schedule = DoctorSchedule.fromJson(json);
            print('Parsed schedule: ${schedule.toString()}');
            return schedule;
          }).toList();
          
          print('Final schedules list length: ${schedules.length}');
          return schedules;
        } else {
          throw Exception('Backend error: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load doctor schedules: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllDoctorSchedules: $e');
      throw Exception('Error fetching doctor schedules: $e');
    }
  }

  static Future<List<DoctorSchedule>> getDoctorSchedules(String doctorId) async {
    try {
      final response = await ApiClient.instance.get(
        'doctorSchedules/doctor/$doctorId',
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = response.data;
        if (responseData['success'] == true) {
          List<dynamic> jsonData = responseData['data'];
          return jsonData.map((json) => DoctorSchedule.fromJson(json)).toList();
        } else {
          throw Exception('Backend error: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load doctor schedules: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching doctor schedules: $e');
    }
  }

  static Future<DoctorSchedule?> createDoctorSchedule(DoctorSchedule schedule) async {
    try {
      final response = await ApiClient.instance.post(
        'doctorSchedules',
        data: schedule.toJson(),
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> responseData = response.data;
        if (responseData['success'] == true) {
          return DoctorSchedule.fromJson(responseData['data']);
        } else {
          throw Exception('Backend error: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to create doctor schedule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating doctor schedule: $e');
    }
  }

  static Future<DoctorSchedule?> updateDoctorSchedule(String id, DoctorSchedule schedule) async {
    try {
      final response = await ApiClient.instance.put(
        'doctorSchedules/$id',
        data: schedule.toJson(),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = response.data;
        if (responseData['success'] == true) {
          return DoctorSchedule.fromJson(responseData['data']);
        } else {
          throw Exception('Backend error: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to update doctor schedule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating doctor schedule: $e');
    }
  }

  static Future<bool> deleteDoctorSchedule(String id) async {
    try {
      final response = await ApiClient.instance.delete(
        'doctorSchedules/$id',
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting doctor schedule: $e');
    }
  }
}
