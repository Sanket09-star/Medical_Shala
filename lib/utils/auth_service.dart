import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'apple_sign_in_stub.dart'
    if (dart.library.io) 'apple_sign_in_ios.dart';

class AuthService {
  static Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // User cancelled
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  static Future<UserCredential?> signInWithApple() async {
    return await signInWithApple();
  }

  static Future<void> saveUserInfoIfNew(User user) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'fullName': user.displayName ?? '',
        'email': user.email ?? '',
        'avatarUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
} 