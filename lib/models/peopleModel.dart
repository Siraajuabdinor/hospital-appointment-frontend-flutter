class PeopleModel {
  final String? id;
  final String fullName;
  final String username;
  final String email;
  final String tell;
  final String sex;
  final String address;

  PeopleModel({
    this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.tell,
    required this.sex,
    required this.address,
  });

  factory PeopleModel.fromJson(Map<String, dynamic> json) {
    return PeopleModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      tell: json['tell'] ?? '',
      sex: json['sex'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'tell': tell,
      'sex': sex,
      'address': address,
    };
  }
}
