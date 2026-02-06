class DoctorSchedule {
  // Static list of days for dropdown selection
  static const List<String> days = [
    'Monday',
    'Tuesday', 
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final String? id;
  final String docNo; // Foreign key reference to Doctor
  final String day;
  final String startTime;
  final String endTime;
  final int? maxAppointments;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DoctorSchedule({
    this.id,
    required this.docNo,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.maxAppointments,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create DoctorSchedule from JSON
  factory DoctorSchedule.fromJson(Map<String, dynamic> json) {
    print('DoctorSchedule.fromJson called with: $json');
    
    // Handle doc_no which can be either a string or an object
    String docNoValue;
    if (json['doc_no'] is Map) {
      docNoValue = json['doc_no']['_id']?.toString() ?? '';
      print('doc_no is Map, extracted _id: $docNoValue');
    } else {
      docNoValue = json['doc_no']?.toString() ?? '';
      print('doc_no is String: $docNoValue');
    }
    
    final schedule = DoctorSchedule(
      id: json['_id']?.toString(),
      docNo: docNoValue,
      day: json['Day'] ?? json['day'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      maxAppointments: json['maxAppointments'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
    
    print('Created DoctorSchedule: ${schedule.toString()}');
    return schedule;
  }

  // Method to convert DoctorSchedule to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'doc_no': docNo,
      'Day': day,
      'startTime': startTime,
      'endTime': endTime,
      if (maxAppointments != null) 'maxAppointments': maxAppointments,
    };
  }

  // Create a copy with updated fields
  DoctorSchedule copyWith({
    String? id,
    String? docNo,
    String? day,
    String? startTime,
    String? endTime,
    int? maxAppointments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorSchedule(
      id: id ?? this.id,
      docNo: docNo ?? this.docNo,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxAppointments: maxAppointments ?? this.maxAppointments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DoctorSchedule(id: $id, docNo: $docNo, day: $day, startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoctorSchedule &&
        other.id == id &&
        other.docNo == docNo &&
        other.day == day &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.maxAppointments == maxAppointments;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        docNo.hashCode ^
        day.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        maxAppointments.hashCode;
  }
}
