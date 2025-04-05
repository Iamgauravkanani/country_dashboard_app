import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../model/country_model.dart';
import '../model/custom_country_model.dart';
import '../services/api_service.dart';

class CountryController extends GetxController {
  final ApiService _apiService = ApiService();
  final RxList<Country> countries = <Country>[].obs;
  final RxList<Country> filteredCountries = <Country>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString sortOrder = 'desc'.obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('CountryController initialized');
    fetchCountries();
    ever(searchQuery, (_) => filterCountries());
  }

  Future<void> fetchCountries() async {
    try {
      isLoading.value = true;
      error.value = '';
      print('🌍 Fetching countries from API...');
      
      final apiCountries = await _apiService.getCountries();
      print('✅ Received ${apiCountries.length} countries from API');
      
      // Clear existing countries before adding new ones
      countries.clear();
      filteredCountries.clear();
      
      // Add new countries
      countries.addAll(apiCountries);
      print('📊 Total countries loaded: ${countries.length}');
      
      // Apply current filter
      filterCountries();
      
      // Apply current sort
      sortCountries();
      
    } catch (e) {
      print('❌ Error fetching countries: $e');
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load countries: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshCountries() async {
    print('🔄 Refreshing countries...');
    await fetchCountries();
  }

  void addCustomCountry(CustomCountry customCountry) {
    debugPrint('Adding custom country: ${customCountry.name}');
    
    // Check if country with same name already exists
    final existingIndex = countries.indexWhere((c) => c.name == customCountry.name);
    if (existingIndex != -1) {
      debugPrint('Country already exists: ${customCountry.name}');
      return;
    }
    
    countries.add(
      Country(
        name: customCountry.name,
        capital: customCountry.capital,
        region: customCountry.region,
        population: customCountry.population,
        languages: ['Custom'],
        flag: '',
      ),
    );
    filterCountries();
  }

  void updateCustomCountry(String oldName, CustomCountry newCountry) {
    debugPrint('Updating custom country from $oldName to ${newCountry.name}');
    
    // Check if new name already exists (if name is being changed)
    if (oldName != newCountry.name) {
      final existingIndex = countries.indexWhere((c) => c.name == newCountry.name);
      if (existingIndex != -1) {
        debugPrint('Country with name ${newCountry.name} already exists');
        return;
      }
    }
    
    final index = countries.indexWhere((c) => c.name == oldName);
    if (index != -1) {
      countries[index] = Country(
        name: newCountry.name,
        capital: newCountry.capital,
        region: newCountry.region,
        population: newCountry.population,
        languages: ['Custom'],
        flag: '',
      );
      filterCountries();
    } else {
      debugPrint('Country not found: $oldName');
    }
  }

  void filterCountries() {
    debugPrint('🔍 Filtering countries with query: ${searchQuery.value}');
    if (searchQuery.value.isEmpty) {
      filteredCountries.assignAll(countries);
      debugPrint('✅ Showing all ${countries.length} countries');
    } else {
      filteredCountries.assignAll(
        countries.where((country) => country.name.toLowerCase().contains(searchQuery.value.toLowerCase())),
      );
      debugPrint('✅ Filtered to ${filteredCountries.length} countries matching "${searchQuery.value}"');
    }
    sortCountries();
  }

  void sortCountries() {
    debugPrint('🔄 Sorting countries by population (${sortOrder.value})');
    filteredCountries.sort((a, b) {
      if (sortOrder.value == 'asc') {
        return a.population.compareTo(b.population);
      } else {
        return b.population.compareTo(a.population);
      }
    });
    debugPrint('✅ Countries sorted (${sortOrder.value})');
  }

  void toggleSortOrder() {
    sortOrder.value = sortOrder.value == 'asc' ? 'desc' : 'asc';
    debugPrint('Sort order changed to: ${sortOrder.value}');
    sortCountries();
  }

  void clearError() {
    error.value = '';
  }
}
