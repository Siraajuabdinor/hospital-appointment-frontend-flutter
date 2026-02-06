class Specialty {
  final String? id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Specialty({
    this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create Specialty from JSON
  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      id: json['_id']?.toString(),
      name: json['name'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  // Method to convert Specialty to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
    };
  }

  // Create a copy with updated fields
  Specialty copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Specialty(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Specialty(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Specialty &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode;
  }
}
