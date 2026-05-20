import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String phone;
  final String address;
  final String role; // "user" | "admin"
  final String? photoUrl;
  final DateTime createdAt;
  final String? fcmToken;

  const UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.role,
    this.photoUrl,
    required this.createdAt,
    this.fcmToken,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      role: data['role'] ?? 'user',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fcmToken: data['fcmToken'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'email': email,
    'fullName': fullName,
    'phone': phone,
    'address': address,
    'role': role,
    if (photoUrl != null) 'photoUrl': photoUrl,
    'createdAt': Timestamp.fromDate(createdAt),
    if (fcmToken != null) 'fcmToken': fcmToken,
  };

  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phone,
    String? address,
    String? role,
    String? photoUrl,
    DateTime? createdAt,
    String? fcmToken,
  }) =>
      UserModel(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        fullName: fullName ?? this.fullName,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        role: role ?? this.role,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt ?? this.createdAt,
        fcmToken: fcmToken ?? this.fcmToken,
      );
}