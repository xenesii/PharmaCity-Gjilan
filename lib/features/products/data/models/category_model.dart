import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? imageUrl;
  final String? iconName;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.iconName,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
      iconName: data['iconName'],
      sortOrder: (data['sortOrder'] ?? 0).toInt(),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'imageUrl': imageUrl,
    'iconName': iconName,
    'sortOrder': sortOrder,
    'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
