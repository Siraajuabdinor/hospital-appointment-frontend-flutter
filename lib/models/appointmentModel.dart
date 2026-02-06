class AppointmentModel {
  final String? id;
  final String pNo;
  final String docNo;
  final DateTime date;
  final String status;
  final double fee;
  final int? serialNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? patientName;
  final String? doctorName;

  AppointmentModel({
    this.id,
    required this.pNo,
    required this.docNo,
    required this.date,
    this.status = 'pending',
    required this.fee,
    this.serialNumber,
    this.createdAt,
    this.updatedAt,
    this.patientName,
    this.doctorName,
  });

  // Factory constructor to create instance from JSON
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    String pNo = '';
    String? patientName;
    
    if (json['p_no'] is Map) {
      pNo = json['p_no']['_id']?.toString() ?? '';
      patientName = json['p_no']['fullName']?.toString();
    } else {
      pNo = json['p_no']?.toString() ?? '';
    }

    String docNo = '';
    String? doctorName;

    if (json['doc_no'] is Map) {
      docNo = json['doc_no']['_id']?.toString() ?? '';
      doctorName = json['doc_no']['fullName']?.toString();
    } else {
      docNo = json['doc_no']?.toString() ?? '';
    }

    return AppointmentModel(
      id: json['_id']?.toString(),
      pNo: pNo,
      docNo: docNo,
      date: DateTime.parse(json['date']),
      status: json['status']?.toString() ?? 'pending',
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      serialNumber: (json['serialNumber'] as num?)?.toInt(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      patientName: patientName,
      doctorName: doctorName,
    );
  }

  // Method to convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'p_no': pNo,
      'doc_no': docNo,
      'date': date.toIso8601String(),
      'status': status,
      'fee': fee,
      if (serialNumber != null) 'serialNumber': serialNumber,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Copy with method for immutability
  AppointmentModel copyWith({
    String? id,
    String? pNo,
    String? docNo,
    DateTime? date,
    String? status,
    double? fee,
    int? serialNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      pNo: pNo ?? this.pNo,
      docNo: docNo ?? this.docNo,
      date: date ?? this.date,
      status: status ?? this.status,
      fee: fee ?? this.fee,
      serialNumber: serialNumber ?? this.serialNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getters for status enum values
  static List<String> get statusValues => [
    'pending',
    'confirmed', 
    'completed',
    'cancelled',
    'walk-in'
  ];

  @override
  String toString() {
    return 'AppointmentModel(id: $id, pNo: $pNo, docNo: $docNo, date: $date, status: $status, fee: $fee, serialNumber: $serialNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppointmentModel &&
        other.id == id &&
        other.pNo == pNo &&
        other.docNo == docNo &&
        other.date == date &&
        other.status == status &&
        other.fee == fee &&
        other.serialNumber == serialNumber;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        pNo.hashCode ^
        docNo.hashCode ^
        date.hashCode ^
        status.hashCode ^
        fee.hashCode ^
        serialNumber.hashCode;
  }
}