class UserProfile {
  final String id;
  final String fullName;
  final String role;

  UserProfile({required this.id, required this.fullName, required this.role});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['full_name'] ?? 'User',
      role: json['role'] ?? 'CUSTOMER',
    );
  }

  bool get isRetailer => role == 'RETAILER';
  bool get isCustomer => role == 'CUSTOMER';
}
