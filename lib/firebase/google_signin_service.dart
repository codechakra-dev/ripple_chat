import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ripple/firebase/auth_service.dart';

class GoogleSignInService {

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  //This code remains same for SignIn and SignUp for google
  Future<UserCredential?> handGoogleSignIn(FirebaseAuth firebaseAuth) async {
    final GoogleSignInAccount? googleSignInAccount = await _googleSignIn
        .signIn();

    if (googleSignInAccount == null) {
      // sign in was canceled
      return null;
    }

    GoogleSignInAuthentication signInAuthentication =
        await googleSignInAccount.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: signInAuthentication.idToken,
      accessToken: signInAuthentication.accessToken,
    );

    final UserCredential userCredential = await firebaseAuth
        .signInWithCredential(credential);

    return userCredential;
  }
}
