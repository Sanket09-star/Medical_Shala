/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

Future<UserCredential?> signInWithApple() async {
  final appleCredential = await SignInWithApple.getAppleIDCredential(
    scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
  );
  final oauthCredential = OAuthProvider("apple.com").credential(
    idToken: appleCredential.identityToken,
    accessToken: appleCredential.authorizationCode,
  );
  return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
} */