class Doctor {
  final String? id;
  final String fullName;
  final String tell;
  final String email;
  final String sex;
  final String? qualification;
  final String? specialtyName;
  final int experienceYears;
  final String? bio;
  final String? image;
  final String status;
  final String sp_no; // Foreign key reference to Specialty (matches backend sp_no)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Doctor({
    this.id,
    required this.fullName,
    required this.tell,
    required this.email,
    required this.sex,
    this.qualification,
    this.specialtyName,
    this.experienceYears = 0,
    this.bio,
    this.image,
    this.status = 'active',
    required this.sp_no,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create Doctor from JSON
  factory Doctor.fromJson(Map<String, dynamic> json) {
    String spNoValue = '';
    String? specialtyName;

    if (json['sp_no'] is Map) {
      spNoValue = json['sp_no']['_id']?.toString() ?? '';
      specialtyName = json['sp_no']['name']?.toString();
    } else {
      spNoValue = json['sp_no']?.toString() ?? '';
    }

    return Doctor(
      id: json['_id']?.toString(),
      fullName: json['fullName'] ?? '',
      tell: json['tell'] ?? '',
      email: json['email'] ?? '',
      sex: json['sex'] ?? '',
      qualification: json['qualification'],
      specialtyName: specialtyName,
      experienceYears: json['experienceYears'] ?? 0,
      bio: json['bio'],
      image: json['image'],
      status: json['status'] ?? 'active',
      sp_no: spNoValue,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  // Method to convert Doctor to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'fullName': fullName,
      'tell': tell,
      'email': email,
      'sex': sex,
      if (qualification != null) 'qualification': qualification,
      'experienceYears': experienceYears,
      if (bio != null) 'bio': bio,
      if (image != null) 'image': image,
      'status': status,
      'sp_no': sp_no,
    };
  }

  // Create a copy with updated fields
  Doctor copyWith({
    String? id,
    String? fullName,
    String? tell,
    String? email,
    String? sex,
    String? qualification,
    String? specialtyName,
    int? experienceYears,
    String? bio,
    String? image,
    String? status,
    String? sp_no,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      tell: tell ?? this.tell,
      email: email ?? this.email,
      sex: sex ?? this.sex,
      qualification: qualification ?? this.qualification,
      specialtyName: specialtyName ?? this.specialtyName,
      experienceYears: experienceYears ?? this.experienceYears,
      bio: bio ?? this.bio,
      image: image ?? this.image,
      status: status ?? this.status,
      sp_no: sp_no ?? this.sp_no,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Doctor(id: $id, fullName: $fullName, email: $email, sex: $sex, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Doctor &&
        other.id == id &&
        other.fullName == fullName &&
        other.tell == tell &&
        other.email == email &&
        other.sex == sex &&
        other.qualification == qualification &&
        other.specialtyName == specialtyName &&
        other.experienceYears == experienceYears &&
        other.bio == bio &&
        other.image == image &&
        other.status == status &&
        other.sp_no == sp_no;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        fullName.hashCode ^
        tell.hashCode ^
        email.hashCode ^
        sex.hashCode ^
        qualification.hashCode ^
        specialtyName.hashCode ^
        experienceYears.hashCode ^
        bio.hashCode ^
        image.hashCode ^
        status.hashCode ^
        sp_no.hashCode;
  }
}

// Enum for sex values (matching backend enum)
enum DoctorSex {
  male('male'),
  female('female');

  const DoctorSex(this.value);
  final String value;

  static DoctorSex fromString(String value) {
    return DoctorSex.values.firstWhere(
      (sex) => sex.value == value,
      orElse: () => DoctorSex.male,
    );
  }
}

// Enum for status values (matching backend enum)
enum DoctorStatus {
  active('active'),
  inactive('inactive');

  const DoctorStatus(this.value);
  final String value;

  static DoctorStatus fromString(String value) {
    return DoctorStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DoctorStatus.active,
    );
  }
}