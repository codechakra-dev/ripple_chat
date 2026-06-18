import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ripple/providers/auth_provider.dart';

import '../../core/constants/app_strings.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = context.read<AuthProvider>();
    authProvider.onInitialization(
      navigateToHomeScreen: () {
        Navigator.pushReplacementNamed(context, AppStrings.homeScreen);
      },
      navigateToLoginScreen: () {
        Navigator.pushReplacementNamed(context, AppStrings.loginScreen);
      },
    );

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("App is Working!")],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
