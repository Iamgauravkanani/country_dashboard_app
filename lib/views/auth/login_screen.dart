import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/theme.dart';
import '../../views/dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authController.isLoggedIn.value) {
        Get.offAll(() => DashboardScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Title
              Text(
                'Country Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor,
                ),
              ),
              SizedBox(height: 30.h),

              // Phone Input Field
              IntlPhoneField(
                controller: phoneController,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                  filled: true,
                  fillColor: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                ),
                initialCountryCode: 'IN',
                dropdownIcon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
                dropdownTextStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor),
                onChanged: (phone) {
                  authController.completePhoneNumber.value = phone.completeNumber;
                },
                onCountryChanged: (country) {
                  authController.completePhoneNumber.value = '${country.dialCode}${phoneController.text}';
                },
              ),
              SizedBox(height: 20.h),

              // Login Button
              Obx(
                () =>
                    authController.isLoading.value
                        ? CupertinoActivityIndicator()
                        : ElevatedButton(
                          onPressed: () {
                            if (phoneController.text.isNotEmpty) {
                              authController.verifyPhoneNumber(authController.completePhoneNumber.value);
                            }
                          },
                          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                            minimumSize: MaterialStateProperty.all(Size(double.infinity, 56.h)),
                          ),
                          child: Text(
                            'Login with OTP',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
