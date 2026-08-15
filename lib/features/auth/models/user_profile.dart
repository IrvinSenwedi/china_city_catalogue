class UserProfile {
  final String id;
  final String fullName;
  final String role;
  final String? phoneNumber;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.role,
    this.phoneNumber,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['full_name'] ?? 'User',
      role: json['role'] ?? 'CUSTOMER',
      phoneNumber: json['phone_number'],
    );
  }

  bool get isRetailer => role == 'RETAILER';

  bool get isCustomer => role == 'CUSTOMER';
}
