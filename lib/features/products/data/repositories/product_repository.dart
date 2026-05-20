import 'dart:io' as io;
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference get _products => _firestore.collection('products').withConverter<ProductModel>(
        fromFirestore: (snap, _) => ProductModel.fromFirestore(snap),
        toFirestore: (product, _) => product.toFirestore(),
      );

  CollectionReference get _categories => _firestore.collection('categories').withConverter<CategoryModel>(
        fromFirestore: (snap, _) => CategoryModel.fromFirestore(snap),
        toFirestore: (cat, _) => cat.toFirestore(),
      );

  // Products
  Stream<List<ProductModel>> getProducts({String? category, bool? featured, String? searchQuery}) {
    Query query = _products.where('isActive', isEqualTo: true);
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    if (featured == true) {
      query = query.where('isFeatured', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      var products = snapshot.docs.map((doc) => doc.data() as ProductModel).toList();
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        return products.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q)
        ).toList();
      }
      return products;
    });
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      final doc = await _products.doc(id).get();
      return doc.data() as ProductModel?;
    } catch (e) {
      return null;
    }
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    final docRef = await _products.add(product);
    return product.copyWith(id: docRef.id);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _products.doc(id).update(data);
  }

  Future<void> deleteProduct(String id) async {
    await _products.doc(id).update({'isActive': false});
  }

  Future<String> uploadImage(String productId, String filePath) async {
    final ref = _storage.ref().child('products/$productId/${DateTime.now().millisecondsSinceEpoch}');
    await ref.putFile(io.File(filePath));
    return await ref.getDownloadURL();
  }

  Future<String> uploadImageFromBytes(String productId, Uint8List bytes) async {
    final ref = _storage.ref().child('products/$productId/${DateTime.now().millisecondsSinceEpoch}');
    await ref.putData(bytes);
    return await ref.getDownloadURL();
  }

  // Categories
  Stream<List<CategoryModel>> getCategories() {
    return _categories
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) {
          final categories = snap.docs.map((doc) => doc.data() as CategoryModel).toList();
          categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          return categories;
        });
  }

  Future<void> addCategory(CategoryModel category) async {
    await _categories.add(category.toFirestore());
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await _categories.doc(id).update(data);
  }

  Future<void> deleteCategory(String id) async {
    await _categories.doc(id).update({'isActive': false});
  }
}
