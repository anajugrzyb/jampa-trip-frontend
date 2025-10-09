class UserModel {
  final int id;
  final String name;
  final String email;
  final String type; // 'client' ou 'company'
  final String? companyName;
  final String? cnpj;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    this.companyName,
    this.cnpj,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['company_name'] ?? '',
      email: json['email'] ?? '',
      type: json['type'] ?? 'client',
      companyName: json['company_name'],
      cnpj: json['cnpj'],
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type,
      if (companyName != null) 'company_name': companyName,
      if (cnpj != null) 'cnpj': cnpj,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  bool get isCompany => type == 'company';
  bool get isClient => type == 'client';

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, type: $type)';
  }
}
