import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/auth/login_screen.dart';
import '../views/auth/otp_screen.dart';
import '../views/dashboard/dashboard_screen.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late SharedPreferences _prefs;

  final RxString completePhoneNumber = ''.obs;
  final RxBool isLoggedIn = false.obs;
  final RxBool isFirstTime = true.obs;
  final RxString verificationId = ''.obs;
  final RxnInt forceResendingToken = RxnInt(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    
    // Load saved states
    isFirstTime.value = _prefs.getBool('isFirstTime') ?? true;
    isLoggedIn.value = _prefs.getBool('isLoggedIn') ?? false;
    
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) async {
      print('Auth state changed: ${user != null ? 'User logged in' : 'User logged out'}');
      isLoggedIn.value = user != null;
      await _prefs.setBool('isLoggedIn', isLoggedIn.value);
      
      // If user is logged in and we're on the login screen, navigate to dashboard
      if (isLoggedIn.value && Get.currentRoute.contains('LoginScreen')) {
        Get.offAll(() => DashboardScreen());
      }
    });
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      completePhoneNumber.value = phoneNumber;

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          isLoading.value = false;
          await _auth.signInWithCredential(credential);
          isLoggedIn.value = true;
          await _prefs.setBool('isLoggedIn', true);
          Get.offAll(() => DashboardScreen());
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          errorMessage.value = e.message ?? 'Verification failed';
          Get.snackbar('Error', errorMessage.value);
        },
        codeSent: (String verificationId, int? resendToken) {
          isLoading.value = false;
          this.verificationId.value = verificationId;
          forceResendingToken.value = resendToken;
          print('Verification ID: $verificationId');
          Get.to(() => OtpScreen());
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          isLoading.value = false;
          this.verificationId.value = verificationId;
        },
        forceResendingToken: forceResendingToken.value,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value);
    }
  }

  Future<void> verifyOtp(String otp) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      print('Verifying OTP: $otp with verificationId: ${verificationId.value}');
      
      if (verificationId.value.isEmpty) {
        isLoading.value = false;
        errorMessage.value = 'Verification ID is missing. Please try again.';
        Get.snackbar('Error', errorMessage.value);
        return;
      }
      
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value, 
        smsCode: otp
      );

      await _auth.signInWithCredential(credential);
      isLoggedIn.value = true;
      await _prefs.setBool('isLoggedIn', true);
      isLoading.value = false;
      Get.offAll(() => DashboardScreen());
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      print('OTP verification error: $e');
      
      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-verification-code') {
          Get.snackbar('Error', 'Invalid OTP. Please check and try again.');
        } else if (e.code == 'invalid-verification-id') {
          Get.snackbar('Error', 'Verification session expired. Please request a new OTP.');
        } else {
          Get.snackbar('Error', e.message ?? 'OTP verification failed');
        }
      } else {
        Get.snackbar('Error', 'OTP verification failed: ${e.toString()}');
      }
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _auth.signOut();
      isLoggedIn.value = false;
      await _prefs.setBool('isLoggedIn', false);
      isLoading.value = false;
      Get.offAll(() => LoginScreen());
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> completeOnboarding() async {
    isFirstTime.value = false;
    await _prefs.setBool('isFirstTime', false);
    
    // If user is already logged in, go to dashboard, otherwise go to login
    if (isLoggedIn.value) {
      Get.offAll(() => DashboardScreen());
    } else {
      Get.offAll(() => LoginScreen());
    }
  }
}
