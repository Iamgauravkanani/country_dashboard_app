import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../model/country_model.dart';
import '../../utils/theme.dart';

class CountryDetailScreen extends StatelessWidget {
  final Country country;

  const CountryDetailScreen({required this.country});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          country.name,
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem(
              context,
              'Capital',
              country.capital,
              Icons.location_city,
              isDarkMode,
            ),
            SizedBox(height: 16.h),
            _buildDetailItem(
              context,
              'Region',
              country.region,
              Icons.public,
              isDarkMode,
            ),
            SizedBox(height: 16.h),
            _buildDetailItem(
              context,
              'Population',
              country.population.toString(),
              Icons.people,
              isDarkMode,
            ),
            SizedBox(height: 16.h),
            _buildDetailItem(
              context,
              'Area',
              '${country.area ?? 'N/A'} km²',
              Icons.map,
              isDarkMode,
            ),
            if (country.languages != null && country.languages!.isNotEmpty) ...[
              SizedBox(height: 16.h),
              _buildDetailItem(
                context,
                'Languages',
                country.languages!.join(', '),
                Icons.language,
                isDarkMode,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool isDarkMode,
  ) {
    return Card(
      color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: isDarkMode
                          ? AppTheme.darkTextColor.withOpacity(0.7)
                          : AppTheme.lightTextColor.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
