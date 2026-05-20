import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pharmacy_model.dart';

class PharmacyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Use untyped CollectionReference and handle conversion manually
  CollectionReference get _pharmacies => _firestore.collection('pharmacies');

  Stream<List<PharmacyModel>> getPharmacies() {
    return _pharmacies
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => PharmacyModel.fromFirestore(doc)).toList());
  }

  Future<void> seedGjilanPharmacies() async {
    for (final pharmacy in gjilanPharmacies) {
      final query = await _pharmacies.where('name', isEqualTo: pharmacy['name']).limit(1).get();
      if (query.docs.isEmpty) {
        await _pharmacies.add({...pharmacy, 'isActive': true});
      }
    }
  }
}
