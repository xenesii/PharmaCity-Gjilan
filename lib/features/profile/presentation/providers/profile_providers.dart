import 'dart:io' as io;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../auth/data/auth_repository.dart';

final profileRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final profileUpdateLoadingProvider = StateProvider<bool>((ref) => false);
final profileUpdateErrorProvider = StateProvider<String?>((ref) => null);
final profileUpdateSuccessProvider = StateProvider<bool>((ref) => false);

final avatarUploadingProvider = StateProvider<bool>((ref) => false);

final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

class ProfileUpdater {
  final AuthRepository _repository;

  ProfileUpdater(this._repository);

  Future<String?> updateProfile(String uid, {
    required String fullName,
    required String phone,
    required String address,
  }) async {
    try {
      await _repository.updateProfile(uid, {
        'fullName': fullName,
        'phone': phone,
        'address': address,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> uploadAvatar(String uid, String filePath) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('avatars/$uid/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(io.File(filePath));
      final url = await ref.getDownloadURL();
      await _repository.updateProfile(uid, {'photoUrl': url});
      return url;
    } catch (e) {
      return null;
    }
  }
}

final profileUpdaterProvider = Provider<ProfileUpdater>((ref) {
  return ProfileUpdater(ref.read(profileRepositoryProvider));
});
