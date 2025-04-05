import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/theme.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final AuthController _authController = Get.find();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Welcome to Country Dashboard',
      'description': 'Your comprehensive platform for exploring and managing country information worldwide',
      'icon': Icons.public,
      'color': AppTheme.onboardingColor1,
    },
    {
      'title': 'Explore Countries',
      'description': 'Discover detailed information about countries, including population, capital, and region data',
      'icon': Icons.explore,
      'color': AppTheme.onboardingColor2,
    },
    {
      'title': 'Manage Custom Data',
      'description': 'Add, edit, and manage your own country information with real-time updates',
      'icon': Icons.edit_note,
      'color': AppTheme.onboardingColor3,
    },
    {
      'title': 'Real-time Updates',
      'description': 'All changes sync across devices instantly, ensuring you always have the latest information',
      'icon': Icons.sync,
      'color': AppTheme.onboardingColor4,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_authController.isLoggedIn.value) {
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
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 160.w,
                          height: 160.h,
                          decoration: BoxDecoration(
                            color: data['color'].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            data['icon'],
                            size: 80.w,
                            color: data['color'],
                          ),
                        ),
                        SizedBox(height: 40.h),
                        Text(
                          data['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          data['description'],
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: isDarkMode 
                                ? AppTheme.darkTextColor.withOpacity(0.8) 
                                : AppTheme.lightTextColor.withOpacity(0.7),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: _currentPage == index ? 24.w : 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.r),
                          color: _currentPage == index 
                              ? _onboardingData[index]['color']
                              : isDarkMode 
                                  ? Colors.grey.shade700 
                                  : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _onboardingData.length - 1) {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      } else {
                        _authController.completeOnboarding();
                        Get.offAll(() => LoginScreen());
                      }
                    },
                    style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                      minimumSize: MaterialStateProperty.all(Size(double.infinity, 56.h)),
                    ),
                    child: Text(
                      _currentPage < _onboardingData.length - 1 ? 'Next' : 'Get Started',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (_currentPage < _onboardingData.length - 1) ...[
                    SizedBox(height: 16.h),
                    TextButton(
                      onPressed: () {
                        _authController.completeOnboarding();
                        Get.offAll(() => LoginScreen());
                      },
                      child: Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: isDarkMode 
                              ? AppTheme.darkTextColor.withOpacity(0.7)
                              : AppTheme.lightTextColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
