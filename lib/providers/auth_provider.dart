import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ripple/core/constants/app_strings.dart';
import 'package:ripple/core/utils/auth_error_helper.dart';
import 'package:ripple/core/utils/email_validation.dart';
import 'package:ripple/core/utils/snackbar_helper.dart';
import 'package:ripple/firebase/auth_service.dart';
import 'package:ripple/firebase/firebase_service.dart';
import 'package:ripple/main.dart';
import 'package:ripple/models/user_model.dart';

class AuthenticationProvider extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final passwordResetCodeController = TextEditingController();

  //final resetCodeController = TextEditingController();
  var showPassword = false;
  var isLoading = false;

  var isCodeSent = false;
  var hidePassword = false;

   User? _currentUser;
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();

  User? get currentUser => _currentUser;
  StreamSubscription<User?>? _userStreamSubscription;
  //Call this method in splash screen
  void onInitialization() async {

    // _firebaseUser = _authService.firebaseAuth.currentUser;

   await _userStreamSubscription?.cancel();
  _userStreamSubscription =  _authService.firebaseAuth.authStateChanges().listen((user) {
      // _firebaseUser = user;
      if (user == null) {
        navigatorKey.currentState?.pushReplacementNamed(AppStrings.loginScreen);
      } else {
        _currentUser = user;
        clearAllControllers();
        navigatorKey.currentState?.pushReplacementNamed(AppStrings.homeScreen);
      }
      notifyListeners();
    });

    // emailController.addListener(() {
    //   print("Email: ${emailController.text}");
    // });
  }

  void togglePasswordVisibility() {
    hidePassword = !hidePassword;
    // print("Hide password: ${hidePassword}");
    notifyListeners();
  }

  //Same method for sign in and sign up
  Future<void> signInUsingGoogle(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();
      UserCredential? userCredential = await _authService.signInUsingGoogle();

      //Create a new user if user has signed up
      if (userCredential != null &&
          userCredential.additionalUserInfo!.isNewUser) {
        await _firebaseService.createUser(
          UserModel(
            uid: userCredential.user?.uid ?? "",
            name: userCredential.user?.displayName ?? "",
            email: userCredential.user?.email ?? "",
            isOnline: true,
          ),
        );
      }
    } catch (e) {

      print("Google signin error: $e");
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
      String message = AuthErrorHelper.authErrorMessage(e.code);

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
      UserCredential userCredential = await _authService.signUpWithEmail(
        email,
        password,
      );
      if (userCredential.additionalUserInfo!.isNewUser) {
        _firebaseService.createUser(
          UserModel(
            uid: userCredential.user?.uid ?? "",
            name: userCredential.user?.displayName ?? "",
            email: userCredential.user?.email ?? "",
            isOnline: true,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = AuthErrorHelper.authErrorMessage(e.code);
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

  Future<void> sendForgotPasswordEmail(
    BuildContext context,
    String email,
  ) async {
    if (email.isEmpty || !EmailValidation.isValidEmail(email)) {
      SnackBarHelper.showSnackBar(
        context,
        "Invalid email",
        "Please, enter a valid email!",
      );
      return;
    }
    try {
      isCodeSent = false;
      isLoading = true;
      notifyListeners();
      await _authService.forgotPassword(email);
      isCodeSent = true;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      String message = AuthErrorHelper.authErrorMessage(e.code);
      if (context.mounted) {
        SnackBarHelper.showSnackBar(context, "Failed", message);
      }
    } catch (e) {
      isCodeSent = false;
      notifyListeners();
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

  Future<void> confirmPasswordResetRequest(
    BuildContext context,
    String code,
    String newPassword,
  ) async {
    if (newPassword.length < 6) {
      SnackBarHelper.showSnackBar(
        context,
        "Weak Password",
        "Password must be at least 6 characters long!",
      );
      return;
    }

    if (code.isEmpty) {
      SnackBarHelper.showSnackBar(
        context,
        "Wrong Code",
        "Please enter valid code!",
      );
      return;
    }
    try {
      isLoading = true;

      notifyListeners();
      await _authService.confirmResetPassword(code, newPassword);
      if (context.mounted) {
        SnackBarHelper.showSnackBar(
          context,
          "Success",
          "Password reset successfully!",
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = AuthErrorHelper.authErrorMessage(e.code);
      if (context.mounted) {
        SnackBarHelper.showSnackBar(context, "Failed", message);
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showSnackBar(context, "Unexpected error: ", "$e");
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearAllControllers() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    passwordResetCodeController.clear();
  }

  @override
  void dispose() {
    _userStreamSubscription?.cancel();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordResetCodeController.dispose();
    super.dispose();
  }
}
