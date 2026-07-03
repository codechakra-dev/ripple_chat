import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ripple/core/services/shared_prefs.dart';
import 'package:ripple/providers/auth_provider.dart';
import 'package:ripple/providers/chat_provider.dart';
import 'package:ripple/providers/settings_provider.dart';
import 'package:ripple/providers/user_provider.dart';
import 'package:ripple/screens/auth/forgot_password_screen.dart';
import 'package:ripple/screens/auth/login_screen.dart';
import 'package:ripple/screens/auth/register_screen.dart';
import 'package:ripple/screens/chat/chat_screen.dart';
import 'package:ripple/screens/home/home_screen.dart';
import 'package:ripple/screens/profile/profile_screen.dart';
import 'package:ripple/screens/settings/settings_screen.dart';
import 'package:ripple/screens/splash/splash_screen.dart';

import 'core/constants/app_strings.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.notification?.title}');
}


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    // Uses Debug provider for emulators/local tests, Play Integrity for live users
    providerAndroid: kDebugMode ? const AndroidDebugProvider() :const AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode ? const AppleDebugProvider() : const AppleDeviceCheckProvider(),
    providerWeb: ReCaptchaV3Provider('your-recaptcha-v3-site-key'),
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final NotificationService notificationService = NotificationService();
  await notificationService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context)  {
    SettingsProvider settingsProvider = context.watch<SettingsProvider>();


    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Ripple Chat',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsProvider.currentThemeMode,
      initialRoute: AppStrings.splashScreen,

      routes: {
        AppStrings.splashScreen: (context) => const SplashScreen(),
        AppStrings.homeScreen: (context) => const ChatPreviewScreen(),
        AppStrings.chatScreen: (context) =>  ChatScreen(),
        AppStrings.forgotPasswordScreen: (context) =>
            const ForgotPasswordScreen(),
        AppStrings.loginScreen: (context) => const LoginScreen(),
        AppStrings.registerScreen: (context) => const RegisterScreen(),
        AppStrings.profileScreen: (context) => const ProfileScreen(),
        AppStrings.settingsScreen: (context) => const SettingsScreen(),
      },
    );
  }
}
