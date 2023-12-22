class UserProfile {
  final String id; // Auto-incremented primary key
  final String fullName;
  final String email;
  final String phoneNumber;
  final String userType;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.userType
  });

  // Convert UserProfile to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'userType':userType,
    };
  }

  // Create UserProfile from Map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] as String,
      userType: map['userType'] as String,
    );
  }
}
