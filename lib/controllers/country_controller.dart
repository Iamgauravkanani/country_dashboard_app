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

  Future<void> fetchCountries({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      countries.clear();
      filteredCountries.clear();
    }
    
    if (!hasMoreData.value && !refresh) {
      debugPrint('No more countries to fetch');
      return;
    }
    
    if (isLoading.value) {
      debugPrint('Already loading countries');
      return;
    }
    
    try {
      isLoading.value = true;
      error.value = '';
      
      debugPrint('Fetching countries for page ${currentPage.value}');
      final newCountries = await _apiService.getCountries(
        page: currentPage.value,
        limit: 20,
      );
      
      if (newCountries.isEmpty) {
        hasMoreData.value = false;
        debugPrint('No more countries available');
      } else {
        countries.addAll(newCountries);
        currentPage.value++;
        debugPrint('Added ${newCountries.length} countries. Total: ${countries.length}');
        filterCountries(); // Apply current filter to new countries
      }
    } catch (e) {
      debugPrint('Error fetching countries: $e');
      error.value = 'Failed to load countries. Please check your internet connection and try again.';
      
      // Try fallback API if main API fails
      try {
        debugPrint('Trying fallback API...');
        final fallbackCountries = await _apiService.getCountriesFallback(
          page: currentPage.value,
          limit: 20,
        );
        
        if (fallbackCountries.isNotEmpty) {
          countries.addAll(fallbackCountries);
          currentPage.value++;
          error.value = '';
          debugPrint('Successfully loaded ${fallbackCountries.length} countries from fallback API');
          filterCountries(); // Apply current filter to new countries
        }
      } catch (fallbackError) {
        debugPrint('Fallback API also failed: $fallbackError');
        error.value = 'Unable to load countries. Please try again later.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshCountries() async {
    await fetchCountries(refresh: true);
  }

  void addCustomCountry(CustomCountry customCountry) {
    debugPrint('Adding custom country: ${customCountry.name}');
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
