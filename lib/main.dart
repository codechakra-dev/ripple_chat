import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ripple/providers/auth_provider.dart';
import 'package:ripple/providers/chat_provider.dart';
import 'package:ripple/providers/user_provider.dart';
import 'package:ripple/screens/auth/forgot_password_screen.dart';
import 'package:ripple/screens/auth/login_screen.dart';
import 'package:ripple/screens/auth/register_screen.dart';
import 'package:ripple/screens/chat/chat_screen.dart';
import 'package:ripple/screens/home/home_screen.dart';
import 'package:ripple/screens/profile/profile_screen.dart';
import 'package:ripple/screens/splash/splash_screen.dart';

import 'core/constants/app_strings.dart';
import 'firebase_options.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: AppStrings.splashScreen,
      routes: {
        AppStrings.splashScreen: (context) => const SplashScreen(),
        AppStrings.homeScreen : (context)=> const HomeScreen(),
        AppStrings.chatScreen : (context) => const ChatScreen(),
        AppStrings.forgotPasswordScreen : (context) => const ForgotPasswordScreen(),
        AppStrings.loginScreen : (context) => const LoginScreen(),
        AppStrings.registerScreen : (context)=> const RegisterScreen(),
        AppStrings.profileScreen : (context) => const ProfileScreen()

      },
    );
  }
}
