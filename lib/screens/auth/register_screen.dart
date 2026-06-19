import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ripple/core/constants/app_strings.dart';
import 'package:ripple/providers/auth_provider.dart';
import 'package:ripple/widgets/custom_text.dart';

import '../../widgets/custom_textfield.dart';


class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final authProvider = context.read<AuthenticationProvider>();
    final emailController = authProvider
        .emailController;
    final passwordController = authProvider
        .passwordController;
    final confirmPasswordController = authProvider
        .confirmPasswordController;

    var hidePassword = context.watch<AuthenticationProvider>().hidePassword;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_add_outlined,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),

                  const CustomText(
                    text: 'Create Account',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,

                    color: Colors.white,
                  ),


                  const SizedBox(height: 8),

                  CustomText(
                    text: 'Sign up to get started',
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),

                  const SizedBox(height: 32),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: emailController,
                            isObscureText: false,
                            labelText: "Email",
                            keyboardInputType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: passwordController,
                            isObscureText: hidePassword,
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => context
                                  .read<AuthenticationProvider>()
                                  .togglePasswordVisibility(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Basic check: passwords match (can also validate length etc.)
                                authProvider.registerAccountWithEmailAndPassword(context);

                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A11CB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'or',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => {

                                authProvider.signInUsingGoogle(context)
                              },
                              icon: Image.asset(
                                'assets/icons/ic_google.png',
                                height: 24,
                              ),
                              label: const Text(
                                'Sign up with Google',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Already registered link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account?"),
                              TextButton(
                                onPressed: (){
                                  authProvider.clearAllControllers();
                                  Navigator.pushReplacementNamed(context, AppStrings.loginScreen);

                                },
                                child: const Text('Sign in'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
