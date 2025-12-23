class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String? middleName;
  final String lastName;
  final bool isAdmin;
  final String? profilePictureUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.isAdmin = false,
    this.profilePictureUrl,
    this.createdAt,
    this.updatedAt,
  });

  // Get full name
  String get fullName => middleName != null && middleName!.isNotEmpty
      ? '$firstName $middleName $lastName'
      : '$firstName $lastName';

  // Get display name (first name only)
  String get displayName => firstName;

  // Create from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      firstName: data['first_name'] ?? '',
      middleName: data['middle_name'] != null && data['middle_name'].toString().isNotEmpty 
          ? data['middle_name'] 
          : null,
      lastName: data['last_name'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
      profilePictureUrl: data['profile_picture_url'],
      createdAt: data['created_at']?.toDate(),
      updatedAt: data['updated_at']?.toDate(),
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'first_name': firstName,
      'middle_name': middleName ?? '',
      'last_name': lastName,
      'isAdmin': isAdmin,
      'profile_picture_url': profilePictureUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    String? profilePictureUrl,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      isAdmin: isAdmin,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserModel &&
      other.uid == uid &&
      other.email == email &&
      other.firstName == firstName &&
      other.middleName == middleName &&
      other.lastName == lastName &&
      other.isAdmin == isAdmin &&
      other.profilePictureUrl == profilePictureUrl;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
      email.hashCode ^
      firstName.hashCode ^
      (middleName?.hashCode ?? 0) ^
      lastName.hashCode ^
      isAdmin.hashCode ^
      profilePictureUrl.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, firstName: $firstName, middleName: $middleName, lastName: $lastName, isAdmin: $isAdmin, profilePictureUrl: $profilePictureUrl)';
  }
}
