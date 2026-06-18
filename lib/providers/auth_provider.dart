import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ripple/core/utils/auth_error_helper.dart';
import 'package:ripple/core/utils/email_validation.dart';
import 'package:ripple/core/utils/snackbar_helper.dart';
import 'package:ripple/firebase/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final passwordResetCodeController = TextEditingController();
  var showPassword = false;
  var isLoading = false;
  User? _firebaseUser;
  final AuthService _authService = AuthService();

  //Call this method in splash screen
  void onInitialization({
    required VoidCallback navigateToHomeScreen,
    required VoidCallback navigateToLoginScreen,
  }) {
    // _firebaseUser = _authService.firebaseAuth.currentUser;
    _authService.firebaseAuth.authStateChanges().listen((user) {
      _firebaseUser = user;
      if (user == null) {
        navigateToLoginScreen();
      } else {
        navigateToHomeScreen();
      }
      notifyListeners();
    });
  }

  //Same method for sign in and sign up
  Future<void> signInUsingGoogle(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();
      await _authService.signInUsingGoogle();
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showSnackBar(context, "Error", e.toString());
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInEmailAndPassword(BuildContext context) async {
    String email = emailController.text;
    String password = passwordController.text;
    if (email.isEmpty || !EmailValidation.isValidEmail(email)) {
      SnackBarHelper.showSnackBar(
        context,
        "Invalid email",
        "Please, enter a valid email!",
      );
      return;
    }

    if (password.isEmpty) {
      SnackBarHelper.showSnackBar(
        context,
        "Missing password!",
        "Please enter a valid password!",
      );
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      await _authService.signInWithEmail(email, password);

      //navigation is already handled in splash screen
      // user will automatically navigated to home after successful login
    } on FirebaseAuthException catch (e) {
      String message = Autherrorhelper.authErrorMessage(e.code);

      if (context.mounted) {
        SnackBarHelper.showSnackBar(context, "Login Failed", message);
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showSnackBar(
          context,
          "Error",
          "An unexpected error occured $e",
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerAccountWithEmailAndPassword(BuildContext context) async {
    String email = emailController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    if (email.isEmpty || !EmailValidation.isValidEmail(email)) {
      SnackBarHelper.showSnackBar(
        context,
        "Invalid email",
        "Please, enter a valid email!",
      );
      return;
    }

    if (password.length < 6) {
      SnackBarHelper.showSnackBar(
        context,
        "Weak Password",
        "Password must be at least 6 characters long!",
      );
      return;
    }

    if (password != confirmPassword) {
      SnackBarHelper.showSnackBar(
        context,
        "Password Mismatch",
        "Passwords don't match!",
      );
      return;
    }

    try {
      isLoading = true;
      await _authService.signUpWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      String message = Autherrorhelper.authErrorMessage(e.code);
      if (context.mounted) {
        SnackBarHelper.showSnackBar(context, "Sign-up Failed", message);
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showSnackBar(
          context,
          'Error',
          'An unexpected error occurred: $e',
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      isLoading = true;
      await _authService.logout();
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showSnackBar(
          context,
          "Sign-out Failed",
          "Unexpected error occurred : $e",
        );
      }
    } finally {
      isLoading = false;
    }
  }

  //flow : go on a different screen like reset password screen
  //have two fields
  // one for email and other for reset code

  Future<void> sendForgotPasswordEmail(String email) async {



  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
