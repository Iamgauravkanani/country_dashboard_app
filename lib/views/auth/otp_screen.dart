import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../views/dashboard/dashboard_screen.dart';

class OtpScreen extends StatefulWidget {
  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  final AuthController authController = Get.find();
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authController.isLoggedIn.value) {
        Get.offAll(() => DashboardScreen());
      }
      
      // Start resend timer
      _startResendTimer();
    });
  }
  
  void _startResendTimer() {
    _canResend = false;
    _resendTimer = 60;
    
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
            _startResendTimer();
          } else {
            _canResend = true;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final defaultPinTheme = PinTheme(
      width: 56.w,
      height: 56.h,
      textStyle: Theme.of(context).textTheme.headlineSmall,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
    );

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Verify OTP',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20.w,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the 6-digit code',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDarkMode ? AppTheme.darkTextColor.withOpacity(0.8) : AppTheme.lightTextColor.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'We sent a verification code to ${authController.completePhoneNumber.value}',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: isDarkMode ? AppTheme.darkTextColor.withOpacity(0.6) : AppTheme.lightTextColor.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 24.h),
            Pinput(
              controller: otpController,
              length: 6,
              defaultPinTheme: defaultPinTheme,
              onCompleted: (pin) {
                if (pin.length == 6) {
                  authController.verifyOtp(pin);
                }
              },
              onChanged: (value) {
                // Clear any error messages when user types
                if (authController.errorMessage.isNotEmpty) {
                  authController.errorMessage.value = '';
                }
              },
            ),
            SizedBox(height: 24.h),
            Obx(
              () => authController.isLoading.value
                  ? Center(child: CupertinoActivityIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        if (otpController.text.length == 6) {
                          authController.verifyOtp(otpController.text);
                        } else {
                          Get.snackbar(
                            'Error',
                            'Please enter a valid OTP',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: isDarkMode ? AppTheme.darkCardColor : Colors.white,
                          );
                        }
                      },
                      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                        minimumSize: MaterialStateProperty.all(Size(double.infinity, 56.h)),
                      ),
                      child: Text(
                        'Verify', 
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 16.h),
            Center(
              child: TextButton(
                onPressed: _canResend 
                    ? () {
                        authController.verifyPhoneNumber(authController.completePhoneNumber.value);
                        _startResendTimer();
                      }
                    : null,
                child: Text(
                  _canResend 
                      ? 'Resend OTP' 
                      : 'Resend OTP in $_resendTimer seconds',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: _canResend 
                        ? Theme.of(context).primaryColor
                        : isDarkMode 
                            ? AppTheme.darkTextColor.withOpacity(0.5)
                            : AppTheme.lightTextColor.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() => authController.errorMessage.isNotEmpty
                ? Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppTheme.errorColor,
                          size: 20.w,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            authController.errorMessage.value,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
