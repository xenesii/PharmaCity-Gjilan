import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        final user = UserModel.fromFirestore(userDoc);
        return user;
      }

      // Nëse dokumenti nuk ekziston, krijo një të ri me rolin e duhur
      final isAdmin = email == 'admin@pharmacity.com';
      final UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        fullName: isAdmin ? 'Admin' : userCredential.user?.displayName ?? '',
        phone: userCredential.user?.phoneNumber ?? '',
        address: '',
        role: isAdmin ? 'admin' : 'user',
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toFirestore());

      return newUser;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase error codes
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Nuk u gjet asnjë llogari me këtë email.');
        case 'wrong-password':
          throw Exception('Fjalëkalimi është i gabuar.');
        case 'invalid-email':
          throw Exception('Adresa e email-it është e pavlefshme.');
        case 'user-disabled':
          throw Exception('Ky përdorues është çaktivizuar.');
        case 'too-many-requests':
          throw Exception('Shumë përpjekje. Ju lutemi provoni përsëri më vonë.');
        case 'network-request-failed':
          throw Exception('Nuk ka lidhje interneti.');
        default:
          throw Exception('Hyrja dështoi: ${e.message}');
      }
    } catch (e) {
      throw Exception('Ndodhi një gabim i papritur: $e');
    }
  }

  // Sign up with email and password
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      final UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        fullName: fullName,
        phone: phone,
        address: '', // Empty initially, user can update later
        role: 'user',
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toFirestore());

      return newUser;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase error codes
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Një llogari me këtë email ekziston tashmë.');
        case 'weak-password':
          throw Exception('Fjalëkalimi duhet të ketë të paktën 6 karaktere.');
        case 'invalid-email':
          throw Exception('Adresa e email-it është e pavlefshme.');
        case 'operation-not-allowed':
          throw Exception('Llogaritë me email/fjalëkalim nuk janë të aktivizuara.');
        case 'too-many-requests':
          throw Exception('Shumë përpjekje. Ju lutemi provoni përsëri më vonë.');
        case 'network-request-failed':
          throw Exception('Nuk ka lidhje interneti.');
        default:
          throw Exception('Regjistrimi dështoi: ${e.message}');
      }
    } catch (e) {
      throw Exception('Ndodhi një gabim i papritur: $e');
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check if user doc exists, if not create one
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        final existingUser = UserModel.fromFirestore(userDoc);
        return existingUser;
      }

      // Create new user document for Google sign-in
      final UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        fullName: userCredential.user!.displayName ?? '',
        phone: userCredential.user!.phoneNumber ?? '',
        address: '',
        role: 'user',
        photoUrl: userCredential.user!.photoURL,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toFirestore());

      return newUser;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('Një llogari ekziston tashmë me të njëjtin email.');
        case 'invalid-credential':
          throw Exception('Kredencialet janë të pavlefshme.');
        case 'operation-not-allowed':
          throw Exception('Hyrja me Google nuk është e aktivizuar.');
        case 'user-disabled':
          throw Exception('Ky përdorues është çaktivizuar.');
        case 'network-request-failed':
          throw Exception('Nuk ka lidhje interneti.');
        default:
          throw Exception('Hyrja me Google dështoi: ${e.message}');
      }
    } catch (e) {
      throw Exception('Ndodhi një gabim i papritur: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Nuk u gjet asnjë llogari me këtë email.');
        case 'invalid-email':
          throw Exception('Adresa e email-it është e pavlefshme.');
        case 'missing-email':
          throw Exception('Duhet të jepni një adresë email-i.');
        case 'network-request-failed':
          throw Exception('Nuk ka lidhje interneti.');
        default:
          throw Exception('Dërgimi i email-it për rivendosje dështoi: ${e.message}');
      }
    } catch (e) {
      throw Exception('Ndodhi një gabim i papritur: $e');
    }
  }

  // Get user by ID from Firestore
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final user = UserModel.fromFirestore(doc);
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get current user
  UserModel? getCurrentUser() {
    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      // Note: This is synchronous and doesn't fetch fresh data from Firestore
      // For production, you might want to use a stream or make it async
      return UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        fullName: firebaseUser.displayName ?? '',
        phone: firebaseUser.phoneNumber ?? '',
        address: '', // Would need to fetch from Firestore
        role: 'user', // Would need to fetch from Firestore
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(), // Would need to fetch from Firestore
      );
    }
    return null;
  }

  // Auth state changes stream
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Update profile
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Përditësimi i profilit dështoi: $e');
    }
  }
}