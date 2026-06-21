class UserModel {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String? lastName;
  final String? mobile;
  final String? designation;
  final String? department;
  final String? branchId;
  final bool isActive;
  final String? lastLoginAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    this.lastName,
    this.mobile,
    this.designation,
    this.department,
    this.branchId,
    this.isActive = true,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'],
      mobile: json['mobile'],
      designation: json['designation'],
      department: json['department'],
      branchId: json['branch_id'],
      isActive: json['is_active'] ?? true,
      lastLoginAt: json['last_login_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'mobile': mobile,
      'designation': designation,
      'department': department,
      'branch_id': branchId,
      'is_active': isActive,
      'last_login_at': lastLoginAt,
    };
  }
}
