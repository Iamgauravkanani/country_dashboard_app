import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:interview_task/views/auth/login_screen.dart';
import 'package:interview_task/views/dashboard/dashboard_screen.dart';
import 'controllers/auth_controller.dart';
import 'firebase_options.dart';
import 'utils/theme.dart';
import 'views/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize AuthController before running the app
  final authController = Get.put(AuthController());

  // Wait for auth state to be determined
  await Future.delayed(Duration(milliseconds: 500));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812), // iPhone 13 size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          title: 'Country Dashboard',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: child,
        );
      },
      child: Obx(() {
        // Check if it's the first time the app is launched
        if (authController.isFirstTime.value) {
          // return OnboardingScreen();
          return OnboardingScreen();
        }
        // Check if the user is already logged in
        else if (authController.isLoggedIn.value) {
          return DashboardScreen();
        }
        // Otherwise, show the login screen
        else {
          return LoginScreen();
        }
      }),
    );
  }
}
