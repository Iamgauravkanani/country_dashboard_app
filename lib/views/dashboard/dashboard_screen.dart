import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../controllers/country_controller.dart';
import '../../controllers/firestore_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../model/custom_country_model.dart';
import '../../utils/theme.dart';
import '../dashboard/add_country_screen.dart';
import '../dashboard/country_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  final CountryController countryController = Get.put(CountryController());
  final FirestoreController firestoreController = Get.put(FirestoreController());
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Country Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () => Get.to(() => AddCountryScreen()),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: _buildSearchBar(isDarkMode, context),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildSortButton(context),
            ),
            SizedBox(height: 8.h),
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'All Countries',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(child: _buildCountryList(isDarkMode)),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'Custom Countries',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(child: _buildCustomCountryList(isDarkMode)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode, BuildContext context) {
    return TextField(
      onChanged: (value) => countryController.searchQuery.value = value,
      style: GoogleFonts.poppins(
        fontSize: 16.sp,
        color: isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor,
      ),
      decoration: InputDecoration(
        labelText: 'Search Countries',
        labelStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
        filled: true,
        fillColor: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
        border: OutlineInputBorder(borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

  Widget _buildSortButton(BuildContext context) {
    return Obx(
      () => ElevatedButton(
        onPressed: () => countryController.toggleSortOrder(),
        style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
          padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder()),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort by Population',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 5.w),
            Icon(
              countryController.sortOrder.value == 'asc' ? Icons.arrow_upward : Icons.arrow_downward,
              size: 20.w,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryList(bool isDarkMode) {
    return Obx(() {
      if (countryController.isLoading.value && countryController.countries.isEmpty) {
        return Center(child: CupertinoActivityIndicator());
      }

      if (countryController.error.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48.w,
                color: AppTheme.errorColor,
              ),
              SizedBox(height: 16.h),
              Text(
                'Error: ${countryController.error.value}',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => countryController.refreshCountries(),
                style: Theme.of(Get.context!).elevatedButtonTheme.style?.copyWith(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder()),
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (countryController.filteredCountries.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 48.w,
                color: isDarkMode ? AppTheme.darkTextColor.withOpacity(0.5) : AppTheme.lightTextColor.withOpacity(0.5),
              ),
              SizedBox(height: 16.h),
              Text(
                'No Countries Found',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? AppTheme.darkTextColor.withOpacity(0.7) : AppTheme.lightTextColor.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Try a different search term',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: isDarkMode ? AppTheme.darkTextColor.withOpacity(0.5) : AppTheme.lightTextColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification.metrics.pixels >= scrollNotification.metrics.maxScrollExtent - 200 &&
              !countryController.isLoading.value &&
              countryController.hasMoreData.value) {
            debugPrint('Loading more countries...');
            countryController.fetchCountries();
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: countryController.filteredCountries.length + (countryController.hasMoreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= countryController.filteredCountries.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Center(child: CupertinoActivityIndicator()),
              );
            }
            final country = countryController.filteredCountries[index];
            return Card(
              margin: EdgeInsets.only(bottom: 8.h),
              color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
              shape: RoundedRectangleBorder(),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.public,
                    color: Theme.of(context).primaryColor,
                    size: 24.w,
                  ),
                ),
                title: Text(
                  country.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Population: ${country.population}',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: isDarkMode ? AppTheme.darkTextColor.withOpacity(0.7) : AppTheme.lightTextColor.withOpacity(0.7),
                  ),
                ),
                trailing: Text(
                  country.region,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: isDarkMode ? AppTheme.darkTextColor.withOpacity(0.7) : AppTheme.lightTextColor.withOpacity(0.7),
                  ),
                ),
                onTap: () => Get.to(() => CountryDetailScreen(country: country)),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildCustomCountryList(bool isDarkMode) {
    return Obx(() {
      if (firestoreController.isLoading.value && firestoreController.customCountries.isEmpty) {
        return Center(child: CupertinoActivityIndicator());
      }

      if (firestoreController.error.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48.w,
                color: AppTheme.errorColor,
              ),
              SizedBox(height: 16.h),
              Text(
                'Error: ${firestoreController.error.value}',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => firestoreController.setupCountriesStream(),
                style: Theme.of(Get.context!).elevatedButtonTheme.style?.copyWith(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder()),
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (firestoreController.customCountries.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.public_off,
                size: 48.w,
                color: isDarkMode ? AppTheme.darkTextColor.withOpacity(0.5) : AppTheme.lightTextColor.withOpacity(0.5),
              ),
              SizedBox(height: 16.h),
              Text(
                'No Custom Countries',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? AppTheme.darkTextColor.withOpacity(0.7) : AppTheme.lightTextColor.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Add your first custom country',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: isDarkMode ? AppTheme.darkTextColor.withOpacity(0.5) : AppTheme.lightTextColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: firestoreController.customCountries.length,
        itemBuilder: (context, index) {
          final country = firestoreController.customCountries[index];
          return Slidable(
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => Get.to(() => AddCountryScreen(country: country)),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: 'Edit',
                  borderRadius: BorderRadius.zero,
                ),
                SlidableAction(
                  onPressed: (context) => _showDeleteDialog(context, country),
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                  borderRadius: BorderRadius.zero,
                ),
              ],
            ),
            child: Card(
              margin: EdgeInsets.only(bottom: 8.h),
              color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
              shape: RoundedRectangleBorder(),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.flag,
                    color: Theme.of(context).primaryColor,
                    size: 24.w,
                  ),
                ),
                title: Text(
                  country.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Population: ${country.population}',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: isDarkMode ? AppTheme.darkTextColor.withOpacity(0.7) : AppTheme.lightTextColor.withOpacity(0.7),
                  ),
                ),
                trailing: Text(
                  country.region,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: isDarkMode ? AppTheme.darkTextColor.withOpacity(0.7) : AppTheme.lightTextColor.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  void _showLogoutDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    Get.dialog(
      AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: isDarkMode ? AppTheme.darkTextColor.withOpacity(0.7) : AppTheme.lightTextColor.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              backgroundColor: MaterialStateProperty.all(AppTheme.errorColor),
              shape: MaterialStateProperty.all(RoundedRectangleBorder()),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CustomCountry country) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    Get.dialog(
      AlertDialog(
        title: Text(
          'Delete Country',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${country.name}?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: isDarkMode ? AppTheme.darkTextColor.withOpacity(0.7) : AppTheme.lightTextColor.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              firestoreController.deleteCountry(country.id);
            },
            style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              backgroundColor: MaterialStateProperty.all(AppTheme.errorColor),
              shape: MaterialStateProperty.all(RoundedRectangleBorder()),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
