import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/auth_repository.dart';
import '../../domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) return null;
  final repo = ref.read(authRepositoryProvider);
  return await repo.getUserById(auth.currentUser!.uid);
});

final authLoadingProvider = StateProvider<bool>((ref) => false);
final authErrorProvider = StateProvider<String?>((ref) => null);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).valueOrNull != null;
});

final isAdminProvider = FutureProvider<bool>((ref) async {
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) return false;
  final repo = ref.read(authRepositoryProvider);
  final user = await repo.getUserById(auth.currentUser!.uid);
  return user?.role == 'admin';
});
