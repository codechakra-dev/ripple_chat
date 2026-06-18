import 'package:firebase_auth/firebase_auth.dart';
import 'package:ripple/firebase/google_signin_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GoogleSignInService _googleSignInService = GoogleSignInService();

  FirebaseAuth get firebaseAuth => _firebaseAuth;

  //SIGN UP USING EMAIL AND PASSWORD
  Future<void> signUpWithEmail(String email, String password) async {
    final UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);

    await userCredential.user?.sendEmailVerification();
  }

  //SIGN IN USING EMAIL AND PASSWORD
  Future<void> signInWithEmail(String email, String password) async {
    final UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
  }

  //SIGN IN USING GOOGLE
  Future<void> signInUsingGoogle() async {
    await _googleSignInService.handGoogleSignIn(firebaseAuth);
  }

  //SIGN UP USING GOOGLE
  Future<void> signUpUsingGoogle() async {
    await _googleSignInService.handGoogleSignIn(firebaseAuth);
  }

  //SIGN OUT USER
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  Future<void> forgotPassword(String email) async {
      //send email to reset password
      await firebaseAuth.sendPasswordResetEmail(email: email);
      //call confirm reset password after this
  }

  Future<void> confirmResetPassword(String code, String newPassword) async {
    await firebaseAuth.confirmPasswordReset(code: code, newPassword: newPassword);
  }
}
