import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/firestore_controller.dart';

import '../../model/custom_country_model.dart';
import '../../utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AddCountryScreen extends StatefulWidget {
  final CustomCountry? country;

  const AddCountryScreen({Key? key, this.country}) : super(key: key);

  @override
  State<AddCountryScreen> createState() => _AddCountryScreenState();
}

class _AddCountryScreenState extends State<AddCountryScreen> {
  final FirestoreController firestoreController = Get.find();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _capitalController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _populationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.country != null) {
      _nameController.text = widget.country!.name;
      _capitalController.text = widget.country!.capital;
      _regionController.text = widget.country!.region;
      _populationController.text = widget.country!.population.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capitalController.dispose();
    _regionController.dispose();
    _populationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.country == null ? 'Add Country' : 'Edit Country',
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
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextFormField(
                  controller: _nameController,
                  label: 'Country Name',
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16.h),
                _buildTextFormField(
                  controller: _capitalController,
                  label: 'Capital',
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16.h),
                _buildTextFormField(
                  controller: _regionController,
                  label: 'Region',
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16.h),
                _buildTextFormField(
                  controller: _populationController,
                  label: 'Population',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Required';
                    if (int.tryParse(value) == null) return 'Must be a number';
                    return null;
                  },
                ),
                SizedBox(height: 32.h),
                Obx(
                  () =>
                      firestoreController.isLoading.value
                          ? Center(child: CupertinoActivityIndicator())
                          : ElevatedButton(
                            onPressed: _submitForm,
                            style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                              minimumSize: MaterialStateProperty.all(Size(double.infinity, 56.h)),
                            ),
                            child: Text(
                              widget.country == null ? 'Add Country' : 'Update Country',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
        filled: true,
        fillColor: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      validator: validator,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newCountry = CustomCountry(
        id: widget.country?.id ?? '',
        name: _nameController.text,
        capital: _capitalController.text,
        region: _regionController.text,
        population: int.parse(_populationController.text),
      );

      if (widget.country == null) {
        firestoreController.addCountry(newCountry);
      } else {
        firestoreController.updateCountry(widget.country!.id, newCountry);
      }
      Get.back();
    }
  }
}
